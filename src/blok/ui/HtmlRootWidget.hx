package blok.ui;

import blok.core.UniqueId;
import blok.ui.RootWidget;

class HtmlRootWidget extends RootWidget {
  static final type = new UniqueId();

  final el:js.html.Element;

  public function new(el, platform,  child) {
    super(platform, child);
    this.el = el;
  }

  public function getWidgetType():UniqueId {
    return type;
  }

  public function resolveRootObject():Dynamic {
    return el;
  }
}
