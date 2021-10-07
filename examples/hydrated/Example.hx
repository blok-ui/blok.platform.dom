package hydrated;

import js.Browser;
import blok.dom.Hydrator.hydrateChildren;

using Blok;

function main() {
  var data:ObservableResult<String, String> = new ObservableResult(Suspended);
  Platform.hydrate(
    Browser.document.getElementById('root'),
    Simple.node({ message: 'Ok!', content: data }),
    root -> trace('done')
  );
  data.resume('Custom!');
}

class Simple extends Component {
  @prop var message:String;
  @prop var content:ObservableResult<String, String>;
  var times:Int = 0;

  @update
  function changeMessage() {
    return { message: 'Changed ${times++}.' };
  }

  function render() {
    return ResultHandler.node({
      result: content,
      loading: () -> Html.text('loading...'),
      error: e -> Html.text(e),
      build: data -> Html.div({}, 
        Html.text(message),
        CustomHydration.node({ content: data }),
        Html.button({
          onclick: _ -> changeMessage()
        }, Html.text('Change'))
      )
    });
  }
}

class CustomHydration extends Component implements Hydratable {
  @prop var content:String;

  #if blok.platform.dom
    public function hydrate(node:js.html.Node, registerEffect:(effect:()->Void)->Void, next:()->Void) {
      trace('This is a custom hydrator!');
      trace('It doesn\'t do anything special, but you can see how it might be used.');
      hydrateChildren(
        this,
        __performRender().toArray(),
        getPlatform(),
        node,
        registerEffect,
        next
      );
    }
  #end
  
  function render() {
    return Html.div({}, Html.text(content));
  }
}
