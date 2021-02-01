package blok.dom;

import js.html.Node;
import js.html.Element;
import blok.core.VNode;
import blok.core.Differ;

class Platform {
  inline public static function createContext(?plugins) {
    return new blok.core.Context(new Engine());
  }

  public static function mount(el:Element, factory:(context:Context)->VNode<Node>) {
    el.innerHTML = '';
    var context = createContext();
    Differ.renderWithSideEffects(cast el, [ factory(context) ], null, context);
  }
}
