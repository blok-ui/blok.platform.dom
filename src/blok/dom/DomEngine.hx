package blok.dom;

import js.html.Node;
import js.html.Text;
import blok.core.Differ;
import blok.core.DefaultScheduler;
import blok.core.Scheduler;
import blok.core.Rendered;
import blok.exception.*;

class DomEngine implements Engine {
  final scheduler:Scheduler;
  
  public function new(?scheduler) {
    this.scheduler = scheduler == null ? new DefaultScheduler() : scheduler;
  }

  public function initialize(component:Component) {
    return switch Std.downcast(component, NativeComponent) {
      case null:
        var result = Differ.initialize(doRenderAndEnsurePlaceholder(component), this, component);
        result;
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
          new Cursor(first.parentNode, first),
          result,
          component
        );

        result;
      case native:
        var previousCount = native.node.childNodes.length;
        var result = Differ.diff(component.__doRenderLifecycle(), this, component, component.__renderedChildren);
        setChildren(
          previousCount, 
          new Cursor(native.node, native.node.firstChild),
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
