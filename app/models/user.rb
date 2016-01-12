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
    params = User.get_book_params(params)
    token = self.auth_token
    begin
      response = RestClient::Request.execute(:url => url, :headers => {:Authorization => token, 'Content-Type' => 'application/json'},:ssl_version => 'TLSv1_2', :method => 'post', :payload => params)
      self.update_booking(JSON.parse(response)) if response
    rescue Exception => e
      response = nil
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

  def self.get_book_params(params)
    body = params['Body'].to_s.split(",") if params['Body'].present?
    if body.present? and body.first.include?("book")
      start_latitude  = body[1].include?("lat") && body[1].split(":")[1]
      start_longitude = body[2].include?("lng") && body[2].split(":")[1]
      product_name    = body[3].split(":")[1]
      product         = product_name.include?("any") ? Product.where("name = #{product}").last : nil
      product_id      = product.present? ? product.uber_id : nil
      book_params = {
          :start_latitude => start_latitude,
          :start_longitude => start_longitude,
      }
      book_params.merge!({:product_id => product_id}) if product_id.present?
      return book_params
    end
  end

  def update_booking(details)
    if details.present? && details["request_id"].present?
      final_response = nil
      url = "https://sandbox-api.uber.com/v1/sandbox/requests/#{details["request_id"]}"
      data = {"status" => "accepted"}
      response = RestClient::Request.execute(:url => url, :headers => {:Authorization => self.auth_token, 'Content-Type' => 'application/json' }, :ssl_version => 'TLSv1_2', :method => 'put', :payload => data.to_json)
      if response.present?
        url = "https://sandbox-api.uber.com/v1/requests/#{details["request_id"]}"
        final_response = RestClient::Request.execute(:url => url, :headers => {:Authorization => self.auth_token, 'Content-Type' => 'application/json' }, :ssl_version => 'TLSv1_2', :method => 'get')
      end
      if final_response.present?
        final_response = JSON.parse(final_response)
        sms_text = "Driver name: #{final_response["driver"]["name"]}, Number: #{final_response["driver"]["phone_number"]}, Vehicle name: #{final_response["vehicle"]["make"]} #{final_response["vehicle"]["model"]}, license_plate, Licence number: #{final_response["vehicle"]["license_plate"]}" 
        self.self.sendsms(self.phone, sms_text)
      end
    end
  end

end
