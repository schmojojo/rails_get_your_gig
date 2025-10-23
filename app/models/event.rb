class Event < ApplicationRecord
  belongs_to :user
  has_one_attached :photo

  validates :title, presence: true
  validates :date, presence: true
  validates :category, presence: true

  validates :category, inclusion: { in: %w(Entertainment Education Work-Related Personal)}
end
