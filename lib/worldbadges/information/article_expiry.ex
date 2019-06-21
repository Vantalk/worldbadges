defmodule Worldbadges.Information.ArticleExpiry do
  use Ecto.Schema
  import Ecto.Changeset
  alias Worldbadges.Information.ArticleExpiry


  schema "article_expiry" do
    # TODO: expiry at according to log_time; add cron to clean
    field :date, Timex.Ecto.DateTime
    field :article_id, :id

    timestamps()
  end

  @doc false
  def changeset(%ArticleExpiry{} = article_expiry, attrs) do
    article_expiry
    |> cast(attrs, [:date, :article_id])
    |> validate_required([:date, :article_id])
  end
end
