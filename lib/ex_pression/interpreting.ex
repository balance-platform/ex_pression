defmodule ExPression.Interpreting do
  @moduledoc """
  Evaluating AST
  """
  alias ExPression.StandardLib

  # Python boolean sematics
  @empty_values [[], %{}, ""]

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
    arity = length(args)

    with :ok <- args_find_error(args),
         {:ok, f_name} <- string_to_existing_atom(name) do
      cond do
        context.functions_module && Code.ensure_loaded?(context.functions_module) &&
            Kernel.function_exported?(context.functions_module, f_name, arity) ->
          safe_fun_call(context.functions_module, f_name, args)

        Code.ensure_loaded?(StandardLib) && Kernel.function_exported?(StandardLib, f_name, arity) ->
          safe_fun_call(StandardLib, f_name, args)

        true ->
          {:error, {:fun_not_defined, f_name, arity}}
      end
    else
      {:error, :atom_not_exist} -> {:error, {:fun_not_defined, name, arity}}
      error -> error
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
      _other -> {:error, {:var_not_bound, name}}
    end
  end

  defp do_eval({:not, [x]}, context) do
    case do_eval(x, context) do
      {:error, _e} = error ->
        error

      res ->
        if res in @empty_values do
          true
        else
          not res
        end
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

      {_key, error} ->
        error
    end
  end

  defp do_eval({:special, [special, value]}, context) do
    case context.functions_module do
      nil -> {:error, {:special_without_module, special, value}}
      module -> module.handle_special(special, value)
    end
  end

  defp do_eval({op, [a, b]}, context) do
    with a when not is_tuple(a) <- do_eval(a, context),
         b when not is_tuple(b) <- do_eval(b, context) do
      eval_bin_op(op, a, b)
    end
  end

  defp do_eval(atom_node, _context) when not is_tuple(atom_node) do
    atom_node
  end

  defp eval_bin_op(:*, a, b) when is_number(a) and is_number(b) do
    a * b
  end

  defp eval_bin_op(:/, a, b) when is_number(a) and is_number(b) do
    a / b
  end

  defp eval_bin_op(:/, a, b) do
    {:bad_op_arg_types, {:/, a, b}}
  end

  defp eval_bin_op(:+, a, b) when is_number(a) and is_number(b) do
    a + b
  end

  defp eval_bin_op(:+, a, b) when is_binary(a) and is_binary(b) do
    a <> b
  end

  defp eval_bin_op(:-, a, b) when is_number(a) and is_number(b) do
    a - b
  end

  # Python semantics for boolean ops

  defp eval_bin_op(:and, a, b) do
    if a in @empty_values do
      a
    else
      a && b
    end
  end

  defp eval_bin_op(:or, a, b) do
    if a in @empty_values do
      b
    else
      a || b
    end
  end

  defp eval_bin_op(:==, a, b) do
    a == b
  end

  defp eval_bin_op(:!=, a, b) do
    a != b
  end

  # Python semantics regarding comparison

  defp eval_bin_op(op, a, b) when op in [:>, :>=, :<, :<=] and is_number(a) and is_number(b) do
    apply(Kernel, op, [a, b])
  end

  defp eval_bin_op(op, a, b) when op in [:>, :>=, :<, :<=] and is_binary(a) and is_binary(b) do
    apply(Kernel, op, [a, b])
  end

  defp eval_bin_op(op, a, b)
       when op in [:>, :>=, :<, :<=] and a in [true, false] and b in [true, false] do
    apply(Kernel, op, [a, b])
  end

  defp eval_bin_op(op, a, b) when op in [:>, :>=, :<, :<=] and is_list(a) and is_list(b) do
    apply(Kernel, op, [length(a), length(b)])
  end

  defp eval_bin_op(:access, %{} = a, b) do
    a[b]
  end

  defp eval_bin_op(:access, a, b) when is_list(a) do
    Enum.at(a, b)
  end

  defp eval_bin_op(op, a, b) do
    {:error, {:bad_op_arg_types, {op, [a, b]}}}
  end

  defp args_find_error(args) do
    case Enum.find(args, fn
           {:error, _e} -> true
           _arg -> false
         end) do
      nil -> :ok
      error -> error
    end
  end

  defp string_to_existing_atom(str) when is_binary(str) do
    {:ok, String.to_existing_atom(str)}
  rescue
    _e ->
      {:error, :atom_not_exist}
  end

  defp safe_fun_call(m, f, args) do
    apply(m, f, args)
  rescue
    e ->
      msg = Exception.format(:error, e, __STACKTRACE__)
      {:error, {:function_call_exception, f, args, e, msg}}
  end
end
