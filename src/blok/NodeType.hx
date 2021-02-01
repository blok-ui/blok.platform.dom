package blok;

import haxe.ds.Map;
import js.Browser;
import js.html.Node;
import js.html.Element;
import blok.core.Differ;

class NodeType<Props:{}> {
  public static inline final SVG_NS = 'http://www.w3.org/2000/svg';
  
  static var types:Map<String, NodeType<Dynamic>> = [];

  public static function get<Props:{}>(tag:String):NodeType<Props> {
    if (!types.exists(tag)) switch tag.split(':') {
      case ['svg', name]: types.set(tag, new NodeType(name, true));
      default: types.set(tag, new NodeType(tag));
    }
    return cast types.get(tag);
  }

  public static function updateNodeAttribute(node:Node, name:String, oldValue:Dynamic, newValue:Dynamic):Void {
    var el:Element = cast node;
    var isSvg = el.namespaceURI == SVG_NS;
    switch name {
      case 'className':
        updateNodeAttribute(node, 'class', oldValue, newValue);
      case 'xmlns' if (isSvg): // skip
      case 'value' | 'selected' | 'checked' if (!isSvg):
        js.Syntax.code('{0}[{1}] = {2}', el, name, newValue);
      case _ if (!isSvg && js.Syntax.code('{0} in {1}', name, el)):
        js.Syntax.code('{0}[{1}] = {2}', el, name, newValue);
      default:
        if (name.charAt(0) == 'o' && name.charAt(1) == 'n') {
          var name = name.toLowerCase();
          if (newValue == null) {
            Reflect.setField(el, name, null);
          } else {
            Reflect.setField(el, name, newValue);
          }
          // var ev = key.substr(2).toLowerCase();
          // el.removeEventListener(ev, oldValue);
          // if (newValue != null) el.addEventListener(ev, newValue);
        } else if (newValue == null || (Std.is(newValue, Bool) && newValue == false)) {
          el.removeAttribute(name);
        } else if (Std.is(newValue, Bool) && newValue == true) {
          el.setAttribute(name, name);
        } else {
          el.setAttribute(name, newValue);
        }
    }
  }

  final tag:String;
  final isSvg:Bool;

  public function new(tag, isSvg = false) {
    this.tag = tag;
    this.isSvg = isSvg;
  }
  
  public function create(props:Props, context:Context):Node {
    var node = if (isSvg) 
      Browser.document.createElementNS(SVG_NS, tag);
    else
      Browser.document.createElement(tag);

    Differ.diffObject(
      {}, 
      props, 
      updateNodeAttribute.bind(node)
    );

    return node;
  }

  public function update(node:Node, previousProps:Props, props:Props, context:Context):Node {
    Differ.diffObject(
      previousProps, 
      props, 
      updateNodeAttribute.bind(node)
    );
    return node;
  }

}
