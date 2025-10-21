class Event < ApplicationRecord
  belongs_to :user

  validates :title, presence: true
  validates :date, presence: true
  validates :category, presence: true
  
  validates :category, inclusion: { in: %w(entertainment education work-related personal)}
end
