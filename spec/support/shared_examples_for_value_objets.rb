require 'spec_helper'

shared_examples 'a value object' do
  it { is_expected.to respond_to(:==).with(1).argument }
  it { is_expected.to respond_to(:eql?).with(1).argument }
  it { is_expected.to respond_to(:hash).with(0).arguments }

  describe '#==' do
    it 'is equivalent to object' do
      [eq_obj].flatten.each do |other|
        is_expected.to eq(other)
      end
    end

    it 'is not equivalent to object' do
      [not_eq_obj].flatten.each do |other|
        is_expected.not_to eq(other)
      end
    end
  end

  describe '#eql?' do
    it 'is identical to object' do
      [eql_obj].flatten.each do |other|
        is_expected.to eql(other)
      end
    end

    it 'is not identical to object' do
      [not_eql_obj].flatten.each do |other|
        is_expected.not_to eql(other)
      end
    end
  end

  describe '#hash' do
    subject { super().hash }

    it 'equals identical object' do
      [eql_obj].flatten.each do |other|
        is_expected.to eq(other.hash)
      end
    end

    it 'does not equal identical object' do
      [not_eql_obj].flatten.each do |other|
        is_expected.not_to eq(other.hash)
      end
    end
  end
end
