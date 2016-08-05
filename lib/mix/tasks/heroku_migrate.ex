defmodule Mix.Tasks.Heroku.Migrate do
  use Mix.Task

  @shortdoc "Run migrate on production heroku"
  def run(_args) do
    System.cmd "heroku", ["run", "POOL_SIZE=2 mix ecto.migrate"], into: IO.stream(:stdio, :line)
  end
end
