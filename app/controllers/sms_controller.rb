class SmsController < ApplicationController

  def receive_sms
    phone = params[:From]
    token = User.get_auth_token(phone)
    # make a call to uber depending on the text contents
    # 'params[:Body]' has the sms content
    
    # *** if we want to send acknowledgement sms ***
    # response = 'Message received.'
    # twiml = Twilio::TwiML::Response.new do |r|
    #   r.Message respnose
    # end
    # twiml.text
  end

end
