class Tag < ApplicationRecord
  has_many :taggings
  has_many :breeds, through: :taggings, dependent: :destroy

  def breed_count
    breeds.count
  end

  def breed_ids
    breeds.pluck(:id)
  end
end
