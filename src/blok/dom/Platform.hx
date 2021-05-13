package blok.dom;

import js.html.Element;
import blok.VNode;

class Platform {
  public static function mount(el:Element, child:VNode) {
    var engine = new DomEngine();
    var root = new NativeComponent(cast el, { children: [ child ] });
    root.initializeRootComponent(engine);
    return root;
  }

  public static function hydrate(el:Element, child:VNode) {
    var engine = new DomEngine();
    return engine.hydrate(el, child);
  }
}
