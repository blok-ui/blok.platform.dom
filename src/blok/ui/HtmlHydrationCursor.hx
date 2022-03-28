package blok.ui;

import js.html.Node;
import blok.ui.HydrationCursor;

class HtmlHydrationCursor implements HydrationCursor {
  var node:Null<Node>;

  public function new(node) {
    this.node = node;
  }

  public function current():Dynamic {
    return node;
  }

  public function next() {
    if (node == null) return;
    node = node.nextSibling;
  }

  public function currentChildren():HydrationCursor {
    if (node == null) return new HtmlHydrationCursor(null);
    return new HtmlHydrationCursor(node.firstChild);
  }

  public function move(current:Dynamic) {
    node = current;
  }
}
