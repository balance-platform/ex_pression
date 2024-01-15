# ExPression
[![Hex Version](https://img.shields.io/hexpm/v/ex_pression.svg)](https://hex.pm/packages/ex_pression)
[![Docs](https://img.shields.io/badge/docs-hexpm-blue.svg)](https://hexdocs.pm/ex_pression)
[![License](https://img.shields.io/hexpm/l/ex_pression.svg)](LICENSE)
[![Coverage Status](https://coveralls.io/repos/github/balance-platform/ex_pression/badge.svg?branch=master)](https://coveralls.io/github/balance-platform/ex_pression?branch=master)

Eval user input expressions in your Elixir project.

## Installation
The package can be installed by adding `ex_pression` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_pression, "~> 0.3.1"}
  ]
end
```

## SAFE
Safe evaluation without acces to other Elixir modules.
```elixir
ExPression.eval("exit(self())")
{:error, %ExPression.Error{name: "UndefinedFunctionError", message: "Function 'self/0' was referenced, but was not defined", data: %{function: :self}}}
```

## JSON
Support for JSON syntax and data types.
```elixir
iex> ExPression.eval("""
{
  "name": "ex_pression",
  "deps": ["xpeg"]
}
""")
{:ok, %{"name" => "ex_pression", "deps" => ["xpeg"]}}
```

## PYTHON
Familiar python-like operators and standard functions.
```elixir
iex> ExPression.eval(~s/{"1": "en", "2": "fr"}[str(int_code)]/, bindings: %{"int_code" => 1})
{:ok, "en"}
```

## EXTEND
Extend expressions by providing Elixir module with functions that you want to use.
```elixir
iex> ExPression.eval("div(5, 2)", functions_module: Kernel)
{:ok, 2}
```

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
  - [x] `and`, `or`, `not`
  - [x] `==`, `!=`, `<`, `<=`, `>`, `>=`
- [x] Math Operators
  - [x] `+`, `-`, `*`, `/`
  - [ ] `**` (power operator)
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

## Implementation
String representation of expression is parsed into AST form. Parsing is done with PEG grammar parser [xpeg](https://github.com/zevv/xpeg). Grammar is defined in module `ExPression.Parsing.Grammar`.
AST interpretation logic is written in plain `Elixir` in module `ExPression.Interpreting`.

## Contribution
Feel free to make a pull request. All contributions are appreciated!
