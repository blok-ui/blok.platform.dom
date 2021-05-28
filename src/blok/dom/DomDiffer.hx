package blok.dom;

import js.html.Node;
import js.html.Text;

using blok.dom.Cursor;
using blok.dom.DomTools;

class DomDiffer extends Differ {
  override function patchComponent(component:Component, vnodes:Array<VNode>, isInit:Bool) {
    var previous = component.getChildComponents().copy();
    diffChildren(component, vnodes);
    if (isInit) 
      initRealNodes(component) 
    else 
      updateRealNodes(component, previous);
  }

  public function initRealNodes(component:Component) {
    switch Std.downcast(component, NativeComponent) {
      case null:
      case native if (!(native.node is Text)):
        DomTools.setChildren(
          0,
          native.node.traverseChildren(),
          native.getChildComponents(),
          native
        );
      default:
    }
  }

  public function updateRealNodes(component:Component, previous:Array<Component>) {
    switch Std.downcast(component, NativeComponent) {
      case null:
        var previousCount = 0;
        var first:Node = null;

        for (node in previous.getNodesFromComponents()) {
          if (first == null) first = node;
          previousCount++;
        }

        if (first == null) {
          // todo: throw something
          trace(Type.getClassName(Type.getClass(component)));
        }
        
        DomTools.setChildren(
          previousCount,
          first.traverseSiblings(),
          component.getChildComponents(),
          component
        );
      case native:
        DomTools.setChildren(
          native.node.childNodes.length, 
          native.node.traverseChildren(), 
          native.getChildComponents(), 
          native
        );
    }
  }
}
