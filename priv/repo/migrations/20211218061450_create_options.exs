defmodule Beast.Repo.Migrations.CreateOptions do
  use Ecto.Migration

  def change do
    create table(:options) do
      add :symbol, :string
      add :strike, :string
      add :expiration, :string
      add :price, :decimal
      add :beast_low, :decimal
      add :beast_high, :decimal

      timestamps()
    end
  end
end
