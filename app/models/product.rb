class Product < ActiveRecord::Base

	def self.get_products
		response = HTTParty.get("https://sandbox-api.uber.com/v1/products?latitude=12.9539598&longitude=77.57757&server_token=d6H3MMHCv0ZRNmQMPytWC82vPzbmZW2-N8sPvs6b")
		if response.present? && response["products"].present?
			response["products"].each do |product|
				Product.create(:name => product["display_name"], :uber_id => product["product_id"]) rescue nil
			end
		end
	end

end
