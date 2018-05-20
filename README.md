# negamax Overview

Negamax is a nim library for executing the Negamax AI algorithm on a turn-based game. The library uses the `turn_based_game` nimble library as the framework for the game itself.

The Negamax algorithm searches and weighs possible future moves. It is a varation of the minimax algorithm that is optimized for games where the "value" of a game's state for one player is directly inverse of the value to the oppossing player. This is known as a zero-sum game. An advantage to one player is always and exact disadvantage to the other player.

This algorithm is desgined to do _alpha/beta pruning_, which shortens the search tree.

This algorithem is currently recursive in nature. The author is currently working on a non-recursive one as well.

Specifically, negamax has the following restrictions:

1. It only works for two-player games.
2. It does not work with games that involve any randomness.
3. It requires that the value of the board be zero-sum in nature.

Algorithm details:

* https://en.wikipedia.org/wiki/Negamax
* https://en.wikipedia.org/wiki/Minimax

# Usage

The bulk of the work is in making the game itself. See the _turn_based_game_ library for details.

* turn_based_game (repo): <https://github.com/JohnAD/turn_based_game>
* turn_based_game (docs): <https://github.com/JohnAD/turn_based_game/wiki>

Once made, simply import the negamax library and use a `NegamaxPlayer` instead of a normal `Player`. Include the `depth` of the search as an object parameter. The depth is measured in **plies**. One **ply** is a single turn. So, a round of play between two players is two plies.

The Negamax AI specifically requires that the

* `scoring`,
* `get_state`, and
* `restore_state`

methods be defined. Again, see the _turn_based_game_ docs for details.

# Simple Example

```
import strutils
import turn_based_game
import negamax

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

const
  X = 0
  Y = 1
  DIRECTIONS = [
    [1, 2],
    [-1, 2],
    [1, -2],
    [-1, -2],
    [2, 1],
    [2, -1],
    [-2, 1],
    [-2, -1]
  ]

  BOARD_SIZE: int = 5
  EMPTY: int = 0
  WHITE_KNIGHT: int = 1
  BLACK_KNIGHT: int = 2
  FILLED: int = 3
  VISUAL_SPACE: string = ".WBX"

  LETTER_A: int = 65
  ALPHABET: string = "ABCDEFGHIJ"

#
# 1. define our game object
#
type
  Knights* = ref object of Game
    board*: array[BOARD_SIZE, array[BOARD_SIZE, int]]
    player_pos: array[3, array[2, int]] # ignore index 0 

#
#  2. add our rules (methods)
#

#
#  2a. private procs and methods
#
proc convert_coord_to_string(dest: array[2, int]): string =
  # example: [2, 3] becomes "C3"; fails if board is larger than 10x10
  result = ""
  result.add(ALPHABET[dest[X]])
  result.add($dest[Y])

# private:
proc convert_string_to_coord(dest: string): array[2, int] =
  # example: "C3" becomes [2, 3]; fails if board is larger than 10x10
  let x = int(char(dest[X])) - LETTER_A
  let y = parseInt($dest[Y])
  result = [x, y]

# private:
method place_player(self: Knights, knight: int, coord: array[2, int]) {.base.} =
  let src = self.player_pos[knight]
  self.board[src[X]][src[Y]] = FILLED
  self.board[coord[X]][coord[Y]] = knight
  self.player_pos[knight] = coord

#
# 2b. STANDARD METHODS EXPECTED OF ALL `turn_based_game`
#
method setup*(self: Knights, players: seq[Player]) =
  self.default_setup(players)
  self.board = [
    [0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0]
  ]
  self.place_player(WHITE_KNIGHT, [0, 0])
  self.player_pos[BLACK_KNIGHT] = [(BOARD_SIZE - 1), (BOARD_SIZE - 1)]
  self.place_player(BLACK_KNIGHT, [BOARD_SIZE - 1, BOARD_SIZE - 1])

method set_possible_moves*(self: Knights, moves: var seq[string]) =
  var
    valid_dest: seq[array[2, int]] = @[]
    dest: array[2, int]
  let cur = self.player_pos[self.current_player_number]
  for jump in DIRECTIONS:
    dest = [cur[X] + jump[X], cur[Y] + jump[Y]]
    if dest[X] < BOARDSIZE:
      if dest[Y] < BOARDSIZE:
        if dest[X] >= 0:
          if dest[Y] >= 0:
            if self.board[dest[X]][dest[Y]] == EMPTY:
              valid_dest.add(dest)
  for dest in valid_dest:
    moves.add(convert_coord_to_string(dest))

method make_move*(self: Knights, move: string): string =
  let dest = convert_string_to_coord(move)
  self.place_player(self.current_player_number, dest)
  return "Jumped to $#.".format(move)

method determine_winner*(self: Knights) =
  if self.winner_player_number > 0:
    return
  var poss_moves: seq[string] = @[]
  var save_player = self.current_player_number
  for p in [1, 2]:
    self.current_player_number = p
    self.set_possible_moves(poss_moves)
    if len(poss_moves) == 0:
      self.winner_player_number = self.next_player_number()
  self.current_player_number = save_player

method status*(self: Knights): string =
  result = "    "
  for n in countup(0, BOARD_SIZE - 1):
    result.add(" " & $n)
  result.add("\n")
  for x in countup(0, BOARD_SIZE - 1):
    result.add("  " & ALPHABET[x] & " ")
    for y in countup(0, BOARD_SIZE - 1):
      result.add(" " & VISUAL_SPACE[self.board[x][y]])
    result.add("\n")

#
# 2c. ADDITIONAL METHODS EXPECTED OF NEGAMAX AI
#
method scoring*(self: Knights): float =
  # for this game, I'll simply compare the number of possible moves
  # of each player
  #
  # first check border cases
  #
  if self.winner_player_number == self.current_player_number:
    return 1000.0
  if self.winner_player_number != 0: # tie or opp won
    return -1000.0
  #
  # now set the score based by multiplying 100.0 by the number of moves you
  # can currently choose from. In theory, that game be as many as seven.
  # (The place you just jumped from is never available.)
  #
  var poss_moves: seq[string] = @[]
  self.set_possible_moves(poss_moves)
  var my_move_score = float(len(poss_moves)) * 100.0
  let save_player = self.current_player_number
  self.current_player_number = self.next_player_number()
  self.set_possible_moves(poss_moves)
  self.current_player_number = save_player
  var opp_move_score = float(len(poss_moves)) * 100.0
  return my_move_score - opp_move_score

method get_state*(self: Knights): string =
  if self.current_player_number == 1:
    result = "1"
  else:
    result = "2"
  for row in self.board:
    for column in row:
      result.add(VISUAL_SPACE[column])

method restore_state*(self: Knights, state: string): void =
  var i: int
  var e: int
  if state.startsWith("1"):
    self.current_player_number = 1
  else:
    self.current_player_number = 2
  for x in countup(0, BOARD_SIZE - 1):
    for y in countup(0, BOARD_SIZE - 1):
      i = x * BOARD_SIZE + y + 1
      e = find(VISUAL_SPACE, state[i])
      self.board[x][y] = e
      if e in [WHITE_KNIGHT, BLACK_KNIGHT]:
        self.player_pos[e][X] = x
        self.player_pos[e][Y] = y

#
# 3. Now play the game between:
#       The human at the console, playing the White/Red Knight, and
#       the negamax AI, playing the Black Knight
#
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
```

# Credit

The code for this engine mimics that written in Python at the EasyAI library located at <https://github.com/Zulko/easyAI>. That library contains both the game rule engine (called TwoPlayerGame) as well as a variety of AI algorithms to play as game players, such as Negamax.
