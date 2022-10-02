class Book < ApplicationRecord
  include PgSearch::Model
  multisearchable against: [:title, :subtitle, :description]

  belongs_to :publisher, required: false
  belongs_to :author

  validates :title, presence: true
  validates :released_on, presence: true
  validates :author, presence: true

  validates :isbn_10, presence: true, uniqueness: true, length: { is: 10 }
  validates :isbn_13, presence: true, uniqueness: true, length: { is: 13 }

  mount_base64_uploader :cover, CoverUploader
end
