class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email, :null => false, :unique => true
      t.string :facebook_id, :null => false, :unique => true

      t.timestamps
    end
  end
end
