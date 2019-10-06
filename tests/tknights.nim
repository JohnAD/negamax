import turn_based_game
import knights
import negamax

const
  K1_correct = @["B2", "C4", "D6", "E4", "F6", "G4", "H6", "F5", "G7", "H5", "G3", "H1", "F2", "G0", "H2", "F1", "E3", "D5", "C7", "B5", "C3", "A2", "B0", "D1", "F0", "G2", "H4"]
  K2_correct = @["G5", "F7", "E5", "D7", "C5", "B7", "A5", "B3", "C1", "D3", "E1", "F3", "G1", "H3", "F4", "G6", "E7", "C6", "D4", "E2", "D0", "C2", "A3", "B1", "D2", "C0"]

var game = Knights()

var players: seq[Player] = @[]
players.add(NegamaxPlayer(name: "K1", depth: 8))
players.add(NegamaxPlayer(name: "K2", depth: 10))

game.setup(players)

var move: string = ""

var move_list_K1: seq[string] = @[]
var move_list_K2: seq[string] = @[]

while not game.is_over():
  move = game.current_player().get_move(game)
  if move=="":
    break
  if game.current_player_number == 1:
    move_list_K1.add(move)
  else:
    move_list_K2.add(move)
  discard game.make_move(move)
  game.determine_winner()
  game.finish_turn()

assert move_list_K1 == K1_correct
assert move_list_K2 == K2_correct
