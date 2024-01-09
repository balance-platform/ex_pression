# ExPression
Define and eval expressions in runtime in your Elixir project.

## Claims
* JSON support - expressions support all JSON types with it's stanrad syntax
```elixir
iex> ExPression.eval(~s({"a": [1, 2, 3]}[a][b]), bindings: %{"a" => "a", "b" => 2})
{:ok, 3}
```
* Python-like operators and standard functions
```elixir
iex> ExPression.eval("not true or false or 1 == 1")
{:ok, true}
```
* Extend expressions by providing Elixir module with functions that you want to use.
```elixir
iex> ExPression.eval("div(x, y)", bindings: %{"x" => 5, "y" => 2}, functions_module: Kernel)
{:ok, 2}
```
* Safe evaluation without acces to other Elixir modules.

## Features list
- [x] JSON data types
  - [x] Integer
  - [x] Float
  - [x] String
  - [x] Array
  - [x] Object
- [x] Standrad library of functions
- [x] Variables bindings
- [x] Extending by providing modules with functions
- [x] Boolean Operators
  - [x] and, or, not
  - [x] ==, !=, <, <=, >, >=
- [x] Math Operators
  - [x] +, -, *, /
  - [ ] ** (power operator)
- [x] Access Operators
  - [x] Field access (`obj.field_name`)
  - [x] Access array element by index (`[1, 2, 3][0]`)
  - [x] Access object field in runtime (`{"fr": "France", "en": "England"}[country]`)
- [x] Error handling
  - [x] Syntax errors 
  - [x] Runtime errors
- [ ] AST Validations
  - [ ] Calling non existing functions
  - [ ] Invalid data types

## Contribution
Feel free to make a pull request. All contributions are appreciated!
