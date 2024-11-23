defmodule SwapifyApi.RateLimiter do
  @doc """
  Rate limit a controller action
  """
  @spec rate_limit(String.t(), list(:atom), pos_integer(), pos_integer(), atom() | tuple()) ::
          any()
  defmacro rate_limit(bucket_name, actions, ms_window, limit, by \\ :ip) do
    quote do
      plug Hammer.Plug,
           [
             rate_limit: {unquote(bucket_name), unquote(ms_window), unquote(limit)},
             by: unquote(by)
           ]
           when var!(action) in unquote(actions)
    end
  end
end
