package blok;

import js.html.Node;

@:allow(blok.NodeType)
@component(dontGenerateType)
class NativeComponent<Attrs> extends Component {
  @prop var attributes:Attrs = null;
  @prop var children:Array<VNode> = [];
  public final node:Node;
  final ref:Null<(node:Node)->Void>;
  final shouldUpdate:Bool;

  public function new(node, props, ?ref, shouldUpdate = true) {
    this.node = node;
    this.ref = ref;
    this.shouldUpdate = shouldUpdate;
    __initComponentProps(props);
  }
  
  @effect
  function handleRef() {
    if (ref != null) ref(node);
  }

  @dispose
  function removeNode() {
    if (__parent is NativeComponent) {
      return;
    }
    if (node.parentNode != null) {
      trace('removing manually');
      node.parentNode.removeChild(node);
    }
  }

  override function shouldComponentUpdate():Bool {
    return shouldUpdate;
  }

  public function isComponentType(type:ComponentType<Dynamic, Dynamic>) {
    return switch Std.downcast(type, NodeType) {
      case null: false;
      case type:
        return node.nodeName.toLowerCase() == type.tag;
    }
  }

  public function render():VNode {
    return if (children.length > 0) VFragment(children) else VNone;
  }
}
