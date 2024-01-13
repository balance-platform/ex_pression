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

  ## Copied from Elixir sources for compatibility with Elixir versions below 1.13.0
  def pow(base, exponent)

  def pow(base, exponent) when is_integer(base) and is_integer(exponent) and exponent >= 0 do
    integer_pow(base, 1, exponent)
  end

  def pow(base, exponent) when is_number(base) and is_number(exponent) and exponent >= 0 do
    :math.pow(base, exponent)
  end

  # https://en.wikipedia.org/wiki/Exponentiation_by_squaring
  defp integer_pow(_, _, 0),
    do: 1

  defp integer_pow(b, a, 1),
    do: b * a

  defp integer_pow(b, a, e) when :erlang.band(e, 1) == 0,
    do: integer_pow(b * b, a, :erlang.bsr(e, 1))

  defp integer_pow(b, a, e),
    do: integer_pow(b * b, a * b, :erlang.bsr(e, 1))
end
