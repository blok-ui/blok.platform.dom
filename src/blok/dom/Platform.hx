package blok.dom;

import js.html.Element;
import blok.VNode;

class Platform {
  public static function mount(el:Element, child:VNode) {
    var root = new NativeComponent(VNative.getTypeForNode(el), cast el, { children: [ child ] });
    root.initializeRootComponent(new DomDiffer());
    return root;
  }

  // public static function hydrate(el:Element, child:VNode) {
  //   var engine = new DomEngine();
  //   return engine.hydrate(el, child);
  // }
}
