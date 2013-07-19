defmodule ChatHandler do
  
  def init(_any, req) do
    session_id = get_session_id_from(req)
    subscribe(session_id)
    {:ok, req, nil}
  end

  def stream(msg, req, state) do
    session_id = get_session_id_from(req)
    broadcast(session_id, msg)
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

  defp get_session_id_from(req) do
    {session_id, _req} = :cowboy_req.qs_val("session_id", req)
    session_id
  end

  defp subscribe(session_id) do
    :gproc.reg {:p, :l, {session_id, :chat_protocol}}
  end

  defp broadcast(session_id, msg) do
    :gproc.send {:p, :l, {session_id, :chat_protocol}},
                {:chat_protocol, msg}
  end
end
