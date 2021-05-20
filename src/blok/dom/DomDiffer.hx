package blok.dom;

import js.html.Node;
import js.html.Text;

using blok.dom.Cursor;
using blok.dom.DomTools;

class DomDiffer {
  static public function create() {
    return new Differ({
      createPlaceholder: createPlaceholder,
      onInitialize: initializeComponent,
      onUpdate: updateComponent,
    });
  }

  static function createPlaceholder(parent:Component) {
    return if (parent is NativeComponent) 
      null 
    else 
      TextType.create({ content: '' });
  }

  static function initializeComponent(component:Component) {
    return switch Std.downcast(component, NativeComponent) {
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

  static function updateComponent(component:Component, previous:Array<Component>) {
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
