defmodule ChatCowboy.Mixfile do
  use Mix.Project

  def project do
    [ app: :"ChatCowboy",
      version: "0.0.1",
      deps: deps ]
  end

  # Configuration for the OTP application
  def application do
    [
      applications: [:ranch, :crypto, :cowboy, :gproc],
      mod: {ChatCowboyServer, []},
    ]
  end

  # Returns the list of dependencies in the format:
  # { :foobar, "0.1", git: "https://github.com/elixir-lang/foobar.git" }
  defp deps do
    [
      {:cowboy, %r".*", github: "extend/cowboy"},
      {:gproc, %r".*", github: "esl/gproc"},
    ]
  end
end