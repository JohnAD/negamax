#
# Knights example
#
# Description: Each player has a chess knight (that moves in a "L" pattern) on
# a 5x5 chessboard. Each turn the player moves the knight to any tile that
# hasn't been occupied by a knight before. The first player that cannot move
# loses.
#
# This game was ported from https://github.com/Zulko/easyAI
#

import strutils
import turn_based_game
import negamax
import tables


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

# private:
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


########################################################################
#
# STANDARD METHODS EXPECTED OF ALL `turn_based_game`
#
########################################################################

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


# the following method is not _required_, but makes it nicer to read
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

########################################################################
#
# ADDITIONAL METHODS EXPECTED OF NEGAMAX AI
#
########################################################################

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

