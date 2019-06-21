defmodule WorldbadgesWeb.Shared do

  @default_limit 15
  @default_page_limit 3

  @bucket_name "plat"
  @host "sfo2.digitaloceanspaces.com"

  @get_ad_path "https://#{@bucket_name}.#{@host}/ads/"
  @get_badge_base_path "https://#{@bucket_name}.#{@host}/base/"
  @get_badge_path "https://#{@bucket_name}.#{@host}/badges/"
  @get_profile_path "https://#{@bucket_name}.#{@host}/profiles/"
  @get_posted_file_path "https://#{@bucket_name}.#{@host}/files/"

  @upload_ad_path "#{@bucket_name}/ads/"
  @upload_badge_base_path "#{@bucket_name}/base/"
  @upload_badge_path "#{@bucket_name}/badges/"
  @upload_profile_path "#{@bucket_name}/profiles/"
  @upload_posted_file_path "#{@bucket_name}/files/"

  def admin?(persona_id, page) do
    persona_id in page.roles["admins"]
  end

  def allocate_name() do
    file_name = UUID.uuid4(:hex)
    # if Worldbadges.Accounts.profile_image_exists?(file_name) do
    #   allocate_name(path)
    # else
    #   file_name
    # end
  end

  def article_link(article_id, page_name) do
    "/page/#{page_name}/#{article_id}"
  end

  def base_image(name) do
    "#{@get_badge_base_path}#{name}.jpg"
  end

  def contact_ids(contact) do
    contact.groups |> Map.values() |> List.flatten |> Enum.uniq()
  end

  def decode_file(input) do
    {start, length} = :binary.match(input, ";base64,")
    raw = :binary.part(input, start + length, byte_size(input) - start - length)
    Base.decode64!(raw)
  end

  def default_limit do
    @default_limit
  end

  def default_page_limit do
    @default_page_limit
  end

  def delete_file(type, file_name) do
    ExAws.S3.delete_object(s3_path(type), file_name) |> ExAws.request(host: @host)
  end

  def file_path do
    @get_posted_file_path
  end

  def get_persona(conn) do
    conn.assigns[:current_persona]
  end

  def is_mobile?(conn) do
    Enum.find(conn.req_headers, fn {x,y} -> x == "user-agent" end)
    |> elem(1) |> Device.is_phone?
  end

  def image_for_ad(ad) do
    "#{@get_ad_path}#{ad.image}.jpg"
  end

  def image_for_badge(badge) do
    "#{@get_badge_path}#{badge.image}.jpg"
    # |> String.replace(" ", "_") # removed for persona edit
  end

  def image_for_page(page) do
    page_image(page.image)
  end

  def image_for_persona(persona) do
    persona_image(persona.image)
  end

  def link_for_file(name) do
    "#{@get_posted_file_path}#{name}"
  end

  def link_for_page(page) do
    page_name_link(page.name)
  end

  def link_for_persona(persona) do
    "/persona/#{persona.id}"
  end

  def mod?(persona_id, page) do
    persona_id in page.roles["mods"]
  end

  def mod_or_admin?(persona_id, page) do
    persona_id in page.roles["mods"] || persona_id in page.roles["admins"]
  end

  def page_name_link(page_name) do
    "/page/#{page_name}"
    |> String.replace(" ", "_")
  end

  def page_image(page_image) do
    "#{@get_badge_path}#{page_image}.jpg"
  end

  def parse_name(name) do
    name |> String.replace(" ", "_")
  end

  def persona_image(name) do
    "#{@get_profile_path}#{name}.jpg"
  end

  def unparse_name(name) do
    name |> String.replace("_", " ") |> String.trim()
  end

  def upload_encoded_data(type, input, file_name) do
    upload_binary(type, decode_file(input), file_name)
  end

  def upload_image(type, file_path, file_name) do
    upload_file(type, file_path, file_name<>".jpg")
  end

  def upload_file(type, file_path, file_name) do
    {:ok, file_binary} = File.read(file_path)
    upload_binary(type, file_binary, file_name)
  end

  def upload_binary(type, file_binary, file_name) do
    # TODO dev/test paths
    # File.write!("#{@badge_path}#{name}.jpg", file_binary) - local

    # TODO look up async upload (to multiple buckets on voting platforma)
    # if Mix.env == "prod" do
      s3_operation =
        ExAws.S3.put_object(s3_path(type), file_name, file_binary)
        |> Map.put(:headers, %{"x-amz-acl" => "public-read"}) # makes file publicly available; this is done here because can not seem to overwrite headers from ExAws.request

      IO.inspect s3_operation

      IO.inspect ExAws.request(s3_operation, host: @host)
    # else
    #   File.copy!(file.path, "#{path}#{file_name}.jpg") # TODO
    # end
  end

  def urlify(content) do
    # regex   = ~r"([(http(s)?):\/\/(www\.)?-a-zA-Z0-9@:%._\+~#=]{2,256}\.(jpg|jpeg|gif|png|bmp|tiff|tga|svg)\b[-a-zA-Z0-9@:;%_\+.~#?&//=]*)"i
    # content = Regex.replace(regex, content, fn _, uri -> "<img src='#{uri}' alt='#{uri}' class='article-img'>" end, global: false)

    # regex = ~r"(((src|alt)=.)?[(http(s)?):\/\/(www\.)?-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b[-a-zA-Z0-9@:;%_\+.~#?&//=]*)"i
    regex = ~r"([(http(s)?):\/\/(www\.)?-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b[-a-zA-Z0-9@:;%_\+.~#?&//=]*)"i
    Regex.replace(regex, content, fn _, uri -> "<a href='#{uri}' target='_blank'>#{uri}</a>" end)
  end

  # defp url_or_image(uri) do
  #   cond do
  #     Regex.match?(~r/(src|alt)=./, uri) -> uri
  #     # Regex.match?(~r/(.jpg|.gif|.png|.jpeg)$/, uri) -> uri
  #     true -> "<a href='#{uri}' target='_blank'>#{uri}</a>"
  #   end
  # end

  def page_membership_actions(action, page) do
    case action do
      "accept_invite"   ->
        "<a href='#' class='btn btn-xs main-bg' style='margin-left:2em;' onclick=\"personaToPageAction('accept_invite', this, '#{parse_name(page.name)}')\">" <>
          "Accept invite" <>
        "</a>"

      "cancel_request"  ->
        "<a href='#' class='btn btn-xs main-bg' style='margin-left:2em;' onclick=\"personaToPageAction('cancel_request', this, '#{parse_name(page.name)}')\">" <>
          "Cancel join request" <>
        "</a>"

      "reject_invite"   ->
        "<a href='#' class='btn btn-xs main-bg' style='margin-left:5px;' onclick=\"personaToPageAction('reject_invite', this, '#{parse_name(page.name)}')\">" <>
          "Reject invite" <>
        "</a>"

      "request_join"    ->
        "<a href='#' class='btn btn-xs main-bg' style='margin-left:2em;' onclick=\"personaToPageAction('request_join', this, '#{parse_name(page.name)}')\">" <>
          "Request to join" <>
        "</a>"

      "unsubscribe"     ->
        "<a href='#' class='btn btn-xs main-bg' style='margin-left:2em;' onclick=\"personaToPageAction('unsubscribe', this, '#{parse_name(page.name)}')\">" <>
          "Unsubscribe" <>
        "</a>"
    end
  end

  defp s3_path(type) do
    case type do
      :ad      -> @upload_ad_path
      :base    -> @upload_badge_base_path
      :badge   -> @upload_badge_path
      :profile -> @upload_profile_path
      :file    -> @upload_posted_file_path
    end
  end
end
