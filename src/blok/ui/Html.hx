package blok.ui;

import blok.ui.Key;
import blok.ui.FragmentWidget;
import blok.ui.Widget;

@:build(blok.html.HtmlBuilder.build(
  'blok.html.HtmlTags', 
  'blok.ui.HtmlElementWidget',
  (_:js.html.Node)
))
class Html {
  public static inline function fragment(...children:Widget):Widget {
    return new FragmentWidget(children);
  }

  public static inline function text(content:String, ?key:Key):Widget {
    return new HtmlTextWidget(content, key);
  }
}
