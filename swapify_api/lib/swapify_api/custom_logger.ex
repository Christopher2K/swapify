defmodule SwapifyApi.CustomLogger do
  @behaviour :gen_event

  def init({__MODULE__, name}) do
    {:ok, %{name: name}}
  end

  def handle_event({level, _gl, {Logger, msg, timestamp, metadata}}, state) do
    formatted_msg = format_message(level, msg, timestamp, metadata)

    # Print to console or now
    IO.puts(formatted_msg)

    {:ok, state}
  end

  def handle_call({:configure, new_config}, state) do
    {:ok, :ok, Map.merge(state, new_config)}
  end

  def handle_info(_, state) do
    {:ok, state}
  end

  defp format_message(level, msg, timestamp, metadata) do
    metadata_string = Enum.map_join(metadata, ", ", fn {k, v} -> "#{k}: #{inspect(v)}" end)
    color = get_color(level)
    time = format_timestamp(timestamp)
    level = level |> Atom.to_string() |> String.upcase()

    [color, "[#{level}] [#{time}]: #{msg} | #{metadata_string}", :reset]
    |> IO.ANSI.format(true)
    |> IO.iodata_to_binary()
  end

  defp format_timestamp({date, {hour, minute, second, millisecond}}) do
    {year, month, day} = date

    :io_lib.format(
      "~4..0B-~2..0B-~2..0B ~2..0B:~2..0B:~2..0B.~3..0B",
      [year, month, day, hour, minute, second, millisecond]
    )
    |> IO.iodata_to_binary()
  end

  defp get_color(:debug), do: :cyan
  defp get_color(:info), do: :green
  defp get_color(:warn), do: :yellow
  defp get_color(:error), do: :red
end
