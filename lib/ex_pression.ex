defmodule ExPression do
  @moduledoc """
  Define and evaluate expressions in runtime in your Elixir project.

  ## Features
  * JSON support - expressions support all JSON types with it's stanrad syntax
  * Python-like operators and standard functions
  * Extend expressions by providing Elixir module with functions that you want to use.
  * Safe evaluation without acces to other Elixir modules.
  """
  alias ExPression.Interpreting
  alias ExPression.Parsing

  @type ast() :: any()

  @doc """
  Parse expression in string format into AST format.

  This can be used for optimizations: to parse expression once and evaluate AST many times.
  """
  @spec parse(binary()) :: {:ok, ast()} | {:error, :parsing_error}
  def parse(expression_str) when is_binary(expression_str) do
    Parsing.parse(expression_str)
  end

  @doc """
  Evalate expression in string or AST format.

  ## Options
  * `:bindings` - map variable names and values.
  * `:functions_module` - module with functions that will be accessible from expressions.

  ## Examples
  iex> eval("1 + 0.5")
  {:ok, 1.5}
  iex> eval("div(x, y)", bindings: %{"x" => 5, "y" => 2}, functions_module: Kernel)
  {:ok, 2}
  iex> eval(~s({"a": [1, 2, 3]}[a][b]), bindings: %{"a" => "a", "b" => 2})
  {:ok, 3}
  iex> eval("not true or false or 1 == 1")
  {:ok, true}
  """
  @spec eval(binary() | ast(), Keyword.t()) :: {:ok, any()} | {:error, any()}
  def eval(str_or_ast, opts \\ [])

  def eval(expression_str, opts) when is_binary(expression_str) do
    case parse(expression_str) do
      {:ok, ast} -> eval(ast, opts)
      error -> error
    end
  end

  def eval(ast, opts) do
    bindings = Keyword.get(opts, :bindings, %{})
    functions_module = Keyword.get(opts, :functions_module)
    Interpreting.eval(ast, bindings, functions_module)
  end
end
