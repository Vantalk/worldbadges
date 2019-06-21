defmodule WorldbadgesWeb.ArticleView do
  use WorldbadgesWeb, :view

  import WorldbadgesWeb.Shared, only: [image_for_badge: 1, image_for_page: 1, image_for_persona: 1, link_for_page: 1, link_for_persona: 1]

  def page_image_for(article) do
    if article.page, do: image_for_page(article.page),
    else: image_for_persona(article.persona)
  end

  def page_for(article, conn) do
    if article.page, do: page_path(conn, :show, article.page.name),
    else: link_for_persona(article.persona)
  end

  def article_image(image) do
    String.replace(image, " ", "+")
  end
end
