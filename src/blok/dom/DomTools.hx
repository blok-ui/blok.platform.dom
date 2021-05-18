package blok.dom;

import js.html.Node;
import js.html.Element;
import blok.exception.*;

class DomTools {
  public static function setChildren(
    previousCount:Int,
    cursor:Cursor,
    children:Array<Component>,
    parent:Component
  ) {
    try {
      var insertedCount = 0;
      var currentCount = 0;
      var nodes = getNodesFromComponents(children);

      for (node in nodes) {
        currentCount++;
        if (node == cursor.current()) cursor.step();
        else if (cursor.insert(node)) insertedCount++;
      }

      var deleteCount = previousCount + insertedCount - currentCount;
      
      for (i in 0...deleteCount) {
        if (!cursor.delete()) break;
      }
    } catch (e:BlokException) {
      throw e;
    } catch (e) {
      throw new WrappedException(e, parent);
    }
  }

  public static function getNodesFromComponents(children:Array<Component>) {
    var nodes:Array<Node> = [];
    for (child in children) switch Std.downcast(child, NativeComponent) {
      case null: 
        nodes = nodes.concat(getNodesFromComponents(child.__children));
      case native:
        nodes.push(native.node);
    }
    return nodes;
  }

  public static function updateNodeAttribute(node:Node, name:String, oldValue:Dynamic, newValue:Dynamic):Void {
    var el:Element = cast node;
    var isSvg = el.namespaceURI == NodeType.SVG_NS;
    switch name {
      case 'className':
        updateNodeAttribute(node, 'class', oldValue, newValue);
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
}