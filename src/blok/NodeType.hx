// package blok;

// import blok.dom.DomTools;
// import haxe.ds.Map;
// import js.Browser;
// import js.html.Node;
// import blok.tools.ObjectTools;
// import blok.core.html.HtmlBaseProps;

// class NodeType<Attrs:{}> {
//   public static inline final SVG_NS = 'http://www.w3.org/2000/svg';
//   static var types:Map<String, NodeType<Dynamic>> = [];

//   public static function get<Props:{}>(tag:String):NodeType<Props> {
//     if (!types.exists(tag)) switch tag.split(':') {
//       case ['svg', name]: types.set(tag, new NodeType(name, true));
//       default: types.set(tag, new NodeType(tag));
//     }
//     return cast types.get(tag);
//   }

//   public final tag:String;
//   public final isSvg:Bool;

//   public function new(tag, isSvg = false) {
//     this.tag = tag;
//     this.isSvg = isSvg;
//   }

//   public function create(props:HtmlChildrenProps<Attrs, Node>) {
//     var node = isSvg 
//       ? Browser.document.createElementNS(SVG_NS, tag)
//       : Browser.document.createElement(tag);
    
//     var component = new NativeComponent(node, {
//       attributes: props.attrs,
//       children: props.children 
//     }, props.ref);
//     ObjectTools.diffObject(
//       {},
//       props.attrs, 
//       DomTools.updateNodeAttribute.bind(component.node)
//     );
    
//     return component;
//   }

//   public function update(component:NativeComponent<Attrs>, props:HtmlChildrenProps<Attrs, Node>) {
//     ObjectTools.diffObject(
//       component.attributes,
//       props.attrs, 
//       DomTools.updateNodeAttribute.bind(component.node)
//     );
//     component.updateComponentProperties({
//       attributes: props.attrs,
//       children: props.children == null ? [] : props.children
//     });
//   }
// }
