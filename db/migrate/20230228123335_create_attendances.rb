class CreateAttendances < ActiveRecord::Migration[7.0]
  def change
    create_table :attendances do |t|
      t.references :user, null: false, foreign_key: true
      t.date :work_day
      t.time :start_time
      t.time :end_time
      t.boolean :protection, default: false

      t.timestamps
    end
    add_index :attendances, [:user_id, :work_day], unique: true
  end
end
