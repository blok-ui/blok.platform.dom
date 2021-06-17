package blok;

import js.Browser;
import js.html.Node;
import blok.VNodeType.getUniqueTypeId;
import blok.core.html.HtmlBaseProps;
import blok.tools.ObjectTools;
import blok.dom.DomTools;

class VNative<Attrs:{}> implements VNode {
  public static inline final SVG_NS = 'http://www.w3.org/2000/svg';
  static var types:Map<String, VNodeType> = [];

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

  public function createComponent(?parent:Component):Component {
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
      DomTools.updateNodeAttribute.bind(native.node)
    );
    native.initializeComponent(parent, key);
    native.renderComponent();
    return native;
  }

  public function updateComponent(component:Component):Component {
    var native:NativeComponent<Attrs> = cast component;
    ObjectTools.diffObject(
      native.attributes,
      props.attrs,
      DomTools.updateNodeAttribute.bind(native.node)
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
