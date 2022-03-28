package blok.dom;

import js.html.Text;
import js.html.Element;
import blok.core.Debug;
import blok.core.DefaultScheduler;
import blok.ui.*;

class Platform extends blok.ui.Platform {
  public static function mount(el, child) {
    var platform = new Platform(DefaultScheduler.getInstance());
    var widget = new HtmlRootWidget(el, platform, child);
    return platform.mountRootWidget(widget);
  }

  public static function hydrate(el, child) {
    var platform = new Platform(DefaultScheduler.getInstance());
    var widget = new HtmlRootWidget(el, platform, child);
    return platform.hydrateRootWidget(new HtmlHydrationCursor(el), widget);
  }

  public function insertObject(object:Dynamic, slot:Null<Slot>, findParent:() -> Dynamic) {
    var el:Element = object;
    if (slot != null && slot.previous != null) {
      var relative:Element = slot.previous.getObject();
      relative.after(el);
    } else {
      var parent:Element = findParent();
      Debug.assert(parent != null);
      parent.appendChild(el);
    }
  }

  public function moveObject(object:Dynamic, from:Null<Slot>, to:Null<Slot>, findParent:() -> Dynamic):Void {
    var el:Element = object;

    Debug.assert(to != null);

    if (from != null && !from.indexChanged(to)) {
      return;
    }

    if (to.previous == null) {
      var parent:Element = findParent();
      Debug.assert(parent != null);
      parent.prepend(el);
      return;
    }

    var relative:Element = to.previous.getObject();
    Debug.assert(relative != null);
    relative.after(el);
  }

  public function removeObject(object:Dynamic, slot:Null<Slot>) {
    var el:Element = object;
    el.remove();
  }

  public function updateObject(object:Dynamic, newWidget:ObjectWidget, oldWidget:Null<ObjectWidget>):Dynamic {
    return newWidget.updateObject(object, oldWidget);
  }

  public function createObject(widget:ObjectWidget):Dynamic {
    return widget.createObject();
  }

  public function createPlaceholderObject(widget:Widget):Dynamic {
    return new Text('');
  }
}
