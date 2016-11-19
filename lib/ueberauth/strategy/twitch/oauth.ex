defmodule Ueberauth.Strategy.Twitch.OAuth do
  @moduledoc """
  OAuth2 for Twitch.

  Add `client_id` and `client_secret` to your configuration:

  config :ueberauth, Ueberauth.Strategy.Twitch.OAuth,
    client_id: System.get_env("TWITCH_APP_ID"),
    client_secret: System.get_env("TWITCH_APP_SECRET")
  """
  use OAuth2.Strategy

  @defaults [
     strategy: __MODULE__,
     site: "https://api.twitch.tv",
     authorize_url: "https://api.twitch.tv/kraken/oauth2/authorize",
     token_url: "https://api.twitch.tv/kraken/oauth2/token"
   ]

  @doc """
  Construct a client for requests to Twitch.

  This will be setup automatically for you in `Ueberauth.Strategy.Twitch`.

  These options are only useful for usage outside the normal callback phase of Ueberauth.
  """
  def client(opts \\ []) do
    config = Application.get_env(:ueberauth, Ueberauth.Strategy.Twitch.OAuth)

    opts =
      @defaults
      |> Keyword.merge(config)
      |> Keyword.merge(opts)

    OAuth2.Client.new(opts)
  end

  @doc """
  Provides the authorize url for the request phase of Ueberauth. No need to call this usually.
  """
  def authorize_url!(params \\ [], opts \\ []) do
    opts
    |> client
    |> OAuth2.Client.authorize_url!(params)
  end

  def get_token!(params \\ [], opts \\ []) do
    opts
    |> client
    |> OAuth2.Client.get_token!(params)
  end

  # Strategy Callbacks

  def authorize_url(client, params) do
    OAuth2.Strategy.AuthCode.authorize_url(client, params)
  end

  def get_token(client, params, headers) do
    client
    |> put_header("Accept", "application/json")
    |> OAuth2.Strategy.AuthCode.get_token(params, headers)
  end
end
