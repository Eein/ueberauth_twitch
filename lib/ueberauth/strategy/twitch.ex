defmodule Ueberauth.Strategy.Twitch do
  @moduledoc """
  Twitch Strategy for Überauth.
  """

  use Ueberauth.Strategy, uid_field: :sub, default_scope: "email", hd: nil

  alias Ueberauth.Auth.Info
  alias Ueberauth.Auth.Credentials
  alias Ueberauth.Auth.Extra

  @doc """
  Handles initial request for Twitch authentication.
  """
  def handle_request!(conn) do
    scopes = conn.params["scope"] || option(conn, :default_scope)

    opts =
      [ scope: scopes ]
      |> with_optional(:hd, conn)
      |> with_optional(:approval_prompt, conn)
      |> with_optional(:access_type, conn)
      |> Keyword.put(:redirect_uri, callback_url(conn))

    redirect!(conn, Ueberauth.Strategy.Twitch.OAuth.authorize_url!(opts))
  end

  @doc """
  Handles the callback from Twitch.
  """
  def handle_callback!(%Plug.Conn{ params: %{ "code" => code } } = conn) do
    opts = [redirect_uri: callback_url(conn)]
    token = Ueberauth.Strategy.Twitch.OAuth.get_token!([code: code], opts)

    if token.access_token == nil do
      set_errors!(conn, [error(token.other_params["error"], token.other_params["error_description"])])
    else
      fetch_user(conn, token)
    end
  end

  @doc false
  def handle_callback!(conn) do
    set_errors!(conn, [error("missing_code", "No code received")])
  end

  @doc false
  def handle_cleanup!(conn) do
    conn
    |> put_private(:twitch_user, nil)
    |> put_private(:twitch_token, nil)
  end

  @doc """
  Fetches the uid field from the response.
  """
  def uid(conn) do
    uid_field =
      conn
      |> option(:uid_field)
      |> to_string

    conn.private.twitch_user[uid_field]
  end

  @doc """
  Includes the credentials from the twitch response.
  """
  def credentials(conn) do
    token = conn.private.twitch_token
    scopes = (token.other_params["scope"] || "")
              |> String.split(",")

    %Credentials{
      expires: !!token.expires_at,
      expires_at: token.expires_at,
      scopes: scopes,
      refresh_token: token.refresh_token,
      token: token.access_token
    }
  end

  @doc """
  Fetches the fields to populate the info section of the `Ueberauth.Auth` struct.
  """
  def info(conn) do
    user = conn.private.twitch_user

    %Info{
      email: user["email"],
      name: user["name"],
      image: user["logo"],
      id: user["_id"]
    }
  end

  @doc """
  Stores the raw information (including the token) obtained from the twitch callback.
  """
  def extra(conn) do
    %Extra{
      raw_info: %{
        token: conn.private.twitch_token,
        user: conn.private.twitch_user
      }
    }
  end


  defp fetch_user(conn, token) do
    conn = put_private(conn, :twitch_token, token)

    # userinfo_endpoint from https://accounts.twitch.com/.well-known/openid-configuration
    #path = "https://api.twitch.tv/kraken/user"
    path = "https://api.twitch.tv/kraken/oauth2/authorize"
    resp = OAuth2.AccessToken.get(token, path)

    case resp do
      { :ok, %OAuth2.Response{status_code: 401, body: _body}} ->
        set_errors!(conn, [error("token", "unauthorized")])
      { :ok, %OAuth2.Response{status_code: status_code, body: user} } when status_code in 200..399 ->
        put_private(conn, :twitch_user, user)
      { :error, %OAuth2.Error{reason: reason} } ->
        set_errors!(conn, [error("OAuth2", reason)])
    end
  end

  defp with_optional(opts, key, conn) do
    if option(conn, key), do: Keyword.put(opts, key, option(conn, key)), else: opts
  end

  defp option(conn, key) do
    Dict.get(options(conn), key, Dict.get(default_options, key))
  end
end
