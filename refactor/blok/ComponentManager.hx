package blok;

import js.Browser;
import js.html.Text;
import js.html.Element;
import blok.dom.ConcreteTools;

class ComponentManager implements ConcreteManager {
  final marker:js.html.Text = Browser.document.createTextNode('');
  final component:Component;

  public function new(component) {
    this.component = component;
  }

  public function toConcrete() {
    var concrete = component.getConcreteChildren();
    var els:Array<Element> = [ cast marker ];
    
    for (child in concrete) {
      els = els.concat(cast child.toConcrete());
    }

    return els;
  }

  public function getFirstConcreteChild() {
    return marker;
  }

  public function getLastConcreteChild() {
    return toConcrete().pop();
  }

  public function toString() {
    return toConcrete().map(el -> el.innerHTML).join('');
  }
  
  public function addConcreteChild(widget:Widget) {
    var el:Element = cast marker.parentNode;
    if (el == null) {
      // Ignore -- we're at the initial render and this
      // will be handled by the parent Widget.
      return;
    }
    ConcreteTools.appendConcreteChild(component, el, widget);
  }

  public function insertConcreteChildAt(pos:Int, widget:Widget) {
    var el:Element = cast marker.parentNode;
    if (el == null) {
      // Ignore -- we're at the initial render and this
      // will be handled by the parent Widget.
      return;
    }
    ConcreteTools.insertConcreteChildAt(component, el, pos, widget);
  }

  public function moveConcreteChildTo(pos:Int, widget:Widget):Void {
    insertConcreteChildAt(pos, widget);
  }

  public function removeConcreteChild(widget:Widget):Void {
    var els:Array<Element> = cast widget.getConcreteManager().toConcrete();
    for (child in els) child.remove();
  }

  public function dispose() {
    marker.remove();
    for (child in component.getChildren()) removeConcreteChild(child);
  }
}
