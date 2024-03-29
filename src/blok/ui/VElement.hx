package blok.ui;

import js.Browser;
import js.html.Node;
import blok.core.UniqueId;
import blok.html.HtmlBaseProps;

class VElement<Attrs:{}> implements VNode {
  public static inline final SVG_NS = 'http://www.w3.org/2000/svg';
  static var types:Map<String, WidgetType> = [];

  public static function getTypeForNode(node:Node) {
    var tag = node.nodeName.toLowerCase();
    if (!types.exists(tag)) {
      types.set(tag, new UniqueId());
    }
    return types.get(tag);
  }

  public static function create<Attrs:{}>(tag:String, props):VElement<Attrs> {
    if (!types.exists(tag)) {
      types.set(tag, new UniqueId());
    }
    var isSvg = false;
    var realTag = switch tag.split(':') {
      case ['svg', name]: 
        isSvg = true;
        name;
      default:
        tag;
    }
    return new VElement(types.get(tag), realTag, props, isSvg);
  }

  public final key:Key;
  public final type:WidgetType;
  public final props:Dynamic;
  public final children:Null<Array<VNode>>;
  public final ref:Null<(node:Node)->Void>;
  public final tag:String;
  public final isSvg:Bool;

  public function new(type, tag, props:HtmlChildrenProps<Attrs, Node>, isSvg) {
    this.type = type;
    this.tag = tag;
    this.isSvg = isSvg;
    this.props = props.attrs;
    this.children = props.children;
    this.ref = props.ref;
    this.key = props.key;
  }

  public function createWidget(?parent:Widget, platform:Platform, effects:Effect):Widget {
    var el = isSvg 
      ? Browser.document.createElementNS(SVG_NS, tag)
      : Browser.document.createElement(tag);
    var native = new ElementWidget(el, type, props, children, ref);
    native.initializeWidget(parent, platform, key);
    native.performUpdate(effects);
    return native;
  }

  public function updateWidget(widget:Widget, effects:Effect):Widget {
    var native:ElementWidget<Attrs> = cast widget;
    native.updateAttrs(props);
    native.setChildren(children);
    native.performUpdate(effects);
    return widget;
  }
}
