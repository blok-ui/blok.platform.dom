package blok.dom;

import js.Browser.document;
import blok.dom.Hydrator.hydrate;

using Medic;

class HydratorTest implements TestCase {
  public function new() {}

  @:test('Hydration works in a simple case')
  function testSimpleHydration() {
    var el = document.createElement('div');
    el.setAttribute('id', 'root');
    
    var child = document.createElement('div');
    child.setAttribute('class', 'foo');
    child.appendChild(document.createTextNode('Foo'));
    el.appendChild(child);
    
    var platform = Platform.createPlatform();
    var effects = EffectManager.createEffectManager();
    var root = hydrate(el, Html.div({
      className: 'foor'
    }, Html.text('foo')), platform, effects.register);

    root.getChildren().length.equals(1);
    trace(root);
  }
}
