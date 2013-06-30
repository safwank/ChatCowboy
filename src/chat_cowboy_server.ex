defmodule ChatCowboyServer do
  @behaviour :application

  defp start_app(app) do
    status = :application.start app
    IO.puts "Starting up #{app}... #{inspect status}"
  end

  def start do
    start_app :ranch
    start_app :crypto
    start_app :cowboy
    start_app :gproc
    start_app __MODULE__
  end

  def start(_type, _args) do
    dispatch = :cowboy_router.compile([
      {:_, [
        {'/',  FileHandler, []},
        {'/_ws', WebSocketHandler, [{:dumb_protocol,   DumbIncrementHandler},
                                    {:mirror_protocol, MirrorHandler}]}
      ]}
    ])
    :cowboy.start_http :my_http_listener, 100, [{:port, 8080}], [{:env, [{:dispatch, dispatch}]}]

    ChatCowboySup.start_link
  end

  def stop(_state) do
    :ok
  end
end
