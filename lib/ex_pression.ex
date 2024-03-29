defmodule ExPression do
  @moduledoc """
  Evaluate user input expression.
  """
  alias ExPression.Error
  alias ExPression.Interpreter
  alias ExPression.Parser

  @type ast() :: any()

  @doc """
  Parse expression in string format into AST format.

  This can be used for optimizations: to parse expression once and evaluate AST many times.
  """
  @spec parse(binary()) :: {:ok, ast()} | {:error, ExPression.Error.t()}
  def parse(expression_str) when is_binary(expression_str) do
    case Parser.parse(expression_str) do
      {:ok, ast} ->
        {:ok, ast}

      {:error, {:parsing_error, rest}} ->
        error = Error.new("SyntaxError", "Syntax Error: couldn't parse '#{rest}'", %{rest: rest})
        {:error, error}
    end
  end

  @doc """
  Evaluate expression.

  ## Options
  * `:bindings` - map variable names and values.
  * `:functions_module` - module with functions that will be accessible from expressions.

  ## Examples
      iex> eval("1 + 0.5")
      {:ok, 1.5}
      iex> eval("div(x, y)", bindings: %{"x" => 5, "y" => 2}, functions_module: Kernel)
      {:ok, 2}
      iex> eval(~s/{"1": "en", "2": "fr"}[str(int_code)]/, bindings: %{"int_code" => 1})
      {:ok, "en"}
      iex> eval("not true or false or 1 == 1")
      {:ok, true}
      iex> eval("exit(self())")
      {:error, %ExPression.Error{name: "UndefinedFunctionError", message: "Function 'self/0' was referenced, but was not defined", data: %{function: :self}}}
  """
  @spec eval(binary(), Keyword.t()) :: {:ok, any()} | {:error, ExPression.Error.t()}
  def eval(expression_str, opts \\ []) when is_binary(expression_str) do
    case parse(expression_str) do
      {:ok, ast} -> eval_ast(ast, opts)
      error -> error
    end
  end

  @doc """
  Evaluate expression given in AST format.
  """
  @spec eval_ast(ast(), Keyword.t()) :: {:ok, any()} | {:error, ExPression.Error.t()}
  def eval_ast(ast, opts \\ []) do
    bindings = Keyword.get(opts, :bindings, %{})
    functions_module = Keyword.get(opts, :functions_module)

    case Interpreter.eval(ast, bindings, functions_module) do
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

  defp build_eval_error({:bad_op_arg_types, {op, args}}) do
    Error.new(
      "BadOperationArgumentTypes",
      "Opeartion '#{op}' does not support argument types of #{inspect(args)}",
      %{
        operation: op,
        arguments: args
      }
    )
  end

  defp build_eval_error({:special_without_module, special, value}) do
    Error.new(
      "SpecialWithoutModule",
      "Special symbol '#{special}' used with value #{value}, but no functions module was provided",
      %{
        special: special,
        value: value
      }
    )
  end
end
