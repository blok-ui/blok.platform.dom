package blok;

import js.html.Node;

using blok.dom.DomTools;
using blok.dom.Cursor;

@component(dontGenerateType)
class NativeComponent<Attrs:{}> extends Component {
  @prop public var attributes:Attrs = null;
  @prop var children:Array<VNode> = [];
  public final node:Node;
  final type:VNodeType;
  final ref:Null<(node:Node)->Void>;
  final shouldUpdate:Bool;
  var previous:Attrs;

  public function new(type, node, props, ?ref, shouldUpdate = true) {
    this.node = node;
    this.ref = ref;
    this.type = type;
    this.shouldUpdate = shouldUpdate;
    __initComponentProps(props);
  }
  
  @effect
  function handleRef() {
    if (ref != null) ref(node);
  }

  override function shouldComponentUpdate():Bool {
    return shouldUpdate;
  }

  function getComponentType():VNodeType {
    return type;
  }

  public function render():VNode {
    return if (children != null && children.length > 0) 
      new VFragment(children) 
    else
      VFragment.empty();
  }

  override function __ensureVNode(vn:Null<VNode>):VNode {
    // No placeholders needed for NativeComponents.
    return if (vn == null) VFragment.empty() else vn;
  }
}
