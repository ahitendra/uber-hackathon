class SmsController < ApplicationController

  def receive_sms
    phone = params[:From]
    @user = User.where(phone: phone).last
    token = @user.auth_token
    # make a call to uber depending on the text contents
    # 'params[:Body]' has the sms content
    
    # *** if we want to send acknowledgement sms ***
    # response = 'Message received.'
    # twiml = Twilio::TwiML::Response.new do |r|
    #   r.Message respnose
    # end
    # twiml.text
    book_uber
  end

  private

  def book_uber
    body = params[:Body].split(",") if params[:Body].present?
    if body.present? and body.first.include?("book")
      start_latitude  = body[1].include?("lat") && body[1].split(":")[1]
      start_longitude = body[2].include?("lng") && body[2].split(":")[1]
      product_name    = body[3].include?("product") && body[3].split(":")[1]
      product         = product_name.include?("any") ? Product.where("name = #{product}").last : nil
      product_id      = product.present? ? product.uber_id : nil
      book_params = {
          :start_latitude => start_latitude,
          :start_longitude => start_longitude,
      }
      book_params.merge!({:product_id => product_id}) if product_id.present?
      book_params.merge1({:token => @user.auth_token})
      book_response = @user.book_uber(book_params)
    end
  end

end
