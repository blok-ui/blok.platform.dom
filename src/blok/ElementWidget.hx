package blok;

import js.html.Node;
import js.html.Element;
import blok.tools.ObjectTools;

class ElementWidget<Attrs:{}> extends ConcreteWidget {
  final el:Element;
  final type:WidgetType;
  final ref:Null<(node:Node)->Void>;
  var attrs:Attrs;
  var children:Array<VNode>;

  public function new(el, type, attrs, children, ?ref) {
    this.el = el;
    this.type = type;
    this.attrs = attrs;
    this.children = children;
    this.ref = ref;
  }

  public function __performUpdate(registerEffect:(effect:()->Void)->Void):Void {
    if (ref != null) registerEffect(ref.bind(el));
    Differ.diffChildren(this, children, __platform, registerEffect);
  }

  override function __initHooks() {
    ObjectTools.diffObject(
      {},
      attrs,
      updateNodeAttribute.bind(el)
    );
  }

  public function setChildren(newChildren:Array<VNode>) {
    __status = WidgetInvalid;
    children = newChildren;
  }

  public function updateAttrs(attrs:Attrs) {
    var changed = ObjectTools.diffObject(
      this.attrs,
      attrs,
      updateNodeAttribute.bind(el)
    );
    if (changed > 0) {
      __status = WidgetInvalid;
      this.attrs = attrs;
    }
  }

  public function getWidgetType() {
    return type;
  }
  
  public function toConcrete() {
    return [ el ];
  }

  public function getFirstConcreteChild() {
    return el;
  }

  public function getLastConcreteChild() {
    return el;
  }

  override function dispose() {
    for (child in getChildren()) removeConcreteChild(child);
    super.dispose();
  }

  public function addConcreteChild(childWidget:Widget) {
    var children:Array<Node> = cast childWidget.getConcreteManager().toConcrete();
    el.append(...children);
  }

  public function insertConcreteChildAt(pos:Int, childWidget:Widget) {
    var children:Array<Node> = cast childWidget.getConcreteManager().toConcrete();
    
    if (pos == 0) {
      el.prepend(...children);
      return;
    }

    var previousWidget = getChildAt(pos - 1);

    if (previousWidget == null) {
      el.append(...children);
      return;
    }

    var previousElement:Element = previousWidget
      .getConcreteManager()
      .getLastConcreteChild();
      
    if (previousElement == null) {
      throw 'We may need to rethink this';
    }

    previousElement.after(...children);
  }

  public function moveConcreteChildTo(pos:Int, widget:Widget) {
    insertConcreteChildAt(pos, widget);
  }

  public function removeConcreteChild(widget:Widget) {
    var els:Array<Element> = cast widget.getConcreteManager().toConcrete();
    for (child in els) child.remove();
  }
}

private function updateNodeAttribute(el:Element, name:String, oldValue:Dynamic, newValue:Dynamic):Void {
  var isSvg = el.namespaceURI == VElement.SVG_NS;
  switch name {
    case 'ref' | 'key': 
      // noop
    case 'className':
      updateNodeAttribute(el, 'class', oldValue, newValue);
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
