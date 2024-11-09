defmodule SwapifyApi.Emails do
  import Swoosh.Email

  require EEx

  @no_reply_sender {"Swapify - Notifications", "info@swapify.live"}

  EEx.function_from_file(
    :defp,
    :welcome_template,
    "lib/swapify_api/emails/welcome.mjml.eex",
    [
      :username,
      :app_url
    ]
  )

  def welcome(email, name, options \\ []) do
    app_url = Keyword.get(options, :app_url)
    username = Keyword.get(options, :username)
    {:ok, template} = welcome_template(username, app_url) |> Mjml.to_html()

    new()
    |> to({name, email})
    |> from(@no_reply_sender)
    |> subject("Thanks for choosing Swapify!")
    |> html_body(template)
    |> put_provider_option(:track_clicks, false)
    |> put_provider_option(:track_opens, false)
  end

  EEx.function_from_file(
    :defp,
    :transfer_ready_template,
    "lib/swapify_api/emails/transfer_ready.mjml.eex",
    [
      :username,
      :app_url,
      :source_name,
      :destination_name,
      :playlist_length,
      :matched_tracks_length
    ]
  )

  def transfer_ready(email, name, options \\ []) do
    app_url = Keyword.get(options, :app_url)
    username = Keyword.get(options, :username)
    source_name = Keyword.get(options, :source_name)
    destination_name = Keyword.get(options, :destination_name)
    matched_tracks_length = Keyword.get(options, :matched_tracks_length)
    playlist_length = Keyword.get(options, :playlist_length)

    {:ok, template} =
      transfer_ready_template(
        username,
        app_url,
        source_name,
        destination_name,
        playlist_length,
        matched_tracks_length
      )
      |> Mjml.to_html()

    new()
    |> to({name, email})
    |> from(@no_reply_sender)
    |> subject("Your transfer is ready!")
    |> html_body(template)
    |> put_provider_option(:track_clicks, false)
    |> put_provider_option(:track_opens, false)
  end

  EEx.function_from_file(
    :defp,
    :transfer_error_template,
    "lib/swapify_api/emails/transfer_error.mjml.eex",
    [
      :username,
      :app_url,
      :source_name,
      :destination_name
    ]
  )

  def transfer_error(email, name, options \\ []) do
    app_url = Keyword.get(options, :app_url)
    username = Keyword.get(options, :username)
    source_name = Keyword.get(options, :source_name)
    destination_name = Keyword.get(options, :destination_name)

    {:ok, template} =
      transfer_error_template(username, app_url, source_name, destination_name)
      |> Mjml.to_html()

    new()
    |> to({name, email})
    |> from(@no_reply_sender)
    |> subject("There was an error on your transfer")
    |> html_body(template)
    |> put_provider_option(:track_clicks, false)
    |> put_provider_option(:track_opens, true)
  end

  EEx.function_from_file(
    :defp,
    :transfer_done_template,
    "lib/swapify_api/emails/transfer_done.mjml.eex",
    [
      :username,
      :app_url,
      :source_name,
      :destination_name
    ]
  )

  def transfer_done(email, name, options \\ []) do
    app_url = Keyword.get(options, :app_url)
    username = Keyword.get(options, :username)
    source_name = Keyword.get(options, :source_name)
    destination_name = Keyword.get(options, :destination_name)

    {:ok, template} =
      transfer_done_template(username, app_url, source_name, destination_name)
      |> Mjml.to_html()

    new()
    |> to({name, email})
    |> from(@no_reply_sender)
    |> subject("Your transfer is done!")
    |> html_body(template)
    |> put_provider_option(:track_clicks, false)
    |> put_provider_option(:track_opens, true)
  end

  EEx.function_from_file(
    :defp,
    :password_reset_request_template,
    "lib/swapify_api/emails/password_reset_request.mjml.eex",
    [
      :username,
      :reset_link
    ]
  )

  def password_reset_request(email, name, opts \\ []) do
    code = Keyword.get(opts, :code)

    app_url = Application.fetch_env!(:swapify_api, :app_url)

    reset_url = app_url <> "/password-reset/#{code}"

    {:ok, template} =
      password_reset_request_template(name, reset_url)
      |> Mjml.to_html()

    new()
    |> to({name, email})
    |> from(@no_reply_sender)
    |> subject("Password reset request")
    |> html_body(template)
    |> put_provider_option(:track_clicks, false)
    |> put_provider_option(:track_opens, true)
  end
end
