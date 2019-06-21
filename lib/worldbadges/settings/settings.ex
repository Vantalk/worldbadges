defmodule Worldbadges.Settings do
  @moduledoc """
  The Settings context.
  """

  import Ecto.Query, warn: false
  alias Worldbadges.Repo

  alias Worldbadges.Settings.Privacy

  @doc """
  Returns the list of privacy.

  ## Examples

      iex> list_privacy()
      [%Privacy{}, ...]

  """
  def list_privacy do
    Repo.all(Privacy)
  end

  @doc """
  Gets a single privacy.

  Raises `Ecto.NoResultsError` if the Privacy does not exist.

  ## Examples

      iex> get_privacy!(123)
      %Privacy{}

      iex> get_privacy!(456)
      ** (Ecto.NoResultsError)

  """
  def get_privacy!(id), do: Repo.get!(Privacy, id)

  @doc """
  Creates a privacy.

  ## Examples

      iex> create_privacy(%{field: value})
      {:ok, %Privacy{}}

      iex> create_privacy(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_privacy(attrs \\ %{}) do
    %Privacy{}
    |> Privacy.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  TODO
  Updates a privacy.

  ## Examples

      iex> update_privacy(privacy, %{field: new_value})
      {:ok, %Privacy{}}

      iex> update_privacy(privacy, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_privacy(persona_id, attrs) do
    Repo.get_by!(Privacy, persona_id: persona_id)
    |> Privacy.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Privacy.

  ## Examples

      iex> delete_privacy(privacy)
      {:ok, %Privacy{}}

      iex> delete_privacy(privacy)
      {:error, %Ecto.Changeset{}}

  """
  def delete_privacy(%Privacy{} = privacy) do
    Repo.delete(privacy)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking privacy changes.

  ## Examples

      iex> change_privacy(privacy)
      %Ecto.Changeset{source: %Privacy{}}

  """
  def change_privacy(%Privacy{} = privacy) do
    Privacy.changeset(privacy, %{})
  end

  alias Worldbadges.Settings.Style

  @doc """
  Returns the list of styles.

  ## Examples

      iex> list_styles()
      [%Style{}, ...]

  """
  def list_styles do
    Repo.all(Style)
  end

  @doc """
  Gets a single style.

  Raises `Ecto.NoResultsError` if the Style does not exist.

  ## Examples

      iex> get_style!(123)
      %Style{}

      iex> get_style!(456)
      ** (Ecto.NoResultsError)

  """
  def get_style!(id), do: Repo.get!(Style, id)

  @doc """
  Creates a style.

  ## Examples

      iex> create_style(%{field: value})
      {:ok, %Style{}}

      iex> create_style(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_style(attrs \\ %{}) do
    %Style{}
    |> Style.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  TODO
  Updates a style.

  ## Examples

      iex> update_style(style, %{field: new_value})
      {:ok, %Style{}}

      iex> update_style(style, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_style(persona_id, attrs) do
    Repo.get_by!(Style, persona_id: persona_id)
    |> Style.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Style.

  ## Examples

      iex> delete_style(style)
      {:ok, %Style{}}

      iex> delete_style(style)
      {:error, %Ecto.Changeset{}}

  """
  def delete_style(%Style{} = style) do
    Repo.delete(style)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking style changes.

  ## Examples

      iex> change_style(style)
      %Ecto.Changeset{source: %Style{}}

  """
  def change_style(%Style{} = style) do
    Style.changeset(style, %{})
  end
end
