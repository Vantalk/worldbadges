defmodule WorldbadgesWeb.ChannelsShared do

  alias Worldbadges.{
    Accounts.Persona,
    Groups,
    Repo
  }

  import WorldbadgesWeb.Shared, only: [allocate_name: 0, file_path: 0, link_for_file: 1, upload_encoded_data: 3]

  def current_persona(socket) do
    Repo.get(Persona, persona_id(socket))
  end

  def persona_id(socket) do
    socket.assigns.guardian_default_claims["sub"]
    |> String.split(":")
    |> List.last
  end

  def subtopic(socket) do
    socket.topic
    |> String.split(":")
    |> List.last()
  end

  def subtopic_group(socket) do
    socket.topic
    |> String.split(":")
    |> List.last()
    |> String.split("_")
    |> List.first()
  end

  def view_page?(socket, subtopic) do
    true
    # TODO: update this (param :name is now used in most places. Should probably rename param for badge/user pages or handle better)
    # if subtopic == "" do
    #   true
    # else
    #   page_name = subtopic |> String.replace("_", " ")
    #   page = Groups.get_page_by_name!(page_name)
    #   user = current_user(socket)
    #   page.public_view || (user && Worldbadges.Groups.page_member?(page.id, user.id))
    # end
  end

  def get_article_data_from_content(content, upload, prev_data) do
    # image_regex = ~r"([(http(s)?):\/\/(www\.)?-a-zA-Z0-9@:%._\+~#=]{2,256}\.(jpg|jpeg|gif|png|bmp|tiff|tga|svg)\b[-a-zA-Z0-9@:;%_\+.~#?&//=]*)"i
    regex = ~r"([(http(s)?):\/\/(www\.)?-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b[-a-zA-Z0-9@:;%_\+.~#?&//=]*)"i
    uri = Regex.run(regex, content); uri = if uri, do: List.first(uri)

    # HANDLE URI DATA %{image, link}
    uri_data = if uri, do: get_uri_data(uri)
    uri_data = if uri_data, do: uri_data, else: %{}

    # HANDLE UPLOAD
    # TODO check file type before uploading. Can be a security issue
    upload_data = if upload do
      save_name = if prev_data["upload"] do
        String.replace(prev_data["upload"], file_path(), "")
      else
        extension = String.split(upload["name"], ".") |> List.last()
        "#{allocate_name()}.#{extension}"
      end

      upload_encoded_data(:file, upload["encoding"], save_name)
      upload_type = if upload["type"] in ["image/jpeg", "image/png"], do: "upload_image", else: "upload"

      %{upload_type => link_for_file(save_name), "upload_name" => upload["name"]}
    else
      if prev_data, do: Map.drop(prev_data, ["token", "image", "link", "title"]), else: %{}
    end

    data = Map.merge(uri_data, upload_data)
    content = if uri == String.trim(content) && data, do: nil, else: content

    {content, data}
  end

  defp get_uri_data(uri) do
    cond do
      Regex.match?(~r/^(http(s)?):\/\/(www\.)youtube\.com\/watch\?v=\w/i, uri) ->
        token = String.split(uri, "?") |> List.last() |> String.split("&") |> List.first() |> String.replace_prefix("v=", "")
        %{"token" => token}
      Regex.match?(~r/^(http(s)?):\/\/youtu\.be\/\w/i, uri) ->
          token = URI.parse(uri).path |> String.replace_prefix("/", "")
          %{"token" => token}
      Regex.match?(~r/(.jpg|.gif|.png|.jpeg)$/, uri) -> %{"image" => uri, "link" => uri}
      true ->
        case HTTPoison.get(uri) do
          {:ok, response} ->
            meta = cond do
              Floki.find(response.body, "[property='og:image']") != [] -> "og"
              Floki.find(response.body, "[property='twitter:image']") != [] -> "twitter"
              true -> nil
            end

            if meta do
              image = Floki.find(response.body, "[property='#{meta}:image']") |> Floki.attribute("content") |> List.first()
              title = Floki.find(response.body, "[property='#{meta}:title']") |> Floki.attribute("content") |> List.first()
              link  = Floki.find(response.body, "[property='#{meta}:url']") |> Floki.attribute("content") |> List.first()
              link = if link, do: link, else: uri
              %{"image" => image, "link" => link, "title" => title}
            end
          {:error, _} -> nil
        end
    end
  end
end
