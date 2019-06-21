defmodule WorldbadgesWeb.Auth do
  import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]
  require Logger

  alias Worldbadges.Accounts.User
  alias Worldbadges.Repo

  def login(conn, user) do
    persona = Worldbadges.Accounts.get_persona!(user.pid)
    Guardian.Plug.sign_in(conn, persona)
  end

  def login_by_key_and_pass(conn, key, given_pass) do
    if key && given_pass do
      user = Repo.get_by(User, key: String.trim(key))

      cond do
        user && checkpw(given_pass, user.password_hash) ->
          {:ok, login(conn, user)}
        user && !checkpw(given_pass, user.password_hash) ->
          # Logger.error "Could not connect. Password doesn't match for user with email: #{email}"
          {:error, "Key/Password invalid", conn}
        true ->
          # Logger.error "User not found with email: #{email}"
          dummy_checkpw
          {:error, "Key/Password invalid", conn}
      end
    else
      Logger.warn "No key or pass provided"
      dummy_checkpw
      {:error, "Key/Password invalid", conn}
    end
  end
  # def login_by_email_and_pass(conn, email, given_pass) do
  #   if email do
  #     user = Repo.get_by(User, email: String.trim(email))
  #
  #     cond do
  #       user && checkpw(given_pass, user.password_hash) ->
  #         {:ok, login(conn, user)}
  #       user && !checkpw(given_pass, user.password_hash) ->
  #         Logger.error "Could not connect. Password doesn't match for user with email: #{email}"
  #         {:error, "Email/Parola invalida", conn}
  #       true ->
  #         Logger.error "User not found with email: #{email}"
  #         dummy_checkpw
  #         {:error, "Email/Parola invalida", conn}
  #     end
  #   else
  #     Logger.warn "No email provided"
  #     dummy_checkpw
  #     {:error, "Email/Parola invalida", conn}
  #   end
  # end

  def logout(conn) do
    Guardian.Plug.sign_out(conn)
  end
end
