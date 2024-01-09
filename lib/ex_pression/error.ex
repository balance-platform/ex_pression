defmodule ExPression.Error do
  @moduledoc """
  Error that occurred while parsing or evaluating expression.
  """
  defstruct [:name, :message, :data]

  @type t() :: %__MODULE__{
          name: binary(),
          message: binary(),
          data: map()
        }

  @spec new(binary(), binary(), map()) :: t()
  def new(name, message, %{} = data) when is_binary(name) and is_binary(message) do
    %__MODULE__{
      name: name,
      message: message,
      data: data
    }
  end
end
