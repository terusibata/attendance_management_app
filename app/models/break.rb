class Break < ApplicationRecord
  belongs_to :attendance
  validates :attendance_id, presence: true
end
