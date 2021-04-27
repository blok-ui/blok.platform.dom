package blok;

import haxe.ds.Map;
import js.Browser;
import js.html.Node;
import blok.core.ObjectTools;

class NodeType<Attrs:{}> {
  static var types:Map<String, NodeType<Dynamic>> = [];

  public static function get<Props:{}>(tag:String):NodeType<Props> {
    if (!types.exists(tag)) { 
      types.set(tag, new NodeType(tag));
    }
    return cast types.get(tag);
  }

  public static function updateNodeAttribute(node:Node, name:String, oldValue:Dynamic, newValue:Dynamic):Void {
    var el:js.html.Element = cast node;
    switch name {
      case 'className':
        updateNodeAttribute(node, 'class', oldValue, newValue);
      case 'value' | 'selected' | 'checked':
        js.Syntax.code('{0}[{1}] = {2}', el, name, newValue);
      case _ if (js.Syntax.code('{0} in {1}', name, el)):
        js.Syntax.code('{0}[{1}] = {2}', el, name, newValue);
      default:
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

  final tag:String;
  final isSvg:Bool;

  public function new(tag, isSvg = false) {
    this.tag = tag;
    this.isSvg = isSvg;
  }

  public function create(props:{
    attrs:Attrs,
    ?children:Array<VNode>,
    ?ref:(node:Node)->Void
  }) {
    var node = isSvg 
      ? Browser.document.createElementNS('', tag) // todo
      : Browser.document.createElement(tag);
    
    var component = new NativeComponent(node, {
      attributes: props.attrs,
      children: props.children 
    }, props.ref);
    ObjectTools.diffObject(
      {},
      props.attrs, 
      updateNodeAttribute.bind(component.node)
    );
    
    return component;
  }

  public function update(component:NativeComponent<Attrs>, props:{
    attrs:Attrs,
    ?children:Array<VNode>,
    ?ref:(node:Node)->Void
  }) {
    ObjectTools.diffObject(
      component.attributes,
      props.attrs, 
      updateNodeAttribute.bind(component.node)
    );
    component.updateComponentProperties({
      attributes: props.attrs,
      children: props.children == null ? [] : props.children
    });
  }
}
