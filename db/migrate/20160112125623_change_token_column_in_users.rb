class ChangeTokenColumnInUsers < ActiveRecord::Migration
  def change
    change_column :users, :auth_token, :text, limit: nil
  end
end
