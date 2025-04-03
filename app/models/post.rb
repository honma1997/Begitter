class Post < ApplicationRecord
  belongs_to :user

  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :post_tags, dependent: :destroy
  has_many :tags, through: :post_tags

  # ActiveStorage
  has_one_attached :image

  # バリデーション
  validates :title, presence: true
  validates :body, presence: true
end
