defmodule ExPression.StandardLib do
  @moduledoc """
  Standard library of functinos for ExPressions

  You can override or add to standard functinos by providing a module to ExPression.
  """

  import Kernel, except: [abs: 1, round: 1, min: 2, max: 2]

  @doc """
  Return the length (the number of items) of an object.
  """
  def len(term)
  def len(string) when is_binary(string), do: String.length(string)
  def len(list) when is_list(list), do: length(list)
  def len(%{} = map), do: map |> Map.keys() |> length()

  @doc """
  Returns the absolute value of a number.
  """
  def abs(number) when is_number(number) do
    Kernel.abs(number)
  end

  @doc """
  Converts term to it's string representation
  """
  def str(term)
  def str(term) when is_binary(term), do: term

  def str(term) do
    Jason.encode!(term, pretty: true)
  end

  @doc """
  Converts number or string to integer
  """
  def int(term)
  def int(term) when is_number(term), do: trunc(term)
  def int(term) when is_binary(term), do: String.to_integer(term)

  def round(number) when is_number(number), do: Kernel.round(number)

  def round(number, precision) when is_float(number), do: Float.round(number, precision)

  def min(list) when is_list(list), do: Enum.min(list)

  def min(a, b), do: Kernel.min(a, b)

  def max(list) when is_list(list), do: Enum.max(list)

  def max(a, b), do: Kernel.max(a, b)

  def pow(base, exponent) do
    base ** exponent
  end
end
