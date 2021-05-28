package blok;

@:build(blok.core.html.HtmlBuilder.build(
  'blok.core.html.SvgTags',
  'blok.VNative',
  (_:js.html.Node),
  'svg'
))
class Svg {}
