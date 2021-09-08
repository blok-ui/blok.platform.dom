package hydrated;

import js.Browser;
import blok.dom.Hydrator.createChildren;

using Blok;

function main() {
  Platform.hydrate(
    Browser.document.getElementById('root'),
    Simple.node({ message: 'Ok.' })
  );
}

class Simple extends Component {
  @prop var message:String;
  var times:Int = 0;

  @update
  function changeMessage() {
    return UpdateState({
      message: 'Changed ${times++}.'
    });
  }

  function render() {
    return Html.div({}, 
      Html.text(message),
      CustomHydration.node({ content: 'Custom!' }),
      Html.button({
        onclick: _ -> changeMessage()
      }, Html.text('Change'))
    );
  }
}

class CustomHydration extends Component implements Hydratable {
  @prop var content:String;

  #if blok.platform.dom
    public function hydrate(node:js.html.Node, registerEffect:(effect:()->Void)->Void) {
      trace('This is a custom hydrator!');
      trace('It doesn\'t do anything special, but you can see how it might be used.');
      createChildren(
        this,
        __performRender().toArray(),
        cast getPlatform(),
        node,
        registerEffect
      );
    }
  #end
  
  function render() {
    return Html.div({}, Html.text(content));
  }
}
