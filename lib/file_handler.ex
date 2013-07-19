defmodule FileHandler do
  @behaviour :cowboy_http_handler
  @moduledoc """
  This is an HTTP handler that will serve a single file to the
  client.
  """

  def init({_any, :http}, req, []) do
    { :ok, req, :undefined}
  end

  def handle(req, state) do
    {path, _req} = :cowboy_req.path(req)
    content_type = get_content_type_for(path)

    {:ok, content} = File.read("assets" <> path)
    {:ok, req} = :cowboy_req.reply(200, [{"Content-Type", content_type}], content, req)
    {:ok, req, state}
  end

  def terminate(_reason, _req, _state) do
    :ok
  end

  defp get_content_type_for(path) do
    cond do
      String.contains? path, ".html" ->
        "text/html"
      String.contains? path, ".js" ->
        "application/javascript"
      String.contains? path, ".css" ->
        "text/css"
      true ->
        "text/plain"
    end
  end
end

