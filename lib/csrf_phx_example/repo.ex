defmodule CsrfPhxExample.Repo do
  use Ecto.Repo,
    otp_app: :csrf_phx_example,
    adapter: Ecto.Adapters.Postgres
end
