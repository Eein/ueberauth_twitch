# Überauth Twitch

> Twitch OAuth2 strategy for Überauth.

## Installation

1. UPDATE: Setup your application at [Twitch Developer Console](https://console.developers.twitch.com/home).

1. Add `:ueberauth_twitch` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:ueberauth_twitch, "~> 0.4"}]
    end
    ```

1. Add the strategy to your applications:

    ```elixir
    def application do
      [applications: [:ueberauth_twitch]]
    end
    ```

1. Add Twitch to your Überauth configuration:

    ```elixir
    config :ueberauth, Ueberauth,
      providers: [
        twitch: {Ueberauth.Strategy.Twitch, []}
      ]
    ```

1.  Update your provider configuration:

    ```elixir
    config :ueberauth, Ueberauth.Strategy.Twitch.OAuth,
      client_id: System.get_env("TWITCH_CLIENT_ID"),
      client_secret: System.get_env("TWITCH_CLIENT_SECRET")
    ```

1.  Include the Überauth plug in your controller:

    ```elixir
    defmodule MyApp.AuthController do
      use MyApp.Web, :controller
      plug Ueberauth
      ...
    end
    ```

1.  Create the request and callback routes if you haven't already:

    ```elixir
    scope "/auth", MyApp do
      pipe_through :browser

      get "/:provider", AuthController, :request
      get "/:provider/callback", AuthController, :callback
    end
    ```

1. Your controller needs to implement callbacks to deal with `Ueberauth.Auth` and `Ueberauth.Failure` responses.

For an example implementation see the [Überauth Example](https://github.com/ueberauth/ueberauth_example) application.

## Calling

Depending on the configured url you can initial the request through:

    /auth/twitch

Or with options:

    /auth/twitch?scope=email%20profile

By default the requested scope is "email". Scope can be configured either explicitly as a `scope` query value on the request path or in your configuration:

```elixir
config :ueberauth, Ueberauth,
  providers: [
    twitch: {Ueberauth.Strategy.Twitch, [default_scope: "user_read"]}
  ]
```

You can also pass options such as the `hd` parameter to limit sign-in to a particular Twitch Apps hosted domain, or `approval_prompt` and `access_type` options to request refresh_tokens and offline access.

```elixir
config :ueberauth, Ueberauth,
  providers: [
    twitch: {Ueberauth.Strategy.Twitch, [hd: "example.com", approval_prompt: "force", access_type: "offline"]}
  ]
```

To guard against client-side request modification, it's important to still check the domain in `info.urls[:website]` within the `Ueberauth.Auth` struct if you want to limit sign-in to a specific domain.

## License

Please see [LICENSE](https://github.com/eein/ueberauth_twitch/blob/master/LICENSE) for licensing details.
