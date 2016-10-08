defmodule Evercraft do
  use Application

  def start(_type, _args) do
    Evercraft.Class.Supervisor.start_link
  end

end
