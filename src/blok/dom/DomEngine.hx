package blok.dom;

import haxe.DynamicAccess;
import js.html.Element;
import js.html.Node;
import js.html.Text;
import blok.core.Differ;
import blok.core.DefaultScheduler;
import blok.core.Scheduler;
import blok.core.Rendered;
import blok.exception.*;

using Reflect;
using StringTools;
using blok.dom.Cursor;

class DomEngine implements Engine {
  final scheduler:Scheduler;
  var isHydrating:Bool = false;

  public function new(?scheduler) {
    this.scheduler = scheduler == null ? new DefaultScheduler() : scheduler;
  }

  public function hydrate(el:Element, vNode:VNode) {
    isHydrating = true;
    
    var attrs:DynamicAccess<Dynamic> = {};
    for (attr in el.attributes) {
      attrs.set(attr.name, attr.value);
    }
    var root = new NativeComponent(el, { attributes: attrs });
    root.initializeComponent(this);
    hydrateVNode(el.traverseChildren(), vNode, root.__renderedChildren);

    isHydrating = false;

    root.__dequeueEffects();

    return root;
  }

  function hydrateVNode(cursor:Cursor, vNode:VNode, rendered:Rendered, ?parent:Component) {
    switch vNode {
      case VNone:
      case VComponent(type, _, key) if (type is TextType):
        var el:Element = cast cursor.current();
        var comp = new NativeComponent(el, {}, false);

        cursor.step();

        comp.initializeComponent(this, parent);
        rendered.addChild(TextType, key, comp);
      case VComponent(type, properties, key) if (type is NodeType):
        var props:{ attrs:{}, ?children:Array<VNode> } = properties;
        var attrs:DynamicAccess<Dynamic> = {};
        var el:Element = cast cursor.current();

        cursor.step();
        
        for (attr in el.attributes) {
          attrs.set(attr.name, attr.value);
        }

        // Events won't be present on existing nodes, so lets bind those.
        for (name in props.attrs.fields()) {
          if (name.startsWith('on')) {
            attrs.set(name, props.attrs.field(name));
            NodeType.updateNodeAttribute(el, name, null, props.attrs.field(name));
          }
        }
        
        var comp = new NativeComponent(el, { attributes: attrs }); 
        
        comp.initializeComponent(this, parent);
        rendered.addChild(type, key, comp);
        
        if (props.children != null) {
          var subCursor = el.traverseChildren();
          for (child in props.children) {
            hydrateVNode(subCursor, child, comp.__renderedChildren, comp);
          }
        }
      case VComponent(type, properties, key):
        var component = type.create(properties);
        var child:VNode;

        component.initializeComponent(this, parent);
        child = component.__doRenderLifecycle();
        
        switch child {
          case null | VNone | VFragment([]):
            // Insert a placeholder if needed.
            var text = TextType.create({ content: '' });
            text.initializeComponent(this, component);
            cursor.insert(text.node);
            component.__renderedChildren.addChild(TextType, null, text);
          default:
            hydrateVNode(cursor, child, component.__renderedChildren, component);
        }
        
        rendered.addChild(type, key, component);
      case VFragment(nodes):
        for (child in nodes) {
          hydrateVNode(cursor, child, rendered, parent);
        }
    }
  }

  public function initialize(component:Component) {
    if (isHydrating) return new Rendered();

    return switch Std.downcast(component, NativeComponent) {
      case null:
        Differ.initialize(doRenderAndEnsurePlaceholder(component), this, component);
      case native if (!(native.node is Text)):
        var result = Differ.initialize(component.__doRenderLifecycle(), this, component);
        setChildren(
          0,
          new Cursor(native.node, native.node.firstChild),
          result,
          component
        );
        result;
      case _:
        new Rendered();
    }
  }

  public function update(component:Component) {
    return switch Std.downcast(component, NativeComponent) {
      case null:
        var previousCount = 0;
        var first:Node = null;
        var before = component.__renderedChildren;
        var result = Differ.diff(doRenderAndEnsurePlaceholder(component), this, component, before);

        for (node in getNodesFromRendered(before)) {
          if (first == null) first = node;
          previousCount++;
        }

        if (first == null) {
          trace(Type.getClassName(Type.getClass(component)));
        }
        
        setChildren(
          previousCount,
          first.traverseSiblings(),
          result,
          component
        );

        result;
      case native:
        var previousCount = native.node.childNodes.length;
        var result = Differ.diff(component.__doRenderLifecycle(), this, component, component.__renderedChildren);
        setChildren(
          previousCount, 
          native.node.traverseChildren(),
          result,
          component
        );
        result;
    }
  }

  public function schedule(cb:()->Void):Void {
    scheduler.schedule(cb);
  }

  function getNodesFromRendered(rendered:Rendered) {
    var nodes:Array<Node> = [];
    for (child in rendered.children) switch Std.downcast(child, NativeComponent) {
      case null: 
        nodes = nodes.concat(getNodesFromRendered(child.__renderedChildren));
      case native:
        nodes.push(native.node);
    }
    return nodes;
  }

  function setChildren(
    previousCount:Int,
    cursor:Cursor,
    rendered:Rendered,
    component:Component // for debugging
  ) {
    try {
      var insertedCount = 0;
      var currentCount = 0;
      var nodes = getNodesFromRendered(rendered);

      for (node in nodes) {
        currentCount++;
        if (node == cursor.current()) cursor.step();
        else if (cursor.insert(node)) insertedCount++;
      }

      var deleteCount = previousCount + insertedCount - currentCount;
      
      for (i in 0...deleteCount) {
        if (!cursor.delete()) break;
      }
    } catch (e:BlokException) {
      throw e;
    } catch (e) {
      throw new WrappedException(e, component);
    }
  }

  function doRenderAndEnsurePlaceholder(component:Component):VNode {
    return switch component.__doRenderLifecycle() {
      case null | VNone | VFragment([]): VComponent(TextType, { content: '' });
      case vn: vn;
    }
  }
}
