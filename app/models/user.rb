class User < ActiveRecord::Base

  def get_auth_token(phone)
    User.where(phone: phone).last.auth_token rescue nil
  end

  @account_sid = 'AC1a61a323b5eeff094ce746f3bfdf2d52'
  @auth_token = 'bf096484012c84c791bdb2483e67e494'
  @twilio_number = '+14134183825'

  def self.sendsms(phone_number, message)     
    # set up a client to talk to the Twilio REST API 
    @client = Twilio::REST::Client.new @account_sid, @auth_token
     
    @client.account.messages.create({
      :from => @twilio_number, 
      :to => phone_number,
      :body => message
    })
    # twiml = Twilio::TwiML::Response.new do |r|
    #   r.Message "Sample text.Thanks for the message!"
    # end
    # render xml: twiml.text
  end

  def book_uber(params)
    url = "https://sandbox-api.uber.com/v1/requests"
    begin
      response = RestClient::Request.execute(:url => url, :ssl_version => 'TLSv1_2', :method => 'post', :payload => params)
    rescue Exception => e
      response = nil
      puts e.to_s
    end
    JSON.parse(response) if response
  end
  
  def self.get_info(access_token)
    url = "https://api.uber.com/v1/me"
    begin
      response = RestClient::Request.execute(
        url: url, 
        ssl_version: 'TLSv1_2', 
        method: 'get', 
        scope: 'profile', 
        headers: {Authorization: "Bearer #{access_token}"}
      )
      resp = JSON.parse(response)
      User.create_or_update_user(resp, access_token)
    rescue Exception => e
      puts e.to_s
      response = nil
    end
  end

  def self.create_or_update_user(resp, access_token)
    user = User.where(email: resp['email']).first
    user = User.new if user.blank?
    user.auth_token = access_token
    user.picture = resp['picture']
    user.email = resp['email']
    user.first_name = resp['first_name']
    user.last_name = resp['last_name']
    user.promo_code = resp['promo_code']
    user.uuid = resp['uuid']
    user.phone = '0' if user.phone.blank?
    user.save
  end

end
