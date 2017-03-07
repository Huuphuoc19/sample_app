class Micropost < ApplicationRecord
  belongs_to :user
  default_scope -> { order(created_at: :desc) }
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  mount_uploader :picture, PictureUploader
  validate  :picture_size

  private
    def picture_size
      size = 5
      if picture.size > size.megabytes
        errors.add(:picture, "should be less than #{size}MB")
      end
    end

end
