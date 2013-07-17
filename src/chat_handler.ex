defmodule ChatHandler do
  
  def init(_any, req) do
    subscribe
    {:ok, req, nil}
  end

  def stream(msg, req, state) do
    broadcast msg
    {:reply, msg, req, state}
  end

  # A callback from gproc to broadcast msg to all clients
  def info({:chat_protocol, msg}, req, state) do
    {:reply, msg, req, state}
  end

  def info(_info, req, state) do
    {:ok, req, state}
  end

  def terminate(_reason, _req, _state) do
    :ok
  end

  defp subscribe do
    :gproc.reg {:p, :l, :chat_protocol}
  end

  defp broadcast(msg) do
    :gproc.send {:p, :l, :chat_protocol},
                {:chat_protocol, msg}
  end
end
