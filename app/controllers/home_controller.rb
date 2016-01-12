class HomeController < ApplicationController
  def access_token
    token = params[:access_token]

    # Call the API get user info and save into User Model
    User.get_info(access_token)
    render json: { status: 'success' }
  end
end
