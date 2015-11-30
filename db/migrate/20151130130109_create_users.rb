class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.integer :dropbox_uid
      t.string :email
      t.string :dropbox_token

      t.timestamps null: false
    end
  end
end
