# Full ExPressions language description

## Table of contents
1. [Data types](#data_types)
    1. [Numbers](#numbers)
    2. [Booleans (and `null`)](#booleans)
    3. [Strings](#strings)
    4. [Arrays](#arrays)
    5. [Objects](#objects)
2. [Operators](#operators)
    1. [Access operators](#access-operators)
    2. [String operators](#string-operators)
    3. [Arithmetic operators (and braces)](#arithmetic-operators)
    4. [Logical operators](#logical-operators)
3. [Function calls](#function-calls)
4. [Special symbols](#special-symbols)
5. [Variable bindings](#variable-bindings)
6. [Extend expressions with new functions](#extend)
7. [Standard library functions](#std)
8. [Errors handling](#errors)

## Data types <a name="data_types"></a>
Language has support for all JSON data types:
### Numbers <a name="numbers"></a>
Integers and floats:
```elixir
iex> ExPression.eval("1")
{:ok, 1}
iex> ExPression.eval("1.01")
{:ok, 1.01}
iex> ExPression.eval("1e-3")
{:ok, 0.001}
```

### Booleans (and `null`) <a name="booleans"></a>
```elixir
iex> ExPression.eval("true")
{:ok, true}
iex> ExPression.eval("false")
{:ok, false}
iex> ExPression.eval("null")
{:ok, nil}
```

### Strings <a name="strings"></a>
```elixir
iex> ExPression.eval(~s("Hello, World!"))
{:ok, "Hello, World!"}
iex> ExPression.eval(~s("Привет, мир!"))
{:ok, "Привет, мир!"}
```

### Arrays <a name="arrays"></a>
```elixir
iex> ExPression.eval("[1, [2, 3]]")
{:ok, [1, [2, 3]]}
```
### Objects <a name="objects"></a>
```elixir
iex> ExPression.eval(~s({"en": "England", "fr": "France"}))
{:ok, %{"en" => "England", "fr" => "France"}}
```
#### Note:
Functions in expressions can return any of `Elixir` types:
```elixir
defmodule MyFunctions do
  def new_date(y, m, d), do: Date.new(y, m, d)
end

iex> ExPression.eval("new_date(2024, 1, 1)", functions_module: MyFunctions)
{:ok, ~D[2022-01-30]}
```

## Operators <a name="operators"></a>

### Access operators <a name="access-operators"></a>
1. Access object's field value using dot syntax:
```elixir
iex> ExPression.eval(~s({"en": "England", "fr": "France"}.fr))
{:ok, "France"}
```
2. Access object's field value with braces (in braces can be any expression):
```elixir
iex> ExPression.eval(~s({"en": "England", "fr": "France"}["fr"]))
{:ok, "France"}
```
3. Access array's element by index:
```elixir
iex> ExPression.eval(~s([1, 2, 3][0]))
{:ok, 1}
```

### String operators <a name="string-operators"></a>
`+` (concatenation):
```elixir
iex> ExPression.eval(~s("abc" + "def"))
{:ok, "abcdef"}
```

### Arithmetic operators (and braces) <a name="arithmetic-operators"></a>
`+`, `-`, `*`, `/`:
```elixir
iex> ExPression.eval("1 + 2 * (3 + 4) / 5")
{:ok, 3.8}
```
Braces are supported in general, not only for arithemtic operators, but here is an example.

### Logical operators <a name="logical-operators"></a>
`and`, `or`, `not`, `==`, `!=`, `<`, `<=`, `>`, `>=`:
```elixir
iex> ExPression.eval("not (1 == 2) or false")
{:ok, true}
```
Operators follow `python` semantics:
```elixir
iex> ExPression.eval(~s(0 or "" or [] or [1, 2]))
{:ok, [1, 2]}
iex> ExPression.eval(~s([] < [1, 2] and "12" < "123"))
{:ok, true}
```

## Function calls <a name="function-calls"></a>
Familiar syntax for function calls with [standard library of functions](#std).
```elixir
iex> ExPression.eval("min(1, 2)")
{:ok, 1}
```

## Special symbols <a name="special-symbols"></a>
Language supports special symbols (`$`) for most frequent operations in your domain field:
```elixir
defmodule MyFunctions do
  # use $ special symbol in expressions
  def handle_special("$", date_str), do: Date.from_iso8601!(date_str)
  # Use diff function in expressions
  def diff(date_1, date_2), do: Date.diff(date_1, date_2)
end

iex> ExPression.eval(~s/diff($"2023-02-02", $"2022-02-02")/, functions_module: MyFunctions)
{:ok, 365}
```
Special symbol can be followed by an identifier (`$i_am_special`) or a string (`$"I am special!"`).
To use special symbols, you have to provide `functions_module` and define a function `handle_special(symbol, value)`.
Return value of the function will be used in expression.

## Variable bindings <a name="variable-bindings"></a>
Pass variables to expressions using `:bindings` option:
```elixir
iex> ExPression.eval(~s({"en": "England", "fr": "France"}[country_code]), bindings: %{"country_code" => "en"})
{:ok, "England"}
```

## Extend expressions with new functions <a name="extend"></a>
Define functions that you want to allow your user to use in expressions in some module, then pass this module with `:functions_module` option:
```elixir
defmodule MyFunctions do
  # Use my_sum function in expressions
  def my_sum(a, b), do: a + b
end

iex> ExPression.eval("my_sum(1, 2)", functions_module: MyFunctions)
{:ok, 3}
```
In case your function and function from ExPression's standard library have the same name and arity, your function will be called.

## Standard library functions <a name="std"></a>
Functions have same names and signatures as `python`'s builtins.

| Function | Argument types  | Description  |
|---|---|---|
| `len(term)` | `term` can be `string` or `array` or `object` | Return the length (the number of items) of an object |
| `abs(term)` | `number` | Returns the absolute value of a number |
| `str(term)` | `term` can be any of ExPression types | In case of `string` does nothing, in other cases - returns string representation of data |
| `int(term)` | `term` can be `number` or `string` | truncates number to integer |
| `round(number)` | `number` | rounds number to an integer |
| `round(number, precision)` | `number` | rounds number with given `precision` |
| `min(array)` | `array` | returns minimum of an array, raises `Enum.EmptyError` in case of empty array |
| `min(a, b)` | `a` and `b` can be any comparable types | returns minimum of `a` and `b` |
| `max(array)` | `array` | returns maximum of an array, raises `Enum.EmptyError` in case of empty array |
| `max(a, b)` | `a` and `b` can be any comparable types | returns maximum of `a` and `b` |
| `pow(base, exponent)` | `base` and `exponent` have to be `numbers` (integer or floating point) | returns `a` to the power of `b`. If both are integers - result is `integer`. Otherwise - `floating point` |

## Errors handling <a name="errors"></a>
In case of expected error, functions will return `{:error, error}` tuple, where `error` is a structure `%ExPression.Error{}`. In unexpected cases functions may raise an exception.
Here is a list of types of possible errors:
* `UndefinedVariableError` - when variable, that is used in expressions, was not found in `bindings` map.
* `UndefinedFunctionError` - when function, that is used in expressions, was not found in `functions_module` and standard library.
* `FunctionCallException` - when function, called in expression, raised an exception.
* `BadOperationArgumentTypes` - invalid types of arguments for operation (for example, `1 + "str"`).
* `SpecialWithoutModule` - when special symbol is used in expression, but module `:functions_module` was not provided.