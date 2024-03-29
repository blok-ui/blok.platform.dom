package blok.ui;

import js.Browser;
import js.html.Node;
import js.html.Element;

using Lambda;

class ComponentManager implements ConcreteManager {
  #if !debug
    public final marker:js.html.Text = Browser.document.createTextNode('');
  #else
    public final marker:js.html.Comment;
  #end
  final component:Component;

  public function new(component) {
    this.component = component;
    #if debug 
      marker = Browser.document.createComment(
        'blok-marker:' + Type.getClassName(Type.getClass(component))
      ); 
    #end
  }

  public function toConcrete():Concrete {
    var concrete = component.getChildConcreteManagers();
    var els:Array<Element> = [ cast marker ].concat(
      concrete.map(c -> c.toConcrete().toArray()).flatten()
    );
    return els;
  }

  public function toString() {
    return toConcrete().map(el -> el.innerHTML).join('');
  }
  
  public function addConcreteChild(childWidget:Widget) {
    if (marker.parentNode == null) {
      // Will be handled by a parent ConcreteWidget.
      return;
    }
    
    var last:Element = toConcrete().last();
    var children:Array<Node> = cast childWidget
      .getConcreteManager()
      .toConcrete()
      .toArray();
    
    last.after(...children);
  }

  public function insertConcreteChildAt(pos:Int, childWidget:Widget) {
    if (marker.parentNode == null) {
      // Will be handled by a parent ConcreteWidget.
      return;
    }

    var children:Array<Node> = cast childWidget.getConcreteManager().toConcrete();
    
    if (pos == 0) {
      marker.after(...children);
      return;
    }

    var previousWidget = component.getChildAt(pos - 1);

    if (previousWidget == null) {
      addConcreteChild(childWidget);
      return;
    }

    var previousElement:Element = previousWidget
      .getConcreteManager()
      .toConcrete()
      .last();

    previousElement.after(...children);
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
