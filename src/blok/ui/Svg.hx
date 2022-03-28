package blok.ui;

@:build(blok.html.HtmlBuilder.build(
  'blok.html.SvgTags',
  'blok.ui.HtmlElementWidget',
  (_:js.html.Node),
  'svg'
))
class Svg {
  inline extern public static final NAMESPACE = 'http://www.w3.org/2000/svg';
}
