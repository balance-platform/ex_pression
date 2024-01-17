defmodule ExPression.Parser do
  @moduledoc """
  Parsing expressions in strings format with convertion to AST format
  """
  alias ExPression.Parser.Grammar
  @peg Grammar.peg()

  @spec parse(binary()) :: {:ok, ast :: any()} | {:error, {:parsing_error, binary()}}
  def parse(expression_str) when is_binary(expression_str) do
    expression_str = String.trim(expression_str)

    case Xpeg.match(@peg, expression_str) do
      %{result: :ok, rest: [], captures: [ast]} -> {:ok, ast}
      %{result: _any, rest: rest} -> {:error, {:parsing_error, to_string(rest)}}
    end
  end
end
