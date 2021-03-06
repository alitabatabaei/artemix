class Transform < ActiveRecord::Base
  require 'RMagick'

  validates :image_x, :presence => true
  validates :image_y, :presence => true
  validates :width, :presence => true # negative width correlates to a mirrored image
  validates :height, :presence => true
  validates :rotation, :presence => true
  validates_inclusion_of :leg, :in => [
    'left',
    'right'
  ]

  belongs_to :artwork
  belongs_to :design

  validates :artwork, :presence => true

  def prepare_for_create
    self.image_x = self.image_x.to_i
    self.image_y = self.image_y.to_i
    self.height = self.height.to_i
    self.width = self.width.to_i
    self.artwork_id = self.artwork_id.to_i
    self.design_id = self.design_id.to_i
    self.rotation = self.rotation.to_f
  end

  # takes pixel counts from the website and scales them to actual 300dpi template size
  def scale
    scale_factor = 20 # template.png height divided by canvas height
    self.image_x *= scale_factor
    self.image_y *= scale_factor
    self.height *= scale_factor
    self.width *= scale_factor
    self.rotation *= 180 / Math::PI
  end

  def crop_image!(image, center_x)
    if self.leg == 'left'
      crop_origin_x = self.image_x
      crop_width = center_x - self.image_x
    else
      crop_origin_x = self.image_x < 0 ? self.image_x.abs : 0
      crop_width = self.width
    end
    puts "leg: #{self.leg}, x: #{crop_origin_x}, width: #{crop_width}"
    image.crop!(crop_origin_x, 0, crop_width, self.height)
  end

  # For MVP, this method moves, resizes, composites, rotates (at your own risk!), and mirrors. Nothing else
  # Input: a Magick::ImageList
  # Output: a Magick::ImageList that represents the composite of the inputted image on top of the transformed image
  # Imagine glueing transform's artwork onto the passed-in image.
  def apply(template_image)
    self.scale

    image = Magick::ImageList.new(self.artwork.image.path)

    image[0].rotate!(rotation) unless rotation.nil?
    image.resize!(self.width, self.height)

    center_x = template_image.columns / 2
    crop_image!(image, center_x)

    self.image_x += template_image.columns / 2 if self.leg == 'right'

    # x_copies = (image[0].columns / template[0].columns).ceil
    # y_copies = (image[0].rows / template[0].rows).ceil

    # To be tiling, see http://www.imagemagick.org/RMagick/doc/ilist.html#mosaic
    # tiled = Magick::ImageList.new
    # page = Magick::Rectangle.new(0,0,0,0)
    # x_copies.times do |x|
    #   y_copies.times do |y|

    #   end
    # end

    design_image = template_image[0].composite(image, self.image_x, self.image_y, Magick::DstOverCompositeOp)

    if mirror
      design_image.flop!
      design_image.composite!(image, self.image_x, self.image_y, Magick::DstOverCompositeOp)
      design_image.flop!
    end

    intermediate_location = "#{Dir.tmpdir}/#{SecureRandom.hex}.png"
    design_image.write(intermediate_location)
    intermediate_location
  end

end
