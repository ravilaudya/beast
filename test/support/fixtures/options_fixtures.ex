defmodule Beast.OptionsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Beast.Options` context.
  """

  @doc """
  Generate a option.
  """
  def option_fixture(attrs \\ %{}) do
    {:ok, option} =
      attrs
      |> Enum.into(%{
        beast_high: "120.5",
        beast_low: "120.5",
        expiration: "some expiration",
        price: "120.5",
        strike: "some strike",
        symbol: "some symbol"
      })
      |> Beast.Options.create_option()

    option
  end
end
