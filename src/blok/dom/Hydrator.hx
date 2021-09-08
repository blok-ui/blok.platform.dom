package blok.dom;

import js.html.Text;
import js.html.Node;
import js.html.Element;
import blok.core.html.Hydratable;

// @todo: This is probably rather fragile, as we're basically handling
//        widget lifecycles manually. Ideally we'd just be able to
//        use `widget.performUpdate(...)`, but right now that'll create
//        elements, which is not what we want when hydrating. 

function hydrate(
  el:Element,
  vnode:VNode,
  platform:Platform,
  registerEffect:(effect:()->Void)->Void
) {
  var root = new ElementWidget(el, VElement.getTypeForNode(el), {}, []);
  root.initializeWidget(null, platform);
  root.__status = WidgetValid;
  createChildren(root, [ vnode ], platform, el.firstChild, registerEffect);
  return root;
}

function createElementWidget<Attrs:{}>(
  el:Element, 
  vnode:VElement<Attrs>,
  parent:Widget,
  platform:Platform,
  registerEffect:(effect:()->Void)->Void
):ElementWidget<Attrs> {
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
  if (vnode.children.length > 0) {
    createChildren(widget, vnode.children, platform, el.firstChild, registerEffect);
  }
  return widget;
}

function createTextWidget(
  text:Text,
  vnode:VText,
  parent:Widget,
  platform:Platform,
  registerEffect:(effect:()->Void)->Void
) {
  #if debug assertIsTextNode(text); #end
  var widget = new TextWidget(cast text);
  widget.initializeWidget(parent, platform, vnode.key);
  widget.__status = WidgetValid;
  return widget;
}

@:access(blok.Component)
function createComponent<Props:{}>(
  firstNode:Node,
  vnode:VComponent<Props>,
  parent:Widget,
  platform:Platform,
  registerEffect:(effect:()->Void)->Void
) {
  if (vnode == null) return null;
  var comp = vnode.factory(vnode.props);
  comp.initializeWidget(parent, platform, vnode.key);
  var manager:ComponentManager = cast comp.getConcreteManager();
  firstNode.parentNode.insertBefore(manager.marker, firstNode);
  if (comp is Hydratable) {
    var hydratable:Hydratable = cast comp;
    hydratable.hydrate(firstNode, registerEffect);
  } else {
    createChildren(comp, comp.__performRender().toArray(), platform, firstNode, registerEffect);
  }
  registerEffect(comp.runComponentEffects);
  comp.__status = WidgetValid;
  return comp;
}

function createChildren(
  parent:Widget,
  children:Array<VNode>,
  platform:Platform,
  real:Node,
  registerEffect:(effect:()->Void)->Void
) {
  for (child in children) switch Std.downcast(child, VElement) {
    case null: switch Std.downcast(child, VText) {
      case null:
        var comp = createComponent(real, cast child, parent, platform, registerEffect);
        if (comp != null) { 
          parent.__children.add(comp);
          real = comp.getConcreteManager().getLastConcreteChild().nextSibling;
        }
      case text:
        parent.__children.add(createTextWidget(cast real, text, parent, platform, registerEffect));
        real = real.nextSibling;
    }
    case element:
      parent.__children.add(createElementWidget(cast real, element, parent, platform, registerEffect));
      real = real.nextSibling;
  }
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
