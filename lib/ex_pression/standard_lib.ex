defmodule ExPression.StandardLib do
  @moduledoc """
  Standard library of functinos for ExPressions

  You can override or add to standard functinos by providing a module to ExPression.
  """

  def str(term) do
    to_string(term)
  end
end
