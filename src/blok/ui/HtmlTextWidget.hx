package blok.ui;

import js.html.Text;
import blok.core.UniqueId;

class HtmlTextWidget extends ObjectWidget {
  static final type = new UniqueId();

  final content:String;

  public function new(content, ?key) {
    super(key);
    this.content = content;
  }

  public function getChildren():Array<Widget> {
    return [];
  }

  public function createObject():Dynamic {
    return new Text(content);
  }

  public function getWidgetType():UniqueId {
    return type;
  }

  public function updateObject(object:Dynamic, ?previousWidget:Widget):Dynamic {
    var text:Text = object;
    var previous:HtmlTextWidget = cast previousWidget;
    if (previous != null && content != previous.content) {
      text.textContent = content == null ? '' : content;
    }
    return text;
  }

  public function createElement():Element {
    return new ObjectWithoutChildrenElement(this);
  }
}
