# ExPression
[![Hex Version](https://img.shields.io/hexpm/v/ex_pression.svg)](https://hex.pm/packages/ex_pression)
[![Docs](https://img.shields.io/badge/docs-hexpm-blue.svg)](https://hexdocs.pm/ex_pression)
[![License](https://img.shields.io/hexpm/l/ex_pression.svg)](LICENSE)
[![Coverage Status](https://coveralls.io/repos/github/balance-platform/ex_pression/badge.svg?branch=master)](https://coveralls.io/github/balance-platform/ex_pression?branch=master)

Evaluate user input expressions.

## Installation
The package can be installed by adding `ex_pression` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_pression, "~> 0.4.1"}
  ]
end
```

## Key features
1. **Safe** evaluation without acces to other Elixir modules.
```elixir
iex> ExPression.eval("exit(self())")
{:error, %ExPression.Error{name: "UndefinedFunctionError", message: "Function 'self/0' was referenced, but was not defined", data: %{function: :self}}}
```

2. Support for **JSON** syntax and data types.
```elixir
iex> ExPression.eval("""
{
  "name": "ex_pression",
  "deps": ["xpeg"]
}
""")
{:ok, %{"name" => "ex_pression", "deps" => ["xpeg"]}}
```

3. Familiar **python**-like operators and standard functions.
```elixir
iex> ExPression.eval(~s/{"1": "en", "2": "fr"}[str(int_code)]/, bindings: %{"int_code" => 1})
{:ok, "en"}
```

4. **Extend** expressions by providing Elixir module with functions that you want to use.
```elixir
defmodule MyFunctions do
  # use $ special symbol in expressions
  def handle_special("$", date_str), do: Date.from_iso8601!(date_str)
  # Use diff function in expresions
  def diff(date_1, date_2), do: Date.diff(date_1, date_2)
end

iex> ExPression.eval(~s/diff($"2023-02-02", $"2022-02-02")/, functions_module: MyFunctions)
{:ok, 365}
```

Full language description can be found in [FULL_DESCRIPTION.md](./FULL_DESCRIPTION.md)

## Implementation
String representation of expression is parsed into AST form. Parsing is done with PEG grammar parser [xpeg](https://github.com/zevv/xpeg). Grammar is defined in module `ExPression.Parser.Grammar`.
AST interpretation logic is written in plain `Elixir` in module `ExPression.Interpreter`.

## Contribution
Feel free to make a pull request. All contributions are appreciated!
