package blok;

import js.html.Text;
import blok.WidgetType.getUniqueTypeId;

class TextWidget extends ConcreteWidget {
  public static final type:WidgetType = getUniqueTypeId();

  final node:Text;

  public function new(node) {
    this.node = node;
  }
  
  override function dispose() {
    node.remove();
    super.dispose();
  }

  public function setText(content:String) {
    if (node.textContent == content) return;
    node.textContent = content;
  }
  
  public function getWidgetType() {
    return type;
  }

  public function toConcrete() {
    return [ node ];
  }

  public function getFirstConcreteChild() {
    return node;
  }

  public function getLastConcreteChild() {
    return node;
  }

  public function toString() {
    return node.textContent;
  }

  public function __performUpdate(registerEffect:(effect:()->Void)->Void):Void {
    // noop
  }

  public function addConcreteChild(widget:Widget) {
    throw 'invalid';
  }

  public function insertConcreteChildAt(pos:Int, widget:Widget) {
    throw 'invalid';
  }

  public function removeConcreteChild(widget:Widget):Void {
    throw 'invalid';
  }

  public function moveConcreteChildTo(pos:Int, child:Widget):Void {
    throw 'invalid';
  }
}

