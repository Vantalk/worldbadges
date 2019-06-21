defmodule WorldbadgesWeb.CurrentPersona do
  import Plug.Conn
  import Guardian.Plug

  def init(opts), do: opts

  def call(conn, _opts) do
    persona = current_resource(conn)
    assign(conn, :current_persona, persona)
  end
end
