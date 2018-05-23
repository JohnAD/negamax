import turn_based_game
import negamax

import knights

#
#  Game of Knights
#
# Knights is played on a 5 row by 5 column chessboard with standard Knight pieces. Just like
# in chess, the Knight move by jumping in an L pattern: moving one space in any direction followed by
# moving two spaces at a right angle to the first move. When a knight makes a jump, the place that it
# formerly occupied is marked with an X and it can no longer be landed on by either player. As the
# game progresses, there are fewer and fewer places to land. There are no captures in this game.
#
# To start, each player has one Knight placed in an opposite corner. The players then take turns jumping.
# The last player to still have a place to move is the winner.
#

var game = Knights()

game.setup(@[
  Player(name: "Black Knight"),
  NegamaxPlayer(name: "White Knight", depth: 7)
])

var history: seq[string] = @[]

history = game.play()

echo "history: " & $history
