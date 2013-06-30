defmodule MirrorHandler do
  
  def init(_any, req) do
    subscribe
    {:ok, req, nil}
  end

  # All it does is send the message back to all clients,
  # including the sender itself
  def stream(msg, req, state) do
    broadcast msg
    {:reply, msg, req, state}
  end

  # A callback from gproc to broadcast msg to all clients
  def info({:mirror_protocol, msg}, req, state) do
    {:reply, msg, req, state}
  end

  def info(_info, req, state) do
    {:ok, req, state}
  end

  def terminate(_reason, _req, _state) do
    :ok
  end


  ## Private functions ##

  defp subscribe do
    :gproc.reg {:p, :l, :mirror_protocol}
  end

  defp broadcast(msg) do
    :gproc.send {:p, :l, :mirror_protocol},
                {:mirror_protocol, msg}
  end
end
