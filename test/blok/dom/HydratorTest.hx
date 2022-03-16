package blok.dom;

import js.Browser.document;
import blok.ui.Effect;
import blok.dom.Hydrator.hydrate;

using Medic;
using Blok;

class HydratorTest implements TestCase {
  public function new() {}

  @:test('Hydration works in a simple case')
  @:test.async
  function testSimpleHydration(done) {
    var el = document.createElement('div');
    el.setAttribute('id', 'root');
    
    var child = document.createElement('div');
    child.setAttribute('class', 'foo');
    child.appendChild(document.createTextNode('Foo'));
    el.appendChild(child);
    
    var platform = Platform.createPlatform();
    var effects = Effect.createTrigger();
    
    hydrate(el, Html.div({
      className: 'foor'
    }, Html.text('foo')), platform, effects, (root) -> {
      root.getChildren().length.equals(1);
      done();
    });
  }
}
