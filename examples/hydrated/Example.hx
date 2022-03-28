package hydrated;

import js.Browser;

using Blok;

function main() {
  var data:ObservableResult<String, String> = new ObservableResult(Suspended);
  Platform.hydrate(
    Browser.document.getElementById('root'),
    Simple.node({ content: 'foo' })
    // root -> trace('done')
  );
  data.resume('Custom!');
}

// class AsyncLoading extends Component {
//   @prop var message:String;
//   @prop var content:ObservableResult<String, String>;
//   var times:Int = 0;

//   @update
//   function changeMessage() {
//     return { message: 'Changed ${times++}.' };
//   }

//   function render() {
//     return ResultHandler.node({
//       result: content,
//       loading: () -> Html.text('loading...'),
//       error: e -> Html.text(e),
//       build: data -> Html.div({}, 
//         Html.text(message),
//         Simple.node({ content: data }),
//         Html.button({
//           onclick: _ -> changeMessage()
//         }, Html.text('Change'))
//       )
//     });
//   }
// }

class Simple extends Component {
  @prop var content:String;
  var times:Int = 1;

  @update
  function changeContent() {
    return { content: 'Changed ${times++}.' };
  }

  function render() {
    return Html.div({}, 
      Html.text(content),
      Html.button({
        onclick: _ -> changeContent()
      }, Html.text('Change'))
    );
  }
}
