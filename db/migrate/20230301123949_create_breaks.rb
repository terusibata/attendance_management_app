class CreateBreaks < ActiveRecord::Migration[7.0]
  def change
    create_table :breaks do |t|
      t.references :attendance, null: false, foreign_key: true
      t.time :start_time
      t.time :end_time

      t.timestamps
    end
    add_index :breaks, [:attendance_id, :start_time]
  end
end
