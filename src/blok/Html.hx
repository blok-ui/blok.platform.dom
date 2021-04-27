package blok;

import blok.Key;

@:build(blok.core.html.HtmlBuilder.build('blok.core.html.HtmlTags', (_:js.html.Node)))
class Html {
  public static inline function fragment(children:Array<VNode>):VNode {
    return VFragment(children);
  }

  public static inline function text(content:String, ?key:Key):VNode {
    return VComponent(TextType, { content: content }, key);
  }
}
