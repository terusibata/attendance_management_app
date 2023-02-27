class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :name
      t.string :password_digest
      t.string :email
      t.date :hire_date
      t.date :end_date
      t.boolean :admin, default: false

      t.timestamps
    end
  end
end
