class SmsController < ApplicationController

  def receive_sms
    phone = params['From']
    puts params['From'].to_s + "*************************"
    @user = User.where(phone: phone).last
    # make a call to uber depending on the text contents
    # 'params[:Body]' has the sms content
    
    # *** if we want to send acknowledgement sms ***
    # response = 'Message received.'
    # twiml = Twilio::TwiML::Response.new do |r|
    #   r.Message respnose
    # end
    # twiml.text
    book_uber
    render json: { status: 'success' }
  end

  private

  def book_uber
    response = @user.book_uber(params)
  end

end
