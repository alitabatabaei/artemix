require 'spec_helper'

describe Transform do
  let(:artwork_attributes) { {
    :locked => false,
    :name => "valid",
    :image => fixture_file_upload('fourmoons.jpg', 'image/jpeg')
  } }
  let(:valid_attributes) { {
    :image_x => 1,
    :image_y => 1,
    :height => 1,
    :width => 1,
    :artwork => @artwork,
    :leg => "left"
  } } 
  before do
    @artwork = Artwork.create!(artwork_attributes)
  end
  describe 'with proper values' do
    it 'should save' do
      Transform.create!(valid_attributes)
    end
  end
  describe 'without proper values' do
    it 'should not save without image_x' do
      valid_attributes.delete(:image_x)
      expect{ Transform.create!(valid_attributes) }.to raise_error
    end
    it 'should not save without image_y' do
      valid_attributes.delete(:image_y)
      expect{ Transform.create!(valid_attributes) }.to raise_error
    end
    it 'should not save without height' do
      valid_attributes.delete(:height)
      expect{ Transform.create!(valid_attributes) }.to raise_error
    end
    it 'should not save without width' do
      valid_attributes.delete(:width)
      expect{ Transform.create!(valid_attributes) }.to raise_error
    end
    it 'should not save without an artwork' do
      valid_attributes.delete(:artwork)
      expect{ Transform.create!(valid_attributes) }.to raise_error
    end
    it 'should not save without a leg specified' do
      valid_attributes.delete(:leg)
      expect{ Transform.create!(valid_attributes) }.to raise_error
    end
  end
  describe 'scaling' do
    it 'should change values when scaled' do
      t = Transform.new(valid_attributes)
      t.scale
      t.image_x = valid_attributes[:image_x] * 20
      t.image_y = valid_attributes[:image_y] * 20
      t.height = valid_attributes[:height] * 20
      t.width = valid_attributes[:width] * 20
    end
  end
end
