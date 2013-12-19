# Cribbage using Gosu

This will eventually be a game of cribbage running under the Ruby
[Gosu](http:http://www.libgosu.org/) gem.

## Cut for Deal

First, a cut is made for deal. This is now honoured for the correct starter
of play to 31.

## Deal and Discards

Then, two hands are dealt, and discards can be selected from the player's
hand via the mouse. For now, the computer just discards a random pair of cards.

## Turn-up card cut

After discarding, clicking on the pack at the right hand side will cut a
card (always done by the human player at present)

## Play to 31

After the card is cut, the correct player will start the play to 31.
The CPU will choose cards in turn, with some intelligence. 15s, 31s,
pairs / royal / double, runs, and goes are scored.

## Vegetables

Once the play to 31 is complete, that's shallot for now :-) The scoring
engine is done, so it is possible to do the show.

### Instructions

There are on-screen instructions, which are being added to.

# Keys

R   Restarts
Esc Exits
