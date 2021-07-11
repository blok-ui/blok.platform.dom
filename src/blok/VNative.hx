package blok;

import js.Browser;
import js.html.Node;
import js.html.Element;
import blok.VNodeType.getUniqueTypeId;
import blok.core.html.HtmlBaseProps;
import blok.tools.ObjectTools;

class VNative<Attrs:{}> implements VNode {
  public static inline final SVG_NS = 'http://www.w3.org/2000/svg';
  static var types:Map<String, VNodeType> = [];

  public static function updateNodeAttribute(node:Node, name:String, oldValue:Dynamic, newValue:Dynamic):Void {
    var el:Element = cast node;
    var isSvg = el.namespaceURI == VNative.SVG_NS;
    switch name {
      case 'ref' | 'key': 
        // noop
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

  public static function getTypeForNode(node:Node) {
    var tag = node.nodeName.toLowerCase();
    if (!types.exists(tag)) {
      types.set(tag, getUniqueTypeId());
    }
    return types.get(tag);
  }

  public static function create<Attrs:{}>(tag:String, props):VNative<Attrs> {
    if (!types.exists(tag)) {
      types.set(tag, getUniqueTypeId());
    }
    var isSvg = false;
    var realTag = switch tag.split(':') {
      case ['svg', name]: 
        isSvg = true;
        name;
      default:
        tag;
    }
    return new VNative(types.get(tag), realTag, props, isSvg);
  }

  public final key:Key;
  public final type:VNodeType;
  public final props:HtmlChildrenProps<Attrs, Node>;
  public final children:Null<Array<VNode>> = null;
  final isSvg:Bool;
  final tag:String;

  public function new(type, tag, props, isSvg) {
    this.type = type;
    this.tag = tag;
    this.props = props;
    this.isSvg = isSvg;
    this.key = props.key;
  }

  public function createComponent(engine:Engine, ?parent:Component):Component {
    var node = isSvg 
      ? Browser.document.createElementNS(SVG_NS, tag)
      : Browser.document.createElement(tag);
    
    var native = new NativeComponent(type, node, {
      attributes: props.attrs,
      children: props.children
    }, props.ref);
    ObjectTools.diffObject(
      {},
      props.attrs,
      updateNodeAttribute.bind(native.node)
    );
    native.initializeComponent(parent, engine, key);
    native.renderComponent();
    return native;
  }

  public function updateComponent(engine:Engine, component:Component):Component {
    var native:NativeComponent<Attrs> = cast component;
    ObjectTools.diffObject(
      native.attributes,
      props.attrs,
      updateNodeAttribute.bind(native.node)
    );
    native.updateComponentProperties({
      attributes: props.attrs,
      children: props.children
    });
    if (native.shouldComponentRender()) {
      native.renderComponent();
    }
    return native;
  }
}
