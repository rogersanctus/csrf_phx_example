defmodule CsrfPhxExampleWeb.PageController do
  use CsrfPhxExampleWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home)
  end

  def get_form(conn, params) do
    {token, signed} = CsrfPlus.get_token_tuple(conn)

    conn
    |> assign(:form, Phoenix.Component.to_form(params))
    |> CsrfPlus.put_token(token_tuple: {token, signed}, exclude: [:header])
    |> render(:get_form, layout: false)
  end

  def post_form(conn, %{"email" => email} = params) do
    if String.length(String.trim(email)) == 0 do
      post_form(conn, with_params: params)
    else
      conn
      |> assign(:form, Phoenix.Component.to_form(params))
      |> render(:form_success, layout: false)
    end
  end

  def post_form(conn, with_params: params) do
    conn
    |> assign(:form, Phoenix.Component.to_form(params))
    |> assign(:error, "Email is required")
    |> render(:get_form, layout: false)
  end

  def post_form(conn, params) do
    post_form(conn, with_params: params)
  end
end
