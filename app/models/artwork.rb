class Artwork < ActiveRecord::Base
  has_attached_file :image, :styles => { :medium => "300x300>", :thumb => "100x100>", :canvas => "300x660>" }, :default_url => "/images/:style/missing.png"

  # soft upper limit of 16 characters for the artist field
  validates :artist, presence: true
  # validates_inclusion_of :locked, :in => [true, false]

  validates_attachment_presence :image
  validates_attachment_content_type :image, :content_type => /image\/(jpg|jpeg|png|gif)/

  has_many :transforms
end
