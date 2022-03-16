package blok.ui;

import js.Browser;

class VText implements VNode {
  public final type:WidgetType = TextWidget.type;
  public final key:Null<Key>;
  public final props:Dynamic;
  public final children:Null<Array<VNode>> = null;

  public function new(text:String, ?key) {
    this.key = key;
    this.props = text;
  }

  public function createWidget(?parent:Widget, platform:Platform, effects:Effect):Widget {
    var widget = new TextWidget(Browser.document.createTextNode(props));
    widget.initializeWidget(parent, platform, key);
    widget.performUpdate(effects);
    return widget;
  }

  public function updateWidget(widget:Widget, effects:Effect):Widget {
    var text:TextWidget = cast widget;
    text.setText(props);
    text.performUpdate(effects);
    return widget;
  }
}
