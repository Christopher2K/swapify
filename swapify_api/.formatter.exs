[
  plugins: [
    TailwindFormatter,
    Phoenix.LiveView.HTMLFormatter
  ],
  import_deps: [:ecto, :ecto_sql, :phoenix],
  subdirectories: ["priv/*/migrations"],
  inputs: ["*.{ex,exs,heex}", "{config,lib,test}/**/*.{ex,exs,heex}", "priv/*/seeds.exs"]
]
