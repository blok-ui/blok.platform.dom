package blok.dom;

import js.html.Element;

class Platform extends blok.Platform {
  public static function mount(
    el:Element,
    root:VNode,
    ?initialEffect
  ) {
    var platform = new Platform(new DefaultScheduler());
    var root = new ElementWidget(
      el, 
      VElement.getTypeForNode(el),
      {},
      [ root ]
    );
    platform.mountRootWidget(root, initialEffect);
    return root;
  }

  public function createManagerForComponent(component:Component):ConcreteManager {
    return new ComponentManager(component);
  }
}
