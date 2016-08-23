class Banner < ActiveRecord::Base
  enum record_type: { "category": 0, "item": 1 }

  after_create :generate_url

  belongs_to :bannerable, polymorphic: true

  scope :recent, -> { order(id: :DESC) }

  mount_uploader :image, OriginalPicUploader

  private

  def generate_url
    baes_url = "https://www.mmwooo.com"

    if record_type == "category"
      category = bannerable
      result_url = baes_url + category.record_path
    elsif record_type == "item"
      item = bannerable
      result_url = baes_url + item.record_path
    end

    update_column(:url, result_url)
  end
end