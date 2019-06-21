defmodule WorldbadgesWeb.Router do
  use WorldbadgesWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :with_session do
    plug Guardian.Plug.VerifySession
    plug Guardian.Plug.LoadResource
    plug WorldbadgesWeb.CurrentPersona
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :login_required do
    plug Guardian.Plug.EnsureAuthenticated, handler: WorldbadgesWeb.GuardianErrorHandler
  end

  scope "/", WorldbadgesWeb do
    pipe_through [:browser, :with_session] # Use the default browser stack

    # registered user zone
    scope "/" do
      pipe_through [:login_required]

      get "/", PageController, :index

      resources "/ad",           AdController, except: [:show, :edit, :update]
      resources "/article",     ArticleController, except: [:show]
      resources "/comment",      CommentController
      resources "/delete_task", DeleteTaskController
      resources "/interest_article", InterestArticleController
      resources "/notifications", NotificationController
      resources "/privacy",      PrivacyController, except: [:index]
      resources "/style",       StyleController
      resources "/badge",       BadgeController, except: [:edit, :update]

      get "/ads/:name",          AdController, :show
      get "/ads/:ad_name/edit",       AdController, :edit
      patch "/ad/:name",         AdController, :update
      put "/ad/:name",           AdController, :update
      get "/badge/:name/edit",   BadgeController, :edit
      patch "/badge/:name",      BadgeController, :update
      put "/badge/:name",        BadgeController, :update
      get "/civic_ads/:name",    AdController, :show
      get "/civic_ads/:civic_ad_name/edit", AdController, :edit
      # get "/group/new",          GroupController, :new
      # get "/page_groups/:name/edit", GroupController, :edit_page_group
      # get "/persona_groups/:name/edit", GroupController, :edit_persona_group
      # post "/create_group",      GroupController, :create
      # put "/create_group",      GroupController, :create
      # patch "/group/:name",          GroupController, :update
      # put "/group/:name",            GroupController, :update
      get "/page/new",           PageController, :new
      post "/page",              PageController, :create
      get "/page/:name/edit",    PageController, :edit
      patch "/page/:name",       PageController, :update
      put "/page/:name",         PageController, :update
      resources "/pending_articles", PendingArticleController
      post "/change_image",      PersonaController, :change_image
      # get "/invite",             PersonaController, :invite
      get "/remove_persona_from_page",        PersonaController, :remove_persona_from_page
      # get "/accept_join",        PersonaController, :accept_join
      # get "/reject_join",        PersonaController, :reject_join
      # get "/revoke_invitation",  PersonaController, :revoke_invitation
      get "/persona/:id/edit",   PersonaController, :edit
      get "/persona/:id/change_persona",     PersonaController, :change_persona
      get "/persona/change_persona", PersonaController, :change_persona
      get "/persona/create",     PersonaController, :create
      post "/save_preferences",  PersonaController, :save_preferences
      get "/search_non_members", PersonaController, :search_non_members
      patch "/persona_update",   PersonaController, :update
      put   "/persona_update",   PersonaController, :update
      get "/creation_panel",     SharedController, :creation_panel
      get "/delete/:type/:name", SharedController, :delete
      get "/get_list/:type",     SharedController, :get_list
      get "/notifications_settings",      SharedController, :notifications_settings
      get "/profile_edit",       SharedController, :profile_edit
      get "/access_settings",    SharedController, :access_settings
      get "/delete_account",     UserController, :delete_account
      get "/reserve_account/:months",    UserController, :reserve_account
      get "/revoke_account_deletion",    UserController, :revoke_account_deletion
      patch "/user_update",      UserController, :update
      put   "/user_update",      UserController, :update
    end

    # TODO remove unused routes

    post "/create_case", SharedController, :create_case
    get "/help", SharedController, :help
    get "/help_form", SharedController, :help_form
    get "/news", SharedController, :news

    resources "/message",     MessageController
    resources "/session",     SessionController, only: [ :new, :create, :delete ]


    # resources "/add_contacts", AddContactController

    # resources "/badge_group", BadgeGroupController
    # resources "/blocked",     BlockedController
    # resources "/chat",        ChatController

    # resources "/contact",     ContactController



    # # resources "/page",        PageController, except: [:show, :edit]
    # resources "/page_group",  PageGroupController, except: [:show, :edit]


    # resources "/user_group",  UserGroupController, except: [:show, :edit]

    get "/search",             PageController, :search

    get "/user/new",   UserController, :new
    post "/user",      UserController, :create

    get "/persona/:id",             PersonaController, :show
    get "/persona/:id/:article_id", PersonaController, :show
    get "/page/:name",              PageController,    :show
    get "/page/:name/:article_id",  PageController,    :show
    get "/page/:name/:article_id/:comment_id", PageController, :show
  end

  # Other scopes may use custom stacks.
  # scope "/api", WorldbadgesWeb do
  #   pipe_through :api
  # end
end
