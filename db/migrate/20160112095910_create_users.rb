class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :auth_token, null: false
      t.string :phone, null: false
      t.string :first_name
      t.string :last_name
      t.string :picture
      t.string :promo_code
      t.string :uuid
      t.timestamps null: false
    end
    add_index :users, :email,                :unique => true
    add_index :users, :phone,                :unique => true
    add_index :users, :auth_token,           :unique => true
  end
end
