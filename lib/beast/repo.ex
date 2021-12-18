defmodule Beast.Repo do
  use Ecto.Repo,
    otp_app: :beast,
    adapter: Ecto.Adapters.Postgres
end
