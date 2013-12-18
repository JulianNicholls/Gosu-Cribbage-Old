# Cribbage using Gosu

This will eventually be a game of cribbage running under the Ruby
[Gosu](http:http://www.libgosu.org/) gem.

## Cut for Deal

First, a cut is made for deal. This is not actually honoured yet, the game
is currently run as a confused mix with the player initiating each phase.

## Deal and Discards

Then, two hands are dealt, and discards can be selected from the player's
hand via the mouse. For now, the computer just discards a random pair of cards.

## Turn-up card cut

After discarding, clicking on the pack at the right hand side will cut a
card, and display the value of the player's hand with the cut card.

## Play to 31

After the card is cut, it is up to the player to start the play to 31.
The CPU will also choose cards in turn, with some intelligence.
15s, 31s, pairs / royal, runs, and goes are scored.

## Vegetables

Once the play to 31 is complete, that's shallot for now :-) The scoring
engine is done, so it is possible to do the show.

### Instructions

There are on-screen instructions, which are being added to.

# Keys

R   Restarts
Esc Exits
