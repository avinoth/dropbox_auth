class AuthController < ApplicationController
  require 'dropbox_sdk'

  def login
    authorize_url = dropbox_auth.start()
    redirect_to authorize_url
  end

  def dropbox_callback
    access_token, user_id, url_state = dropbox_auth.finish(params)
    session[:access_token] = access_token
    user = DropboxClient.new(access_token).account_info
    validate_user user
    redirect_to root_path
  end

  def logout
    session.delete(:current_user)
    redirect_to root_path
  end

  private

  def validate_user user
    existing_user = User.find_by(email: user["email"])
    if existing_user.present?
      session[:current_user] = existing_user.name
    else
      new_user = User.create(name: user["display_name"], dropbox_uid: user["uid"], email: user["email"], dropbox_token: session[:access_token])
      session[:current_user] = new_user.name
    end
  end

  def dropbox_auth
   redirect_uri = url_for :controller => 'auth', :action => 'dropbox_callback'
   DropboxOAuth2Flow.new(ENV['APP_KEY'], ENV['APP_SECRET'], redirect_uri, session, :dropbox_auth_csrf_token)
 end
end
