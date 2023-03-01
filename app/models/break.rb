class Break < ApplicationRecord
  belongs_to :attendance
  validates :attendance_id, presence: true
  default_scope -> { order(created_at: :desc) }
end
