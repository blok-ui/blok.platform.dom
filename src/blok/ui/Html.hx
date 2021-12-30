package blok.ui;

@:build(blok.html.HtmlBuilder.build(
  'blok.html.HtmlTags', 
  'blok.ui.VElement',
  (_:js.html.Node)
))
class Html {
  public static inline function fragment(...children:VNode):VNode {
    return Fragment.node({ children: children.toArray() });
  }

  public static inline function placeholder() {
    return text('');
  }

  public static inline function text(content:String, ?key:Key):VNode {
    return new VText(content, key);
  }
}
