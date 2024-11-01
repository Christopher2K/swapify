defmodule SwapifyApi.Emails do
  import Swoosh.Email

  require EEx

  @no_reply_sender {"Swapify", "noreply@swapify.live"}

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
  end
end
