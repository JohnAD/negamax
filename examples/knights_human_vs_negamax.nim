import turn_based_game
import knights
import negamax
import strutils

const
  TAB: string = "   "

var game = Knights()

game.setup(@[
  Player(name: "Black Knight"),
  NegamaxPlayer(name: "White Knight", depth: 7)
])

var history: seq[string] = @[]
var move: string = ""

while not game.is_over():
  if game.current_player_number == 2:
    echo ""
    echo "AI (Negamax) is thinking..."
  move = game.current_player().get_move(game)
  if move.isNil:
    break
  history.add(move)
  echo ""
  echo TAB & game.make_move(move)
  game.determine_winner()
  game.finish_turn()

echo ""
echo "GAME OVER"
if game.winner_player_number == STALEMATE:
  echo TAB & "result: stalemate!"
elif game.winner_player_number == 0:
  echo TAB & "result: no winner yet."
else:
  echo TAB & "result: winner is $#".format(game.winning_player.name)
echo ""
echo TAB & "history: " & $history
