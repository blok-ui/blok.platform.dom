package blok.dom;

import js.html.Element;

class Platform extends blok.Platform {
  public static function mount(
    el:Element,
    root:VNode
  ) {
    var platform = new Platform(new DefaultScheduler());
    var widget = new PlatformWidget(
      new ElementWidget(
        el, 
        VElement.getTypeForNode(el),
        {},
        [ root ]
      ),
      platform
    );
    widget.mount();
    return widget;
  }

  public function createManagerForComponent(component:Component):ConcreteManager {
    return new ComponentManager(component);
  }
}
