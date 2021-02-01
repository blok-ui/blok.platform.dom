package blok;

import blok.core.Key;

@:build(blok.core.html.HtmlBuilder.build('blok.core.html.HtmlTags', (_:js.html.Node)))
class Html {
  public static inline function fragment(children:Array<VNode>):VNode {
    return VFragment(children);
  }

  public static inline function text(content:String, ?key:Key):VNode {
    return VNative(TextType, { content: content }, null, key, []);
  }
}
