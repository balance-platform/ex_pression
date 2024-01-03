defmodule ExPression.Interpreting do
  @moduledoc """
  Evaluating AST
  """
  alias ExPression.StandardLib

  @spec eval(ast :: any(), bindings :: map(), functions_module :: atom()) ::
          {:ok, res :: any()} | {:error, any()}
  def eval(ast, bindings \\ %{}, functions_module \\ nil) do
    case do_eval(ast, %{functions_module: functions_module, bindings: bindings}) do
      {:error, error} -> {:error, error}
      res -> {:ok, res}
    end
  end

  defp do_eval({:fun_call, [name | args]}, context) do
    args = Enum.map(args, &do_eval(&1, context))

    case Enum.find(args, fn
           {:error, _e} -> true
           _arg -> false
         end) do
      nil ->
        f_name = String.to_existing_atom(name)
        arity = length(args)
        # TODO: wrap error on function exception ???
        cond do
          context.functions_module &&
              Kernel.function_exported?(context.functions_module, f_name, arity) ->
            apply(context.functions_module, f_name, args)

          Code.ensure_loaded(StandardLib) && Kernel.function_exported?(StandardLib, f_name, arity) ->
            apply(StandardLib, f_name, args)

          true ->
            {:error, {:fun_not_defined, f_name, arity}}
        end

      error ->
        error
    end
  end

  defp do_eval({:field_access, [obj, field_name]}, context) do
    case do_eval(obj, context) do
      {:error, _e} = error ->
        error

      obj ->
        Map.get(obj, field_name)
    end
  end

  defp do_eval({:var, [name]}, context) do
    case context.bindings do
      %{^name => value} -> value
      _other -> {:error, {:var_not_defined, name}}
    end
  end

  defp do_eval({:not, [x]}, context) do
    case do_eval(x, context) do
      {:error, _e} = error -> error
      res -> not res
    end
  end

  defp do_eval({:array, items}, context) do
    items = Enum.map(items, &do_eval(&1, context))

    case Enum.find(items, fn
           {:error, _e} -> true
           _arg -> false
         end) do
      nil ->
        items

      error ->
        error
    end
  end

  defp do_eval({:obj, obj}, context) do
    obj = Enum.map(obj, fn {k, v} -> {k, do_eval(v, context)} end)

    case Enum.find(obj, fn
           {_k, {:error, _e}} -> true
           _kv -> false
         end) do
      nil ->
        Map.new(obj)

      error ->
        error
    end
  end

  # credo:disable-for-next-line
  defp do_eval({op, [a, b]}, context) do
    with a when not is_tuple(a) <- do_eval(a, context),
         b when not is_tuple(b) <- do_eval(b, context) do
      case op do
        :* -> a * b
        :/ -> a / b
        :+ -> a + b
        :- -> a - b
        :and -> a and b
        :or -> a or b
        :== -> a == b
        :!= -> a != b
        :> -> a > b
        :>= -> a >= b
        :< -> a < b
        :<= -> a <= b
        :access -> eval_access(a, b)
      end
    end
  end

  defp do_eval(atom_node, _context) when not is_tuple(atom_node) do
    atom_node
  end

  defp eval_access(%{} = a, b) do
    a[b]
  end

  defp eval_access(a, b) when is_list(a) do
    Enum.at(a, b)
  end
end
