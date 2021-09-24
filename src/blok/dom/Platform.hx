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
    ?next:(widget:Widget)->Void,
    ?initialEffect
  ) {
    var platform = createPlatform();
    var effects = EffectManager.createEffectManager();
    if (initialEffect != null) effects.register(initialEffect);
    Hydrator.hydrate(
      el,
      root,
      platform, 
      effects.register,
      rootWidget -> {
        effects.dispatch();
        next(rootWidget);
      }
    );
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
