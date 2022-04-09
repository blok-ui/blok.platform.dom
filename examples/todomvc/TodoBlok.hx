package todomvc;

import haxe.Json;
import haxe.ds.ReadOnlyArray;
import js.html.InputElement;

using Blok;
using Reflect;
using Lambda;

function main() {
  Platform.mount(
    js.Browser.document.getElementById('root'),
    App.of({ todos: TodoStore.load() })
  );
}

class Todo implements Record {
  @constant var id:Int;
  @prop var description:String;
  @prop var isCompleted:Bool;
  @prop var isEditing:Bool = false;
}

enum abstract TodoVisibility(String) from String to String {
  var All;
  var Completed;
  var Active;
}

@service(fallback = TodoStore.load())
class TodoStore implements State {
  static inline final BLOK_TODO_STORE = 'blok-todo-store';
  
  public static function load() {
    var data = js.Browser.window.localStorage.getItem(BLOK_TODO_STORE);
    var store = if (data == null) {
      new TodoStore({ uid: 0,  todos: [], visibility: All });
    } else {
      fromJson(Json.parse(data));
    }
    store.getObservable().observe(save);
    return store;
  }

  public static function save(store:TodoStore) {
    js.Browser.window.localStorage.setItem(BLOK_TODO_STORE, Json.stringify(store.toJson()));
  }

  public static function fromJson(data:Dynamic) {
    return new TodoStore({
      uid: data.field('uid'),
      todos: (data.field('todos'):Array<Dynamic>).map(Todo.fromJson),
      visibility: data.field('visibility')
    });
  }

  @prop var uid:Int;
  @prop var todos:ReadOnlyArray<Todo>;
  @prop var visibility:TodoVisibility;

  @memo
  public function getVisibleTodos() {
    var out = todos.filter(todo -> switch visibility {
      case Completed: todo.isCompleted;
      case Active: !todo.isCompleted;
      case All: true;
    });
    out.reverse();
    return out;
  }

  @update
  public function addTodo(description:String) {
    if (description == null) return {};
    return { 
      uid: uid + 1,
      todos: todos.concat([ new Todo({
        id: uid,
        description: description,
        isCompleted: switch visibility {
          case All | Active: false;
          case Completed: true; 
        }
      }) ]) 
    };
  }

  @update
  public function removeTodo(id:Int) {
    return { todos: todos.filter(todo -> todo.id != id) }
  }
  
  @update
  public function setTodoStatus(id:Int, isCompleted:Bool) {
    if (!todos.exists(todo -> todo.id == id)) return {};
    return {
      todos: todos.map(todo -> if (todo.id == id) {
        todo.withIsCompleted(isCompleted);
      } else {
        todo;
      })
    };
  }

  @update
  public function updateTodo(id:Int, description:String) {
    if (!todos.exists(todo -> todo.id == id)) return {};
    return {
      todos: todos.map(todo -> if (todo.id == id) {
        todo.with({
          description: description,
          isEditing: false
        });
      } else {
        todo.withIsEditing(false);
      })
    };
  }

  @update
  public function setEditingTodo(id:Int) {
    if (!todos.exists(todo -> todo.id == id)) return {};
    return {
      todos: todos.map(todo -> if (todo.id == id) {
        todo.withIsEditing(true);
      } else {
        todo.withIsEditing(false);
      })
    };
  }

  @update
  public function clearEditingTodos() {
    return {
      todos: todos.map(todo -> if (todo.isEditing) {
        todo.withIsEditing(false);
      } else {
        todo;
      })
    };
  }

  @update
  public function setAllTodoStatuses(isCompleted:Bool) {
    return {
      todos: todos.map(todo -> todo.withIsCompleted(isCompleted))
    };
  }

  @update
  public function removeCompletedTodos() {
    return {
      todos: todos.filter(todo -> !todo.isCompleted)
    }
  }

  @update
  public function changeVisibility(visibility:TodoVisibility) {
    return { visibility: visibility };
  }

  public function toJson() {
    return {
      uid: uid,
      todos: todos.map(todo -> todo.toJson()),
      visibility: visibility
    };
  }
}

class App extends Component {
  @prop var todos:TodoStore;

