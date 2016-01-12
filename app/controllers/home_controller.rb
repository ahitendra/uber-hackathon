class HomeController < ApplicationController
  def access_token
    access_token = params[:access_token]
    binding.pry

    # Call the API get user info and save into User Model
    render json: { status: 'success' }
  end
end
