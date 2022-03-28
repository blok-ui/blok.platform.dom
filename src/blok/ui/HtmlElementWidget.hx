package blok.ui;

import js.Browser;
import js.html.Node;
import blok.core.UniqueId;
import blok.core.ObjectTools;
import blok.html.HtmlBaseProps;

class HtmlElementWidget<Attrs:{}> extends ObjectWidget {
  static final types:Map<String, UniqueId> = [];

  public static function create<Attrs:{}>(tag:String, props):HtmlElementWidget<Attrs> {
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
    return new HtmlElementWidget(types.get(tag), realTag, props, isSvg);
  }

  final type:UniqueId;
  public final tag:String;
  public final attrs:Dynamic;
  final children:Null<Array<Widget>>;
  final isSvg:Bool;
  public final ref:Null<(node:Node)->Void>;

  public function new(type, tag, props:HtmlChildrenProps<Attrs, Node>, isSvg) {
    super(props.key);
    this.type = type;
    this.tag = tag;
    this.attrs = props.attrs;
    this.children = props.children;
    this.ref = props.ref;
    this.isSvg = isSvg;
  }

  public function getWidgetType():UniqueId {
    return type;
  }

  public function createElement():Element {
    return new HtmlElementElement(this);
  }

  public function getChildren():Array<Widget> {
    return children == null ? [] : children;
  }

  public function createObject():Dynamic {
    var el = isSvg 
      ? Browser.document.createElementNS(Svg.NAMESPACE, tag)
      : Browser.document.createElement(tag);
    updateObject(el);
    return el;
  }

  public function updateObject(object:Dynamic, ?previousWidget:Widget):Dynamic {
    var el:js.html.Element = object;
    var oldAttrs = previousWidget == null ? {} : (cast previousWidget:HtmlElementWidget<Dynamic>).attrs;
    
    ObjectTools.diffObject(oldAttrs, attrs, HtmlTools.updateNodeAttribute.bind(el));

    return el;
  }
}

class HtmlElementElement extends ObjectWithChildrenElement {
  override function performBuild(previousWidget:Null<Widget>) {
    super.performBuild(previousWidget);
    maybeHandleRef();
  }

  override function performHydrate(cursor:HydrationCursor) {
    super.performHydrate(cursor);
    maybeHandleRef();
  }

  inline function maybeHandleRef() {
    var el:HtmlElementWidget<Dynamic> = cast widget;
    if (el.ref != null) platform.scheduleEffects(effects -> {
      effects.register(() -> el.ref(getObject()));
    });
  }
}
