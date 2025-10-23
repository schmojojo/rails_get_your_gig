class Message < ApplicationRecord
  validates :content, length: { in: 6..1000 }
end
