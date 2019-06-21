defmodule WorldbadgesWeb.GuardianSerializer do
  @behaviour Guardian.serializer

  alias Worldbadges.Repo
  alias Worldbadges.Accounts.User
  alias Worldbadges.Accounts.Persona

  def for_token(persona = %Persona{}), do: {:ok, "Persona:#{persona.id}"}
  def for_token(_), do: {:error, "Unknown resource type"}

  def from_token("Persona:" <> id), do: {:ok, Repo.get(Persona, id)}
  def from_token(_), do: {:error, "Unknown resource type"}
end
