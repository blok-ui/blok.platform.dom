package blok.dom;

import js.html.Node;
import js.html.Element;

/**
  Utilities for moving real elements/nodes around the DOM.
**/
class ConcreteTools {
  public inline static function insertConcreteChildAt(parent:Widget, el:Element, pos:Int, childWidget:Widget) {
    var children:Array<Node> = cast childWidget.getConcreteManager().toConcrete();
    
    if (pos == 0) {
      el.prepend(...children);
      return;
    }

    var previousWidget = parent.getChildAt(pos - 1);

    if (previousWidget == null) {
      el.append(...children);
      return;
    }

    var previousElement:Element = previousWidget
      .getConcreteManager()
      .getLastConcreteChild();
      
    if (previousElement == null) {
      throw 'We may need to rethink this';
    }

    previousElement.after(...children);
  }

  public inline static function appendConcreteChild(parent:Widget, el:Element, childWidget:Widget) {
    var children:Array<Node> = cast childWidget.getConcreteManager().toConcrete();
    el.append(...children);
  }
}
