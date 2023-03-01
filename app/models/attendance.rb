class Attendance < ApplicationRecord
  belongs_to :user
  has_many :breaks , dependent: :destroy 
  default_scope -> { order(created_at: :desc) }
  validates :user_id, presence: true
end
