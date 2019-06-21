defmodule WorldbadgesWeb.CommentView do
  use WorldbadgesWeb, :view

  alias Worldbadges.Posting
  import WorldbadgesWeb.Shared, only: [default_limit: 0, image_for_persona: 1, persona_image: 1]

  def scrollData(comments) do
    if is_nil(comments) do
      [nil, "true", "true",]
    else
      first_comment = List.first(comments)
      last_comment  = List.last(comments)

      a_id  = if first_comment, do: first_comment.article_id
      fc_id = if first_comment, do: first_comment.id, else: "true"
      lc_id = if last_comment,  do: last_comment.id,  else: "true"

      [a_id, fc_id, lc_id]
    end
  end

  # def render("comments", %{article_id: article_id, comments: comments, editable: editable, scroll_bwd: scroll_bwd}) do
  #   html = Enum.reduce(comments, "", fn(comment, acc) ->
  #     {comment_id, content, inserted_at, persona_image, persona_name} = comment
  #
  #     Phoenix.View.render_to_string(__MODULE__, "_comment.html",
  #       comment_id: comment_id,
  #       content: content,
  #       inserted_at: inserted_at,
  #       persona_image: persona_image(persona_image),
  #       persona_name:  persona_name
  #     ) <> acc
  #   end)
  #
  #   %{article_id: article_id, html: html, scroll_bwd: scroll_bwd}
  # end

  # def render("comment", %{comment: comment}) do
  #   {comment_id, content, inserted_at, persona_image, persona_name} = comment
  #
  #   Phoenix.View.render_to_string(__MODULE__, "_comment.html",
  #     # editable: editable,
  #     comment_id: comment_id,
  #     content: content,
  #     inserted_at: inserted_at,
  #     persona_image: persona_image(persona_image),
  #     persona_name: persona_name
  #   )
  # end

  # def render("new_comment", %{comment: comment, persona: persona}) do
  #   Phoenix.View.render_to_string(__MODULE__, "_comment.html",
  #     comment_id: comment.id,
  #     content: comment.content,
  #     persona_image: image_for_persona(persona),
  #     persona_name: persona.name
  #   )
  # end

  # TODO: check if better use struct
  # def persona_image_for(comment) do
  #   elem(comment, 2)
  # end
  #
  # def content_for(comment) do
  #   elem(comment, 1)
  # end
  #
  # def persona_link_for(comment) do
  #    "#{elem(comment, 4)} #{elem(comment, 3)}"
  # end
end
