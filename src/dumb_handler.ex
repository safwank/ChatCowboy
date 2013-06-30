defmodule DumbIncrementHandler do
  #@behaviour :simple_handler

  defrecord State, counter: 0

  def init(_any, req) do
    :timer.send_interval 50, :tick
    {:ok, req, State.new}
  end

  def stream("reset\n", req, state) do
    {:ok, req, state.counter(0)}
  end

  # Received timer event
  def info(:tick, req, state) do
    {:reply,
      to_binary(state.counter),
      req,
      state.update_counter(fn(x) -> x + 1 end)}
  end

  def info(_info, req, state) do
    {:ok, req, state}
  end

  def terminate(_reason, _req, _state) do
    :ok
  end
end

