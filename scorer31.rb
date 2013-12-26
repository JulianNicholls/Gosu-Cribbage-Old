module CribbageGame
  # Scorer for the Play to 31

  class Scorer31
    def initialize( engine )
      @engine = engine
    end

    def evaluate( set, total, player )
      @set, @turn = set, player
      @top        = set.last

      peg_player( player, 2, total.to_s ) if total == 15 || total == 31

      evaluate_4 if set.length >= 4
      evaluate_3 if set.length >= 3
      evaluate_2 if set.length >= 2
    end

    def evaluate_4
      if @set[-4..-2].all? { |c| c.rank == @top.rank }
        peg_player( @turn, 6, 'a Double Pair Royal' )
      end
    end

    def evaluate_3
      if @set[-3..-2].all? { |c| c.rank == @top.rank }
        peg_player( @turn, 4, 'a Pair Royal' )
      end

      score_runs
    end

    def evaluate_2
      peg_player( @turn, 2, 'a Pair' ) if @set[-2].rank == @top.rank
    end

    def peg_player( turn, by, reason )
      @engine.set_score( turn, by, reason )
    end

    private

    def score_runs
      @set.length.downto(3) do |n|
        if run?( @set[-n..-1].sort_by( &:rank ) )
          peg_player( @turn, n, "a Run of #{n}" )
          return
        end
      end
    end

    def run?( cards )
      (1..cards.size - 1).all? { |idx| cards[idx].rank == cards[idx - 1].rank + 1 }
    end
  end
end
