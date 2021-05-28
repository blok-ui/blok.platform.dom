package blok;

import js.html.Text;
import blok.VNodeType.getUniqueTypeId;

private final textType = getUniqueTypeId(); 

class VText implements VNode {
  public final type = textType;
  public final key:Null<Key>;
  public final props:{ content:String };
  public final children:Null<Array<VNode>> = null;

  public function new(props:{ content:String }, ?key) {
    this.props = props;
    this.key = key;
  }

  public function createComponent():Component {
    return new NativeComponent(type, new Text(props.content), {}, null, false);
  }

  public function updateComponent(component:Component) {
    var native:NativeComponent<{}> = cast component;
    if (props.content != native.node.textContent) native.node.textContent = props.content;
    return native;
  }
}
