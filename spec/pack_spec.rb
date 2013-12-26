require_relative '../card'

describe Cribbage::Pack do
  before :each do
    @pack = Cribbage::Pack.new
  end

  it 'should deal exactly 52 cards' do
    52.times do |time|
      # Must be done first, because the 52nd time it'll be true after deal!
      expect( @pack.empty? ).to eq false
      expect( @pack.deal ).to_not eq nil
    end

    expect( @pack.deal ).to eq nil
    expect( @pack.empty? ).to eq true
  end

  it 'should deal 52 different cards' do
    deck  = Array.new( 52 ) { @pack.deal }
    udeck = deck.uniq { |c| c.short_name }
    expect( deck ).to eq udeck
  end

  it 'should be able to cut a card' do
    expect( @pack.cut ).to_not eq @pack.cut
  end
end
