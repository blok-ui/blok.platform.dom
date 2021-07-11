package blok.dom;

import js.html.Node;
import blok.exception.*;

class DomTools {
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

  // public static function findNodeClosestToComponent(component:Component) {
  //   if (component.__parent == null) return null;

  //   var parent = component.__parent;
  //   var pos = parent.getChildPosition(component);
  //   var before = parent.getChildren().slice(0, pos);
    
  //   if (before.length == 0) {
  //     return findNodeClosestToComponent(parent);
  //   }

  //   var nodes = getNodesFromComponents(before);
    
  //   if (nodes.length == 0) {
  //     return findNodeClosestToComponent(before[before.length - 1]);
  //   }

  //   return nodes[nodes.length - 1];
  // }

  public static function setChildren(
    previousCount:Int,
    cursor:Cursor,
    nodes:Array<Node>,
    parent:Component
  ) {
    try {
      var insertedCount = 0;
      var currentCount = 0;

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
}