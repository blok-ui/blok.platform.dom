package hydrated;

import js.Browser;

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
      Html.button({
        onclick: _ -> changeMessage()
      }, Html.text('Change'))
    );
  }
}
