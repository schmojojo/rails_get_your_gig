class Message < ApplicationRecord
  validates :content, length: { in: 6..1000 }, if: -> { role == "user"}
end
