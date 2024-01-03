defmodule ExPression.Parsing do
  @moduledoc """
  Parsing expressions in strings format with convertion to AST format
  """
  alias ExPression.Parsing.Grammar
  @peg Grammar.peg()

  @spec parse(binary()) :: {:ok, ast :: any()} | {:error, :parsing_error}
  def parse(expression_str) when is_binary(expression_str) do
    case Xpeg.match(@peg, expression_str) do
      %{result: :ok, captures: [ast]} -> {:ok, ast}
      %{result: :error} -> {:error, :parsing_error}
    end
  end
end
