defmodule Beast.OptionsTest do
  use Beast.DataCase

  alias Beast.Options

  describe "options" do
    alias Beast.Options.Option

    import Beast.OptionsFixtures

    @invalid_attrs %{beast_high: nil, beast_low: nil, expiration: nil, price: nil, strike: nil, symbol: nil}

    test "list_options/0 returns all options" do
      option = option_fixture()
      assert Options.list_options() == [option]
    end

    test "get_option!/1 returns the option with given id" do
      option = option_fixture()
      assert Options.get_option!(option.id) == option
    end

    test "create_option/1 with valid data creates a option" do
      valid_attrs = %{beast_high: "120.5", beast_low: "120.5", expiration: "some expiration", price: "120.5", strike: "some strike", symbol: "some symbol"}

      assert {:ok, %Option{} = option} = Options.create_option(valid_attrs)
      assert option.beast_high == Decimal.new("120.5")
      assert option.beast_low == Decimal.new("120.5")
      assert option.expiration == "some expiration"
      assert option.price == Decimal.new("120.5")
      assert option.strike == "some strike"
      assert option.symbol == "some symbol"
    end

    test "create_option/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Options.create_option(@invalid_attrs)
    end

    test "update_option/2 with valid data updates the option" do
      option = option_fixture()
      update_attrs = %{beast_high: "456.7", beast_low: "456.7", expiration: "some updated expiration", price: "456.7", strike: "some updated strike", symbol: "some updated symbol"}

      assert {:ok, %Option{} = option} = Options.update_option(option, update_attrs)
      assert option.beast_high == Decimal.new("456.7")
      assert option.beast_low == Decimal.new("456.7")
      assert option.expiration == "some updated expiration"
      assert option.price == Decimal.new("456.7")
      assert option.strike == "some updated strike"
      assert option.symbol == "some updated symbol"
    end

    test "update_option/2 with invalid data returns error changeset" do
      option = option_fixture()
      assert {:error, %Ecto.Changeset{}} = Options.update_option(option, @invalid_attrs)
      assert option == Options.get_option!(option.id)
    end

    test "delete_option/1 deletes the option" do
      option = option_fixture()
      assert {:ok, %Option{}} = Options.delete_option(option)
      assert_raise Ecto.NoResultsError, fn -> Options.get_option!(option.id) end
    end

    test "change_option/1 returns a option changeset" do
      option = option_fixture()
      assert %Ecto.Changeset{} = Options.change_option(option)
    end
  end
end
