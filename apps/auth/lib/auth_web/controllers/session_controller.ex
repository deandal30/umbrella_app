defmodule AuthWeb.SessionController do
  use AuthWeb, :controller

  alias Innerpeace.Db.{
    Base.AuthContext,
    Hydra
  }

  def index(conn, %{"consent" => consent}) do
    user = Auth.Guardian.Plug.current_resource(conn)
    if is_nil(user) do
      render conn, "index.html", consent: consent
    else
      conn
      |> redirect(to: session_path(conn, :authorize, consent: consent))
    end
  end

  def index(conn, _) do
    render conn, "status.json"
  end

  defp parse_scopes(scopes) do
    Enum.map(scopes, fn(scope) ->
      case scope do
        "auth" ->
          %{
            name: "Auth",
            description: "Allow client to user your credentials to authenticate in their app."
          }
      end
    end)
  end

  def logout(conn, %{"consent" => consent}) do
    conn
    |> Auth.Guardian.Plug.sign_out
    |> redirect(to: session_path(conn, :index, consent: consent))
  end

  def unauthenticated(conn, consent) do
    conn
    |> put_flash(:error, "You need to authenticate your account.")
    |> render("index.html", consent: consent)
  end

  def authorize(conn, %{"consent" => consent}) do
    user = Auth.Guardian.Plug.current_resource(conn)
    if is_nil(user) do
      conn
      |> unauthenticated(consent)
    else
      res = Hydra.get_consent(consent)
      case res do
        %{"error" => error} ->
          conn
          |> render(AuthWeb.ErrorView, "404.html")
        res ->
          scopes = res["requestedScopes"]

          client = Hydra.get_client(res["clientId"])
          client = client |> parse_client(scopes)

          conn
          |> render("authorize.html", client: client, consent: consent, scopes: scopes)
      end
    end
  end

  defp parse_client(client, scopes) do
    %{
      name: client["client_name"],
      logo_uri: client["logo_uri"],
      policy_uri: client["policy_uri"],
      tos_uri: client["tos_uri"],
      scopes: parse_scopes(scopes)
    }
  end

  def accept(conn, %{
    "consent" => consent,
    "scopes" => scopes
  }) do
    user = Auth.Guardian.Plug.current_resource(conn)
    if is_nil(user) do
      conn
      |> unauthenticated(consent)
    else
      with {:ok} <- Hydra.accept(consent, scopes, user.id),
           res <- Hydra.get_consent(consent)
      do
        conn
        |> redirect(external: res["redirectUrl"])
      end
    end
  end

  def deny(conn, %{
    "consent" => consent,
    "scopes" => scopes
  }) do
    user = Auth.Guardian.Plug.current_resource(conn)
    if is_nil(user) do
      conn
      |> unauthenticated(consent)
    else
      with {:ok} <- Hydra.deny(consent, scopes, user.id),
           res <- Hydra.get_consent(consent)
      do
        conn
        |> redirect(external: res["redirectUrl"])
      end
    end
  end

  def login(conn, %{"session" => user_params}) do
    username = user_params["username"]
    password = user_params["password"]
    consent = user_params["consent"]
    case AuthContext.authenticate(username, password) do
      {:ok, user} ->
        conn
        |> Auth.Guardian.Plug.sign_in(user)
        |> redirect(to: session_path(conn, :index, consent: consent))
      {:error, :not_found} ->
        conn
        |> put_flash(:error, "Error in user login. Please try again.")
        |> render("index.html", consent: consent)
    end
  end
end
