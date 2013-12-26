require_relative '../card'

require 'spec_helper'

describe Cribbage::Card do

  it 'should return the correct suit for each card' do
    expect( FullPack::HA.suit ).to eq 1
    expect( FullPack::CA.suit ).to eq 2
    expect( FullPack::DA.suit ).to eq 3
    expect( FullPack::SA.suit ).to eq 4
  end

  it 'should return the correct rank for each card' do
    expect( FullPack::HA.rank ).to eq 1
    expect( FullPack::H2.rank ).to eq 2
    expect( FullPack::H3.rank ).to eq 3
    expect( FullPack::H4.rank ).to eq 4
    expect( FullPack::H5.rank ).to eq 5
    expect( FullPack::H6.rank ).to eq 6
    expect( FullPack::H7.rank ).to eq 7
    expect( FullPack::H8.rank ).to eq 8
    expect( FullPack::H9.rank ).to eq 9
    expect( FullPack::HT.rank ).to eq 10
    expect( FullPack::HJ.rank ).to eq 11
    expect( FullPack::HQ.rank ).to eq 12
    expect( FullPack::HK.rank ).to eq 13
  end

  it 'should return the correct value for each card' do
    expect( FullPack::HA.value ).to eq 1
    expect( FullPack::H2.value ).to eq 2
    expect( FullPack::H3.value ).to eq 3
    expect( FullPack::H4.value ).to eq 4
    expect( FullPack::H5.value ).to eq 5
    expect( FullPack::H6.value ).to eq 6
    expect( FullPack::H7.value ).to eq 7
    expect( FullPack::H8.value ).to eq 8
    expect( FullPack::H9.value ).to eq 9
    expect( FullPack::HT.value ).to eq 10
    expect( FullPack::HJ.value ).to eq 10
    expect( FullPack::HQ.value ).to eq 10
    expect( FullPack::HK.value ).to eq 10
  end

  it 'should correctly name all suits' do
    expect( FullPack::HA.suit_name ).to eq 'Hearts'
    expect( FullPack::CA.suit_name ).to eq 'Clubs'
    expect( FullPack::DA.suit_name ).to eq 'Diamonds'
    expect( FullPack::SA.suit_name ).to eq 'Spades'
  end

  it 'should correctly name all ranks' do
    expect( FullPack::HA.rank_name ).to eq 'Ace'
    expect( FullPack::H2.rank_name ).to eq '2'
    expect( FullPack::H3.rank_name ).to eq '3'
    expect( FullPack::H4.rank_name ).to eq '4'
    expect( FullPack::H5.rank_name ).to eq '5'
    expect( FullPack::H6.rank_name ).to eq '6'
    expect( FullPack::H7.rank_name ).to eq '7'
    expect( FullPack::H8.rank_name ).to eq '8'
    expect( FullPack::H9.rank_name ).to eq '9'
    expect( FullPack::HT.rank_name ).to eq 'Ten'
    expect( FullPack::HJ.rank_name ).to eq 'Jack'
    expect( FullPack::HQ.rank_name ).to eq 'Queen'
    expect( FullPack::HK.rank_name ).to eq 'King'
  end

  it 'should correctly name all cards' do
    expect( FullPack::HA.name ).to eq 'Ace of Hearts'
    expect( FullPack::H2.name ).to eq '2 of Hearts'
    expect( FullPack::H3.name ).to eq '3 of Hearts'
    expect( FullPack::H4.name ).to eq '4 of Hearts'
    expect( FullPack::H5.name ).to eq '5 of Hearts'
    expect( FullPack::H6.name ).to eq '6 of Hearts'
    expect( FullPack::H7.name ).to eq '7 of Hearts'
    expect( FullPack::H8.name ).to eq '8 of Hearts'
    expect( FullPack::H9.name ).to eq '9 of Hearts'
    expect( FullPack::HT.name ).to eq 'Ten of Hearts'
    expect( FullPack::HJ.name ).to eq 'Jack of Hearts'
    expect( FullPack::HQ.name ).to eq 'Queen of Hearts'
    expect( FullPack::HK.name ).to eq 'King of Hearts'

    expect( FullPack::CA.name ).to eq 'Ace of Clubs'
    expect( FullPack::DA.name ).to eq 'Ace of Diamonds'
    expect( FullPack::SA.name ).to eq 'Ace of Spades'
  end

  it 'should render a card as a string' do
    expect( "#{FullPack::HA}" ).to eq FullPack::HA.name
    expect( "#{FullPack::CA}" ).to eq FullPack::CA.name
    expect( "#{FullPack::DA}" ).to eq FullPack::DA.name
    expect( "#{FullPack::SA}" ).to eq FullPack::SA.name
  end

  it 'should have a correct short name for all cards' do
    expect( FullPack::HA.short_name ).to eq 'AH'
    expect( FullPack::H2.short_name ).to eq '2H'
    expect( FullPack::H3.short_name ).to eq '3H'
    expect( FullPack::H4.short_name ).to eq '4H'
    expect( FullPack::H5.short_name ).to eq '5H'
    expect( FullPack::H6.short_name ).to eq '6H'
    expect( FullPack::H7.short_name ).to eq '7H'
    expect( FullPack::H8.short_name ).to eq '8H'
    expect( FullPack::H9.short_name ).to eq '9H'
    expect( FullPack::HT.short_name ).to eq 'TH'
    expect( FullPack::HJ.short_name ).to eq 'JH'
    expect( FullPack::HQ.short_name ).to eq 'QH'
    expect( FullPack::HK.short_name ).to eq 'KH'

    expect( FullPack::CA.short_name ).to eq 'AC'
    expect( FullPack::DA.short_name ).to eq 'AD'
    expect( FullPack::SA.short_name ).to eq 'AS'
  end

  # These tests are for completeness, unfortunately not all fonts support the
  # Unicode characters necessary for the suit symbols.

  it 'should return the correct character for all suits' do
    expect( FullPack::HA.suit_char ).to eq "\u2665"
    expect( FullPack::CA.suit_char ).to eq "\u2663"
    expect( FullPack::DA.suit_char ).to eq "\u2666"
    expect( FullPack::SA.suit_char ).to eq "\u2660"
  end

  it 'should have a correct display name for all cards' do
    expect( FullPack::HA.display_name ).to eq "A\u2665"
    expect( FullPack::H2.display_name ).to eq "2\u2665"
    expect( FullPack::H3.display_name ).to eq "3\u2665"
    expect( FullPack::H4.display_name ).to eq "4\u2665"
    expect( FullPack::H5.display_name ).to eq "5\u2665"
    expect( FullPack::H6.display_name ).to eq "6\u2665"
    expect( FullPack::H7.display_name ).to eq "7\u2665"
    expect( FullPack::H8.display_name ).to eq "8\u2665"
    expect( FullPack::H9.display_name ).to eq "9\u2665"
    expect( FullPack::HT.display_name ).to eq "10\u2665"
    expect( FullPack::HJ.display_name ).to eq "J\u2665"
    expect( FullPack::HQ.display_name ).to eq "Q\u2665"
    expect( FullPack::HK.display_name ).to eq "K\u2665"

    expect( FullPack::CT.display_name ).to eq "10\u2663"
    expect( FullPack::DT.display_name ).to eq "10\u2666"
    expect( FullPack::ST.display_name ).to eq "10\u2660"
  end
end
