Blok Platform DOM
=================

The DOM Platform for Blok.

Getting Started 
---------------

Install using [Lix](https://github.com/lix-pm):

`lix install gh:blok-ui/blok.platform.dom`

Install using haxelib:

> Not available yet

Once you've installed Blok (and added it as a library in your hxml), you can quickly import everything you need with `using Blok`. Take a look at the [TodoMVC example](examples/todomvc/TodoMvc.hx) if you want to get a good idea of how Blok works (especially how it handles state, services and more complex concepts), but an extremely simple Hello World will look like this:

```haxe
import blok.dom.Platform;

using Blok;

class Greeter extends Component {
  @prop var greeting:String = 'Hello';
  @prop var location:String = 'World';

  function render() {
    return Html.div({
      className: 'hello-world'
    }, Html.text(greeting + ' ' + location));
  }
}

function main() {
  Platform.mount(
    js.Browser.document.getElementById('root'),
    Greeter.node({
      greeting: 'Hello',
      location: 'world'
    })
  );
}

```

Include this in an HTML file with an element that has an id of `root` (like the [TodoMVC example does](dist/todomvc/index.html)) and you're good to go!
