defmodule ExPression do
  @moduledoc """
  Define and evaluate expressions in runtime in your Elixir project.

  ## Features
  * JSON support - expressions support all JSON types with it's stanrad syntax
  * Python-like operators and standard functions
  * Extend expressions by providing Elixir module with functions that you want to use.
  * Safe evaluation without acces to other Elixir modules.
  """
  alias ExPression.Error
  alias ExPression.Interpreting
  alias ExPression.Parsing

  @type ast() :: any()

  @doc """
  Parse expression in string format into AST format.

  This can be used for optimizations: to parse expression once and evaluate AST many times.
  """
  @spec parse(binary()) :: {:ok, ast()} | {:error, ExPression.Error.t()}
  def parse(expression_str) when is_binary(expression_str) do
    case Parsing.parse(expression_str) do
      {:ok, ast} ->
        {:ok, ast}

      {:error, {:parsing_error, rest}} ->
        error = Error.new("SyntaxError", "Syntax Error: couldn't parse '#{rest}'", %{rest: rest})
        {:error, error}
    end
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
  @spec eval(binary() | ast(), Keyword.t()) :: {:ok, any()} | {:error, ExPression.Error.t()}
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

    case Interpreting.eval(ast, bindings, functions_module) do
      {:ok, res} ->
        {:ok, res}

      {:error, error} ->
        error = build_eval_error(error)
        {:error, error}
    end
  end

  defp build_eval_error({:var_not_bound, var}) do
    Error.new("UndefinedVariableError", "Variable '#{var}' was used, but was not defined", %{
      var: var
    })
  end

  defp build_eval_error({:fun_not_defined, fun, arity}) do
    Error.new(
      "UndefinedFunctionError",
      "Function '#{fun}/#{arity}' was referenced, but was not defined",
      %{function: fun}
    )
  end

  defp build_eval_error({:function_call_exception, fun, args, exception, msg}) do
    Error.new(
      "FunctionCallException",
      "Function '#{fun}' called with args #{inspect(args)} raised exception: #{inspect(exception.__struct__)}",
      %{function: fun, args: args, exception: exception, message: msg}
    )
  end
end
