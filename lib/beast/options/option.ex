defmodule Beast.Options.Option do
  use Ecto.Schema
  import Ecto.Changeset

  schema "options" do
    field :beast_high, :decimal, default: 0.0
    field :beast_low, :decimal, default: 0.0
    field :expiration, :string
    field :price, :decimal, default: 0.0
    field :strike, :string
    field :symbol, :string

    timestamps()
  end

  @doc false
  def changeset(option, attrs) do
    option
    |> cast(attrs, [:symbol])
    |> validate_required([:symbol])
  end
end
