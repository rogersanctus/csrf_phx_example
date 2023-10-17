defmodule CsrfPhxExampleWeb.Router do
  use CsrfPhxExampleWeb, :router
  use Plug.ErrorHandler

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {CsrfPhxExampleWeb.Layouts, :root}
    plug :put_secure_browser_headers
  end

  pipeline :csrf do
    plug CsrfPlus, raise_exception?: true
    plug :assign_csrf_token
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", CsrfPhxExampleWeb do
    pipe_through [:browser, :csrf]

    get "/", PageController, :home
    get "/form", PageController, :get_form
    post "/form", PageController, :post_form
    get "/form-success", PageController, :form_success
  end

  # scope "/live", CsrfPhxExampleWeb do
  #   pipe_through [:browser, :protect_from_forgery]
  #
  #   live_session :default, layout: false, root_layout: {CsrfPhxExampleWeb.Layouts, :live} do
  #     live "/form", FormLive, :index
  #   end
  # end

  # Other scopes may use custom stacks.
  # scope "/api", CsrfPhxExampleWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:csrf_phx_example, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: CsrfPhxExampleWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  def handle_errors(conn, %{kind: _kind, reason: reason, stack: stack}) do
    if CsrfPlus.Exception.csrf_plus_exception?(reason) do
      form_route =
        Phoenix.Router.routes(__MODULE__)
        |> Enum.find(fn route ->
          route.plug == CsrfPhxExampleWeb.PageController && route.plug_opts == :get_form
        end)

      form_path =
        case form_route do
          nil -> "/"
          route -> route.path
        end

      conn
      |> assign(:error, reason)
      |> assign(:form_path, form_path)
      |> put_view(CsrfPhxExampleWeb.PageHTML)
      |> render(:form_error, layout: false)
    else
      reraise reason, stack
    end
  end

  defp assign_csrf_token(conn, _opts) do
    {_token, signed_token} = CsrfPlus.get_token_tuple(conn)
    assign(conn, :csrf_token, signed_token)
  end
end
