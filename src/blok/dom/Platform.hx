package blok.dom;

import js.html.Element;

class Platform extends blok.Platform {
  public static function mount(
    el:Element,
    root:VNode,
    ?initialEffect
  ) {
    var platform = createPlatform();
    var root = createRoot(el, root);
    platform.mountRootWidget(root, initialEffect);
    return root;
  }

  public static function hydrate(
    el:Element,
    root:VNode,
    ?initialEffect
  ) {
    var platform = createPlatform();
    var effects = EffectManager.createEffectManager();
    var root = Hydrator.hydrate(el, root, platform, effects.register);
    if (initialEffect != null) effects.register(initialEffect);
    effects.dispatch();
    return root;
  }

  public inline static function createPlatform() {
    return new Platform(DefaultScheduler.getInstance());
  }

  public inline static function createRoot(el:Element, root:VNode) {
    return new ElementWidget(
      el, 
      VElement.getTypeForNode(el),
      {},
      [ root ]
    );
  }

  public function createManagerForComponent(component:Component):ConcreteManager {
    return new ComponentManager(component);
  }
}
