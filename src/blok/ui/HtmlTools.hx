package blok.ui;

import js.html.Element;

using StringTools;

class HtmlTools {
  public static function updateNodeAttribute(
    el:Element,
    name:String,
    oldValue:Dynamic,
    newValue:Dynamic
  ):Void {
    var isSvg = el.namespaceURI == Svg.NAMESPACE;
    switch name {
      case 'ref' | 'key': 
        // noop
      case 'className':
        updateNodeAttribute(el, 'class', oldValue, newValue);
      case 'xmlns' if (isSvg): // skip
      case 'value' | 'selected' | 'checked' if (!isSvg):
        js.Syntax.code('{0}[{1}] = {2}', el, name, newValue);
      case _ if (!isSvg && js.Syntax.code('{0} in {1}', name, el)):
        js.Syntax.code('{0}[{1}] = {2}', el, name, newValue);
      default:
        name = getHtmlName(name);
        if (name.charAt(0) == 'o' && name.charAt(1) == 'n') {
          var name = name.toLowerCase();
          if (newValue == null) {
            Reflect.setField(el, name, null);
          } else {
            Reflect.setField(el, name, newValue);
          }
        } else if (newValue == null || (Std.is(newValue, Bool) && newValue == false)) {
          el.removeAttribute(name);
        } else if (Std.is(newValue, Bool) && newValue == true) {
          el.setAttribute(name, name);
        } else {
          el.setAttribute(name, newValue);
        }
    }
  }

  // @todo: come up with a way to do this automatically with the @:html
  //        metadata from blok.core.html.
  static function getHtmlName(name:String) {
    if (name.startsWith('aria')) {
      return 'aria-' + name.substr(4).toLowerCase();
    }
    return name;
  }
    
}
