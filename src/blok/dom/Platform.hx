package blok.dom;

import js.html.Element;
import blok.VNode;

class Platform {
  public static function mount(el:Element, child:VNode) {
    var engine = new Engine([ new DomPlugin() ]);
    var root = new NativeComponent(
      VNative.getTypeForNode(el), 
      cast el, 
      { children: [ child ] }
    );
    
    root.initializeRootComponent(engine);
    root.renderRootComponent();

    return root;
  }
}
