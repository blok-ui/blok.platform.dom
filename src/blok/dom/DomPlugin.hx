package blok.dom;

import js.html.Node;
import js.html.Text;

using blok.dom.DomTools;
using blok.dom.Cursor;

class DomPlugin implements Plugin {
  public function new() {}

  public function prepareVNodes(component:Component, vnode:VNodeResult):VNodeResult {
    if (component is NativeComponent) {
      return vnode;
    }

    return if (vnode == null) {
      Html.placeholder();
    } else switch vnode.unwrap() {
      case VNone | VGroup([]):
        Html.placeholder();
      default:
        vnode;
    }
  }
  
  public function wasInitialized(component:Component) {
    // noop
  }

  public function wasRendered(component:Component) {
    switch Std.downcast(component, NativeComponent) {
      case null:
        if (component.componentIsRenderingForTheFirstTime()) return;
    
        var previousCount = 0;
        var previous = component.getPreviousChildren().getNodesFromComponents();
        var first:Node = null;
    
        for (node in previous) {
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
          component.getChildren().getNodesFromComponents(),
          component
        );
      case native:
        if (native.node is Text) return;

        if (native.componentIsRenderingForTheFirstTime()) {
          DomTools.setChildren(
            0,
            native.node.traverseChildren(),
            native.getChildren().getNodesFromComponents(),
            native
          );
        } else {
          DomTools.setChildren(
            native.node.childNodes.length, 
            native.node.traverseChildren(), 
            native.getChildren().getNodesFromComponents(), 
            native
          );
        }
    }
  }

  public function willBeDisposed(component:Component) {
    // noop
  }
}
