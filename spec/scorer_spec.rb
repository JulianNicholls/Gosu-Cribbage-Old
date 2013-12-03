require_relative '../scorer'

require 'spec_helper'

module Cribbage
  class Hand
    attr_accessor :cards
  end

  class Scorer
    attr_reader :hand, :thefive, :pairs, :threes, :fours
    public :fifteens_score, :pairs_score, :runs_score, :flush_score, :one_for_his_nob
  end
end

describe Cribbage::Scorer do
  before :each do
    pack = Cribbage::Pack.new

    @basehand = Cribbage::Hand.new pack
    @basehand.cards = [FullPack::H2, FullPack::S3, FullPack::DT, FullPack::CQ]

    @turncard = FullPack::C5
    @scorer = Cribbage::Scorer.new( @basehand, @turncard )
  end

  it "should collect and not modify the hand" do
    expect( @scorer.hand.cards.length ).to eq 4
  end

  it "should collect the five cards together" do
    expect( @scorer.thefive.length ).to eq 5
  end

  it "should hold the five cards in ascending order" do
    4.times { |c| expect( @scorer.thefive[c].value <= @scorer.thefive[c+1].value ) }
    4.times { |c| expect( @scorer.thefive[c].rank  <= @scorer.thefive[c+1].rank ) }
  end

  it "should generate all the pairs" do
    expect( @scorer.pairs.length ).to eq 10
  end

  it "should generate all the threes" do
    expect( @scorer.threes.length ).to eq 10
  end

  it "should generate all the fours" do
    expect( @scorer.fours.length ).to eq 5
  end

  it "should get a score of 8 for the default hand" do
    expect( @scorer.fifteens_score ).to eq 8
    expect( @scorer.pairs_score ).to eq 0
    expect( @scorer.runs_score ).to eq 0
    expect( @scorer.flush_score ).to eq 0
    expect( @scorer.one_for_his_nob ).to eq 0
    expect( @scorer.evaluate ).to eq 8
  end

  it "should get a score of 12 for a 6336 hand" do
    @basehand.cards = [FullPack::H6, FullPack::S6, FullPack::H3, FullPack::S3]
    @scorer.set_cards( @basehand, @turncard )

    expect( @scorer.fifteens_score ).to eq 8
    expect( @scorer.pairs_score ).to eq 4
    expect( @scorer.runs_score ).to eq 0
    expect( @scorer.flush_score ).to eq 0
    expect( @scorer.one_for_his_nob ).to eq 0
    expect( @scorer.evaluate ).to eq 12
  end

  it "should get a score of 20 for 6555 + 5" do
    @basehand.cards = [FullPack::H6, FullPack::S5, FullPack::H5, FullPack::D5]
    @scorer.set_cards( @basehand, @turncard )

    expect( @scorer.fifteens_score ).to eq 8
    expect( @scorer.pairs_score ).to eq 12
    expect( @scorer.runs_score ).to eq 0
    expect( @scorer.flush_score ).to eq 0
    expect( @scorer.one_for_his_nob ).to eq 0
    expect( @scorer.evaluate ).to eq 20
  end

  it "should get a score of 28 for 5555 + 10 value" do
    @basehand.cards = [FullPack::C5, FullPack::S5, FullPack::H5, FullPack::D5]
    @scorer.set_cards( @basehand, FullPack::HT )

    expect( @scorer.fifteens_score ).to eq 16
    expect( @scorer.pairs_score ).to eq 12
    expect( @scorer.runs_score ).to eq 0
    expect( @scorer.flush_score ).to eq 0
    expect( @scorer.one_for_his_nob ).to eq 0
    expect( @scorer.evaluate ).to eq 28
  end

  it "should get the maximum score of 29 for 555J + 5 suited" do
    @basehand.cards = [FullPack::CJ, FullPack::S5, FullPack::H5, FullPack::D5]
    @scorer.set_cards( @basehand, @turncard )

    expect( @scorer.fifteens_score ).to eq 16
    expect( @scorer.pairs_score ).to eq 12
    expect( @scorer.runs_score ).to eq 0
    expect( @scorer.flush_score ).to eq 0
    expect( @scorer.one_for_his_nob ).to eq 1
    expect( @scorer.evaluate ).to eq 29
  end

  it "should return 4 for a flushed normal hand" do
    @basehand.cards = [FullPack::C2, FullPack::C4, FullPack::C6, FullPack::C8]
    @scorer.set_cards( @basehand, FullPack::ST )

    expect( @scorer.fifteens_score ).to eq 0
    expect( @scorer.pairs_score ).to eq 0
    expect( @scorer.runs_score ).to eq 0
    expect( @scorer.flush_score ).to eq 4
    expect( @scorer.one_for_his_nob ).to eq 0
    expect( @scorer.evaluate ).to eq 4
  end

  it "should return 0 for a flushed crib" do
    @basehand.cards = [FullPack::C2, FullPack::C4, FullPack::C6, FullPack::C8]
    @crib_scorer = Cribbage::Scorer.new( @basehand, FullPack::ST, :crib )

    expect( @crib_scorer.fifteens_score ).to eq 0
    expect( @crib_scorer.pairs_score ).to eq 0
    expect( @crib_scorer.runs_score ).to eq 0
    expect( @crib_scorer.flush_score ).to eq 0
    expect( @crib_scorer.one_for_his_nob ).to eq 0
    expect( @crib_scorer.evaluate ).to eq 0
  end

  it "should return 5 for a flushed normal hand with turn card suited" do
    @basehand.cards = [FullPack::C2, FullPack::C4, FullPack::C6, FullPack::C8]
    @scorer.set_cards( @basehand, FullPack::CT )

    expect( @scorer.fifteens_score ).to eq 0
    expect( @scorer.pairs_score ).to eq 0
    expect( @scorer.runs_score ).to eq 0
    expect( @scorer.flush_score ).to eq 5
    expect( @scorer.one_for_his_nob ).to eq 0
    expect( @scorer.evaluate ).to eq 5
  end

  it "should return 5 for a flushed crib hand with turn card suited" do
    @basehand.cards = [FullPack::C2, FullPack::C4, FullPack::C6, FullPack::C8]
    @crib_scorer = Cribbage::Scorer.new( @basehand, FullPack::CT, :crib )

    expect( @crib_scorer.fifteens_score ).to eq 0
    expect( @crib_scorer.pairs_score ).to eq 0
    expect( @crib_scorer.runs_score ).to eq 0
    expect( @crib_scorer.flush_score ).to eq 5
    expect( @crib_scorer.one_for_his_nob ).to eq 0
    expect( @crib_scorer.evaluate ).to eq 5
  end

  it "should return 8 for 6789 + J" do
    @basehand.cards = [FullPack::C6, FullPack::S7, FullPack::S8, FullPack::C9]
    @scorer.set_cards( @basehand, FullPack::CJ )

    expect( @scorer.fifteens_score ).to eq 4
    expect( @scorer.pairs_score ).to eq 0
    expect( @scorer.runs_score ).to eq 4
    expect( @scorer.flush_score ).to eq 0
    expect( @scorer.one_for_his_nob ).to eq 0
    expect( @scorer.evaluate ).to eq 8
  end

  it "should return 10 for 2334 + 7" do
    @basehand.cards = [FullPack::C2, FullPack::C3, FullPack::S3, FullPack::C4]
    @scorer.set_cards( @basehand, FullPack::C7 )

    expect( @scorer.fifteens_score ).to eq 2
    expect( @scorer.pairs_score ).to eq 2
    expect( @scorer.runs_score ).to eq 6
    expect( @scorer.flush_score ).to eq 0
    expect( @scorer.one_for_his_nob ).to eq 0
    expect( @scorer.evaluate ).to eq 10
  end

  it "should return 12 for 2345 + 5" do
    @basehand.cards = [FullPack::C2, FullPack::S3, FullPack::S4, FullPack::C5]
    @scorer.set_cards( @basehand, FullPack::S5 )

    expect( @scorer.fifteens_score ).to eq 2
    expect( @scorer.pairs_score ).to eq 2
    expect( @scorer.runs_score ).to eq 8
    expect( @scorer.flush_score ).to eq 0
    expect( @scorer.one_for_his_nob ).to eq 0
    expect( @scorer.evaluate ).to eq 12
  end

  it "should return 16 for 5JQK + K (Book pp14)" do
    @basehand.cards = [FullPack::C5, FullPack::CJ, FullPack::SQ, FullPack::CK]
    @scorer.set_cards( @basehand, FullPack::SK )

    expect( @scorer.fifteens_score ).to eq 8
    expect( @scorer.pairs_score ).to eq 2
    expect( @scorer.runs_score ).to eq 6
    expect( @scorer.flush_score ).to eq 0
    expect( @scorer.one_for_his_nob ).to eq 0
    expect( @scorer.evaluate ).to eq 16
  end

  it "should return 14 for A223 + Q (Book pp14)" do
    @basehand.cards = [FullPack::CA, FullPack::S2, FullPack::D2, FullPack::C3]
    @scorer.set_cards( @basehand, FullPack::SQ )

    expect( @scorer.fifteens_score ).to eq 6
    expect( @scorer.pairs_score ).to eq 2
    expect( @scorer.runs_score ).to eq 6
    expect( @scorer.flush_score ).to eq 0
    expect( @scorer.one_for_his_nob ).to eq 0
    expect( @scorer.evaluate ).to eq 14
  end

  it "should return 14 for 4569 + J suited (Book pp14)" do
    @basehand.cards = [FullPack::C4, FullPack::C5, FullPack::C6, FullPack::C9]
    @scorer.set_cards( @basehand, FullPack::CJ )

    expect( @scorer.fifteens_score ).to eq 6
    expect( @scorer.pairs_score ).to eq 0
    expect( @scorer.runs_score ).to eq 3
    expect( @scorer.flush_score ).to eq 5
    expect( @scorer.one_for_his_nob ).to eq 0
    expect( @scorer.evaluate ).to eq 14
  end

  it "should return 7 for 556J + 2 suited (Book pp14)" do
    @basehand.cards = [FullPack::S5, FullPack::C5, FullPack::C6, FullPack::CJ]
    @scorer.set_cards( @basehand, FullPack::C2 )

    expect( @scorer.fifteens_score ).to eq 4
    expect( @scorer.pairs_score ).to eq 2
    expect( @scorer.runs_score ).to eq 0
    expect( @scorer.flush_score ).to eq 0
    expect( @scorer.one_for_his_nob ).to eq 1
    expect( @scorer.evaluate ).to eq 7
  end
end
