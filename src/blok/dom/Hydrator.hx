package blok.dom;

import js.html.Text;
import js.html.Node;
import js.html.Element;
import blok.Platform;
import blok.core.html.Hydratable;

function hydrate(
  el:Element,
  vnode:VNode,
  platform:Platform,
  registerEffect:(effect:()->Void)->Void,
  next:(root:Widget)->Void
) {
  var root = new ElementWidget(el, VElement.getTypeForNode(el), {}, []);
  root.initializeWidget(null, platform);
  root.__status = WidgetValid;
  hydrateChildren(
    root, 
    [ vnode ],
    platform,
    el.firstChild,
    registerEffect,
    () -> next(root)
  );
}

@:access(blok.Component)
function hydrateComponent<Props:{}>(
  firstNode:Node,
  vnode:VComponent<Props>,
  parent:Widget,
  platform:Platform,
  registerEffect:(effect:()->Void)->Void,
  next:(widget:Widget)->Void
) {
  if (vnode == null) next(null);
  
  var comp = vnode.factory(vnode.props);
  comp.initializeWidget(parent, platform, vnode.key);
  
  var manager:ComponentManager = cast comp.getConcreteManager();
  var parentNode:Node = firstNode == null
    ? getParentNodeFromParentWidget(parent)
    : firstNode.parentNode;
  var finish = () -> {
    registerEffect(comp.runComponentEffects);
    comp.__status = WidgetValid;
    next(comp);
  };

  parentNode.insertBefore(manager.marker, firstNode);

  if (comp is Hydratable) {
    var hydratable:Hydratable = cast comp;
    hydratable.hydrate(firstNode, registerEffect, finish);
  } else {
    hydrateChildren(
      comp,
      comp.__performRender().toArray(),
      platform,
      firstNode,
      registerEffect,
      finish
    );
  }
}

function getParentNodeFromParentWidget(parent:Widget):Node {
  return switch Std.downcast(parent, ElementWidget) {
    case null: 
      // @todo: handle cases where parent has no nodes. 
      parent.getConcreteManager().toConcrete().last().parentNode;
    case el: 
      @:privateAccess el.el;
  }
}

function hydrateText(
  text:Text,
  vnode:VText,
  parent:Widget,
  platform:Platform,
  registerEffect:(effect:()->Void)->Void,
  next: (widget:Widget)->Void
) {
  #if debug assertIsTextNode(text); #end
  var widget = new TextWidget(cast text);
  widget.initializeWidget(parent, platform, vnode.key);
  widget.__status = WidgetValid;
  next(widget);
}

function hydrateElement<Attrs:{}>(
  el:Element,
  vnode:VElement<Attrs>,
  parent:Widget,
  platform:Platform,
  registerEffect:(effect:()->Void)->Void,
  next:(widget:Widget)->Void
) {
  #if debug assertIsElement(el, vnode.tag); #end
  var widget = new ElementWidget(
    el, 
    VElement.getTypeForNode(el),
    vnode.props,
    vnode.children,
    vnode.ref
  );
  widget.initializeWidget(parent, platform, vnode.key);
  widget.__status = WidgetValid;
  if (vnode.ref != null) registerEffect(() -> vnode.ref(el));
  if (vnode.children != null && vnode.children.length > 0) {
    hydrateChildren(
      widget,
      vnode.children,
      platform,
      el.firstChild,
      registerEffect,
      () -> next(widget)
    );
  } else {
    next(widget);
  }
}

function hydrateChildren(
  parent:Widget,
  vnodeChildren:Array<VNode>,
  platform:Platform,
  real:Node,
  registerEffect:(effect:()->Void)->Void,
  next:()->Void
) {
  var children = vnodeChildren.copy();

  function process() {
    if (children.length == 0) {
      return next();
    }
    
    var child = children.shift();

    if (child == null) {
      return process();
    }

    switch Std.downcast(child, VElement) {
      case null: switch Std.downcast(child, VText) {
        case null:
          hydrateComponent(
            real,
            cast child,
            parent,
            platform,
            registerEffect,
            widget -> {
              if (widget == null) {
                return process();  
              }
              parent.__children.add(widget);
              real = widget.getConcreteManager().toConcrete().last().nextSibling;
              process();
            }
          );
        case text:
          hydrateText(
            cast real,
            text,
            parent,
            platform,
            registerEffect,
            widget -> {
              parent.__children.add(widget);
              real = real.nextSibling;
              process();
            }
          );
      }
      case element:
        hydrateElement(
          cast real,
          element,
          parent,
          platform,
          registerEffect,
          widget -> {
            parent.__children.add(widget);
            real = real.nextSibling;
            process();
          }
        );
    }
  }

  process();
}

#if debug
  private function assertIsElement(node:Node, expectedTag:String) {
    if (node.nodeName.toLowerCase() != expectedTag) {
      throw 'Expected a ${expectedTag} but encontered a ${node.nodeName.toLowerCase()}.'
        + ' Blok\'s Hydrator expects the existing HTML to exactly match the'
        + ' VNode tree -- make sure you\'re passing in the right data to'
        + ' the initial render'; 
    }
  }

  private function assertIsTextNode(node:Node) {
    if (!(node is Text)) {
      throw 'Expected a Text node, but was encountered a ${node.nodeName}';
    }
  }
#end
