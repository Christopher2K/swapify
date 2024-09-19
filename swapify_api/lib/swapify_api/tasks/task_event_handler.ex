defmodule SwapifyApi.Tasks.TaskEventHandler do
  @moduledoc """
  Macros defining events handlers

  ## Examples
    use SwapifyApi.Tasks.TaskEventHandler, job_module: "Swapify.MyObanJob"

    handle :success do
      # do something with the `args` variable
    end

    handle :catch_call do
      # Required, for safety
    end
  """
  defmacro __using__(opts) do
    quote do
      import SwapifyApi.Tasks.TaskEventHandler
      @jobname unquote(opts[:job_module])
    end
  end

  defmacro handle(:started, do: block) do
    quote do
      def handle_event(
            [:oban, :job, :start],
            _,
            %{job: %{worker: @jobname, args: var!(job_args)}},
            _
          ) do
        unquote(block)
      end
    end
  end

  defmacro handle(:success, do: block) do
    quote do
      def handle_event(
            [:oban, :job, :stop],
            _,
            %{
              job: %{worker: @jobname, args: var!(job_args)},
              result: var!(result),
              state: state
            },
            _
          )
          when state != :cancelled do
        unquote(block)
      end
    end
  end

  defmacro handle(:cancelled, do: block) do
    quote do
      def handle_event(
            [:oban, :job, :stop],
            _,
            %{
              job: %{worker: @jobname, args: var!(job_args)},
              state: :cancelled
            },
            _
          ) do
        unquote(block)
      end
    end
  end

  defmacro handle(:failure, do: block) do
    quote do
      def handle_event(
            [:oban, :job, :exception],
            _,
            %{
              job: %{worker: @jobname, args: var!(job_args)} = job
            },
            _
          )
          when job.attempt == job.max_attempts do
        unquote(block)
      end
    end
  end

  defmacro handle(:error, do: block) do
    quote do
      def handle_event(
            [:oban, :job, :exception],
            _,
            %{job: %{worker: @jobname, args: var!(job_args)} = job},
            _
          )
          when job.attempt < job.max_attempts do
        unquote(block)
      end
    end
  end

  defmacro handle(:catch_all, do: block) do
    quote do
      def handle_event(_, _, _, _) do
        unquote(block)
      end
    end
  end

  @doc """
  Register a module as an Oban Telemetry Event Handler
  """
  defmacro register(module_name) do
    quote do
      handler_module = String.to_atom("Elixir." <> to_string(unquote(module_name)))
      handler_function = :handle_event

      :telemetry.attach_many(
        "#{unquote(module_name)}-Events",
        [
          [:oban, :job, :start],
          [:oban, :job, :stop],
          [:oban, :job, :exception]
        ],
        &apply(handler_module, handler_function, [&1, &2, &3, &4]),
        []
      )
    end
  end
end
