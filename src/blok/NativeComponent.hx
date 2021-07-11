package blok;

// import blok.exception.BlokException;
import js.html.Node;

using blok.dom.DomTools;

@component(dontGenerateType)
class NativeComponent<Attrs:{}> extends Component {
  @prop public var attributes:Attrs = null;
  @prop var children:Array<VNode> = [];
  public final node:Node;
  final type:VNodeType;
  final ref:Null<(node:Node)->Void>;
  final shouldUpdate:Bool;

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

  // @dispose
  // function removeRealNode() {
  //   if (node.parentNode != null) node.parentNode.removeChild(node);
  // }

  override function shouldComponentRender():Bool {
    return shouldUpdate;
  }

  function getComponentType():VNodeType {
    return type;
  }

  public function render() {
    return if (children != null) children else [];
  }

  // override function addChild(component:Component) {
  //   function process(component:Component) {
  //     switch Std.downcast(component, NativeComponent) {
  //       case null:
  //         for (child in component.getChildren()) process(child);
  //       case native:
  //         node.appendChild(native.node);
  //     }
  //   }

  //   super.addChild(component);
  //   process(component);
  // }

  // override function insertChildAt(pos:Int, component:Component) {
  //   function process(component:Component) {
  //     switch Std.downcast(component, NativeComponent) {
  //       case null:
  //         for (child in component.getChildren()) process(child);
  //       case native:
  //         insertRealNodeAt(pos, native);
  //     }
  //   }

  //   process(component);
  //   super.insertChildAt(pos, component);
  // }

  // override function moveChildTo(pos:Int, component:Component) {
  //   function process(component:Component) {
  //     switch Std.downcast(component, NativeComponent) {
  //       case null:
  //         for (child in component.getChildren()) process(child);
  //       case native:
  //         insertRealNodeAt(pos, native);
  //     }
  //   }

  //   process(component);
  //   super.moveChildTo(pos, component);
  // }

  // /**
  //   Interally, blok will pass `replaceChild`, `insertChildBefore` and
  //   `insertChildAfter` to `insertChildAt`, which uses this method. 
  //   In the NativeComponent, `moveComponentTo` will also use this method. 
    
  //   In all cases, we can be assured that the behavior we want is 
  //   to insert the real node _before_ the node closest to `pos`. Note
  //   that we can't be sure that the position of a component matches up
  //   to the position of a real node. Instead, we need to do a little searching
  //   to find the closest one.

  //   This could use some testing.
  // **/
  // function insertRealNodeAt(pos:Int, native:NativeComponent<Dynamic>) {
  //   var child = getChildAt(pos);
  //   if (child == null) {
  //     node.appendChild(native.node);
  //   } else if (child is NativeComponent) {
  //     var prevNative:NativeComponent<Dynamic> = cast child;
  //     node.insertBefore(native.node, prevNative.node);
  //   } else {
  //     var nodes = [ child ].getNodesFromComponents();
  //     var prev = if (nodes.length > 0) {
  //       nodes[nodes.length - 1];
  //     } else {
  //       #if debug
  //         throw new BlokException(
  //           'A placeholder was not created',
  //           this
  //         );
  //       #end
  //       child.findNodeClosestToComponent();
  //     }
  //     node.insertBefore(native.node, prev);
  //   }
  // }
}
