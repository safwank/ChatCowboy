defmodule WebSocketHandler do
  @behaviour :cowboy_http_handler
  @behaviour :cowboy_websocket_handler


  ## This is the part where we handle our WebSocket protocols

  defrecord State, handler: nil, handler_state: nil

  def websocket_init(_any, req, opts) do
    # Select a handler based on the WebSocket sub-protocol
    { headers, _ } = :cowboy_req.headers(req)
    proto = List.keyfind headers, "sec-websocket-protocol", 0
    handler =
      case proto do
        {"sec-websocket-protocol", "dumb-increment-protocol"} ->
          {_, handler} = List.keyfind opts, :dumb_protocol, 0
          handler

        {"sec-websocket-protocol", "mirror-protocol"} ->
          {_, handler} = List.keyfind opts, :mirror_protocol, 0
          handler
      end

    # Init selected handler
    case handler.init(_any, req) do
      {:ok, req, state} ->
        req = :cowboy_req.compact req
        format_ok req, State.new(handler: handler,
                                 handler_state: state)

      {:shutdown, req, _state} ->
        {:shutdown, req}
    end
  end

  # Dispatch generic message to the handler
  def websocket_handle({:text, msg}, req, state) do
    handler = state.handler
    handler_state = state.handler_state

    case handler.stream(msg, req, handler_state) do
      {:ok, req, new_state} ->
        format_ok req, state.handler_state(new_state)

      {:reply, reply, req, new_state} ->
        format_reply req, reply, state.handler_state(new_state)
    end
  end

  # Default case
  def websocket_handle(_any, req, state) do
    format_ok req, state
  end

  # Various service messages
  def websocket_info(info, req, state) do
    handler = state.handler
    handler_state = state.handler_state

    case handler.info(info, req, handler_state) do
      {:ok, req, new_state} ->
        format_ok req, state.handler_state(new_state)

      {:reply, reply, req, new_state} ->
        format_reply req, reply, state.handler_state(new_state)
    end
  end

  def websocket_terminate(_reason, _req, _state) do
    :ok
  end


  ## This is the HTTP part of the handler. It will only start up
  ## properly, if the request is asking to upgrade the protocol to
  ## WebSocket

  defp not_implemented(req) do
    { :ok, req } = :cowboy_req.reply(501, [], [], req)
    { :shutdown, req, :undefined }
  end

  def init({_any, :http}, req, _opts) do
    case :cowboy_req.header("upgrade", req) do
      {bin, req} when is_binary(bin) ->
        case :cowboy_bstr.to_lower(bin) do
          "websocket" ->
            { :upgrade, :protocol, :cowboy_websocket }
          _ ->
            not_implemented req
        end
      {:undefined, req} ->
        not_implemented req
    end
  end

  def handle(req, _state) do
    not_implemented req
  end

  def terminate(_reason, _req, _state) do
    :ok
  end


  ## Private API

  defp format_ok(req, state) do
    {:ok, req, state, :hibernate}
  end

  defp format_reply(req, reply, state) do
    {:reply, {:text, reply}, req, state, :hibernate}
  end
end