  function render() {
    return Provider.provide(todos, context -> Html.div({ className: 'todomvc-wrapper' },
      Html.section({ className: 'todoapp' },
        Html.header({ className: 'header', role: 'header' },
          Html.h1({}, Html.text('todos')),
          TodoInput.of({ 
            className: 'new-todo',
            value: '',
            clearOnComplete: true,
            onCancel: () -> null,
            onSubmit: data -> todos.addTodo(data)
          })
        ),
        TodoStore.observe(context, todos -> TodoContainer.of({
          todos: todos.getVisibleTodos()
        })),
        TodoStore.observe(context, todos -> {
          var todosCompleted = todos.todos.filter(todo -> todo.isCompleted).length;
          var todosLeft = todos.todos.length - todosCompleted;
          return Html.footer({
            className: 'footer',
            style: if (todos.todos.length == 0) 'display: none' else null
          },
            Html.span({ className: 'todo-count' },
              Html.strong({},
                Html.text(switch todosLeft {
                  case 1: '${todosLeft} item left';
                  default: '${todosLeft} items left';
                })
              )
            ),
            Html.ul({ className: 'filters' },
              visibilityControl('#/', All, todos.visibility, todos),
              visibilityControl('#/active', Active, todos.visibility, todos),
              visibilityControl('#/completed', Completed, todos.visibility, todos)
            ),
            Html.button(
              {
                className: 'clear-completed',
                style: if (todosCompleted == 0) 'visibility: hidden' else null,
                onclick: _ -> todos.removeCompletedTodos()
              },
              Html.text('Clear completed (${todosCompleted})') 
            )
          );
        })
      )
    ));
  }

  inline function visibilityControl(
    url:String,
    visibility:TodoVisibility,
    actualVisibility:TodoVisibility,
    todos:TodoStore
  ) {
    return Html.li(
      {
        onclick: _ -> todos.changeVisibility(visibility)
      },
      Html.a(
        {
          href: url,
          className: if (visibility == actualVisibility) 'selected' else null
        },
        Html.text(visibility)
      )
    );
  }
}

class TodoContainer extends Component {
  @prop var todos:ReadOnlyArray<Todo>;

  function render() {
    return Html.section({
      className: 'main',
      ariaHidden: todos.length == 0,
      style: if (todos.length == 0) 'visibility: hidden' else null
    }, 
      // @todo: toggles
      Html.ul({ className: 'todo-list' },
        // Note: using Fragment here entirely to test it.
        //       It is not required, and is even a bad idea,
        //       but I want to make sure it updates correctly.
        Html.fragment(...[ for (todo in todos) 
          TodoView.of({ todo: todo }, todo.id)
        ])
      )
    );
  }
}

@lazy
class TodoInput extends Component {
  @prop var className:String;
  @prop var value:String;
  @prop var clearOnComplete:Bool;
  @prop var onSubmit:(data:String)->Void;
  @prop var onCancel:()->Void;
  @prop var isEditing:Bool = false;
  var ref:js.html.InputElement;

  @update
  function updateValue(value) {
    return { value: value }
  }

  @after
  function maybeFocus() {
    if (isEditing) {
      // @todo: This is clunky, but it ensures we
      //        don't run `focus` until the RootElement
      //        has finished rebuilding. We'll add a
      //        better API soon.
      platform
        .getRootElement()
        .getObservable()
        .next(_ -> ref.focus());
    }
  }

  function render() {
    return Html.input({
      className: className,
      placeholder: 'What needs doing?',
      autofocus: true,
      value: value == null ? '' : value,
      name: className,
      ref: node -> ref = cast node,
      oninput: e -> {
        var target:InputElement = cast e.target;
        updateValue(target.value);
      },
      onblur: _ -> {
        onCancel();
        if (clearOnComplete) updateValue('');
      },
      onkeydown: e -> {
        var ev:js.html.KeyboardEvent = cast e;
        if (ev.key == 'Enter') {
          onSubmit(value);
          if (clearOnComplete) updateValue('');
        } else if (ev.key == 'Escape') {
          onCancel();
          if (clearOnComplete) updateValue('');
        }
      }
    });
  }
}

@lazy
class TodoView extends Component {
  @prop var todo:Todo;
  @use var todos:TodoStore;
  
  inline function getClassName() {
    return [
      if (todo.isCompleted) 'completed' else null,
      if (todo.isEditing) 'editing' else null
    ].filter(c -> c != null).join(' ');
  }

  function render() {
    return Html.li({
      key: todo.id,
      id: 'todo-${todo.id}',
      className: getClassName()
    },
      Html.div({ className: 'view' },
        Html.input({
          className: 'toggle',
          type: Checkbox,
          checked: todo.isCompleted,
          onclick: _ -> todos.setTodoStatus(todo.id, !todo.isCompleted)
        }),
        Html.label({
          ondblclick: _ -> todos.setEditingTodo(todo.id)
        }, Html.text(todo.description)),
        Html.button({
          className: 'destroy',
          onclick: _ ->  todos.removeTodo(todo.id)
        })
      ),
      TodoInput.of({
        className: 'edit',
        value: todo.description,
        clearOnComplete: false,
        isEditing: todo.isEditing,
        onCancel: () -> todos.clearEditingTodos(),
        onSubmit: data -> todos.updateTodo(todo.id, data)
      })
    );
  }
}
