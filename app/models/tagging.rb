class Tagging < ApplicationRecord
  belongs_to :breed
  belongs_to :tag

  after_destroy :remove_orphans

  private
  def remove_orphans
    tag.destroy if tag.breeds.count == 0
  end
end
