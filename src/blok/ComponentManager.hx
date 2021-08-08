package blok;

import js.Browser;
import js.html.Text;
import js.html.Node;
import js.html.Element;

// @Todo: Remove the marker if we have actual elements in the tree.
//        Right now we kind of sort of do it.
//
//        Note that this will work better if we just pass a 
//        PlaceholderWidget from the parent Component :P.
class ComponentManager implements ConcreteManager {
  #if !debug
    final marker:Text = Browser.document.createTextNode('');
  #else
    final marker:js.html.Comment;
  #end
  final component:Component;

  public function new(component) {
    this.component = component;
    #if debug marker = Browser.document.createComment(
      'blok-placeholder:' + Type.getClassName(Type.getClass(component))
    ); #end
  }

  public function toConcrete() {
    var concrete = component.getConcreteChildren();
    var els:Array<Element> = [];
    
    for (child in concrete) {
      els = els.concat(cast child.toConcrete());
    }

    if (els.length == 0) {
      els.push(cast marker);
    }
    
    return els;
  }

  public function getFirstConcreteChild() {
    return toConcrete()[0];
  }

  public function getLastConcreteChild() {
    return toConcrete().pop();
  }

  public function toString() {
    return toConcrete().map(el -> el.innerHTML).join('');
  }
  
  public function addConcreteChild(childWidget:Widget) {
    var first = getFirstConcreteChild();
    var parentNode = first.parentNode;
    if (parentNode == null) {
      // Will be handled by the next ConcreteWidget in the tree.
      return;
    }
    
    var last:Element = getLastConcreteChild();
    var children:Array<Node> = cast childWidget.getConcreteManager().toConcrete();
    last.after(...children);

    if (marker.parentNode != null) marker.remove();
  }

  public function insertConcreteChildAt(pos:Int, childWidget:Widget) {
    var first = getFirstConcreteChild();
    var parentNode = first.parentNode;
    if (parentNode == null) {
      // Will be handled by the next ConcreteWidget in the tree.
      return;
    }

    var children:Array<Node> = cast childWidget.getConcreteManager().toConcrete();
    
    if (pos == 0) {
      first.after(...children);
      return;
    }

    var previousWidget = component.getChildAt(pos - 1);

    if (previousWidget == null) {
      addConcreteChild(childWidget);
      return;
    }

    var previousElement:Element = previousWidget
      .getConcreteManager()
      .getLastConcreteChild();
      
    if (previousElement == null) {
      throw 'We may need to rethink this';
    }

    previousElement.after(...children);
    
    if (marker.parentNode != null) marker.remove();
  }

  public function moveConcreteChildTo(pos:Int, widget:Widget):Void {
    insertConcreteChildAt(pos, widget);
  }

  public function removeConcreteChild(widget:Widget):Void {
    var els:Array<Element> = cast widget.getConcreteManager().toConcrete();
    if (marker.parentNode == null) {
      // Ensure the marker is mounted if needed
      if (toConcrete().length <= 1) getFirstConcreteChild().before(marker);
    }
    for (child in els) child.remove();
  }

  public function dispose() {
    marker.remove();
    for (child in component.getChildren()) removeConcreteChild(child);
  }
}
