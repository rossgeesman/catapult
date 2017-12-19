class Breed < ApplicationRecord
  has_many :taggings
  has_many :tags, through: :taggings, dependent: :destroy
  validates_presence_of :name
  validates_uniqueness_of :name

  def tag_count
    tags.count
  end

  def tag_ids
    tags.pluck(:id)
  end
end
