defmodule ChatHandler do
  
  def init(_any, req) do
    sessionId = getSessionIdFrom req
    subscribe sessionId
    {:ok, req, nil}
  end

  def stream(msg, req, state) do
    sessionId = getSessionIdFrom req
    broadcast sessionId, msg
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

  defp getSessionIdFrom(req) do
    {sessionId, _updatedReq} = :cowboy_req.qs_val "sessionId", req
    sessionId
  end

  defp subscribe(sessionId) do
    :gproc.reg {:p, :l, {sessionId, :chat_protocol}}
  end

  defp broadcast(sessionId, msg) do
    :gproc.send {:p, :l, {sessionId, :chat_protocol}},
                {:chat_protocol, msg}
  end
end
