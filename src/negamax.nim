## Negamax is a nim library for executing the Negamax AI algorithm on a 
## turn-based game. The library uses the ``turn_based_game`` nimble library as
## the framework for the game itself.
## 
## The negamax algorithm searches and weighs possible future moves. It is a 
## varation of the minimax algorithm that is optimized for games where the 
## "value" of a game's state for one player is directly inverse of the value 
## to the oppossing player. This is known as a
## [zero-sum game](https://en.wikipedia.org/wiki/Zero-sum_game).
## 
## This algorithm is desgined to do _alpha/beta pruning_, which shortens the 
## search tree.
## 
## This algorithem is currently recursive. The author is currently working on 
## a non-recursive one as well.
## 
## Negamax has the following restrictions:
## 
## 1. It only works for two-player games.
## 2. It does not work with games that involve any randomness.
## 3. It requires that the value of the board be zero-sum in nature.
## 
## Algorithm details:
## 
## * https://en.wikipedia.org/wiki/Negamax
## * https://en.wikipedia.org/wiki/Minimax
## 
## Usage
## ==========
## 
## The bulk of the work is in making the game itself. See the _turn_based_game_ 
## library for details.
## 
## * turn_based_game (repo): <https://github.com/JohnAD/turn_based_game>
## 
## Once made, simply import the negamax library and use a ``NegamaxPlayer`` 
## instead of a normal ``Player``. Include the ``depth`` of the search as an object 
## parameter. The depth is measured in **plies**. One **ply** is a single play. 
## So, one full round of play between two players is two plies.
## 
## The Negamax AI specifically requires that the
## 
## * ``scoring``,
## * ``get_state``, and
## * ``restore_state``
## 
## methods be defined. Again, see the _turn_based_game_ docs for details.
## 
## Simple Example
## ===============
## 
## .. code:: nim
##
##     import turn_based_game
##     import negamax
## 
##     import knights
## 
##     #
##     #  Game of Knights
##     #
##     # Knights is played on a 5 row by 5 column chessboard with standard Knight pieces. Just like
##     # in chess, the Knight move by jumping in an L pattern: moving one space in any direction followed by
##     # moving two spaces at a right angle to the first move. When a knight makes a jump, the place that it
##     # formerly occupied is marked with an X and it can no longer be landed on by either player. As the
##     # game progresses, there are fewer and fewer places to land. There are no captures in this game.
##     #
##     # To start, each player has one Knight placed in an opposite corner. The players then take turns jumping.
##     # The last player to still have a place to move is the winner.
##     #
## 
##     var game = Knights()
## 
##     game.setup(@[
##       Player(name: "Black Knight"),
##       NegamaxPlayer(name: "White Knight", depth: 7)
##     ])
## 
##     var history: seq[string] = @[]
## 
##     history = game.play()
## 
##     echo "history: " & $history
## 
## For the content pulled by "import knights", see 
## https://github.com/JohnAD/negamax/blob/master/examples/knights.nim
## 
## Videos
## ============
## 
## The following two videos (to be watched in sequence), demonstrate how to use 
## this library and the ``turn_based_game`` library:
## 
## * Using "turn_based_game": https://www.youtube.com/watch?v=u6w8vT-oBjE
## * Using "negamax": https://www.youtube.com/watch?v=op4Mcgszshk
## 
## Credit
## =============
## 
## The code for this engine mimics that written in Python at the EasyAI library 
## located at <https://github.com/Zulko/easyAI>. That library contains both 
## the game rule engine (called TwoPlayerGame) as well as a variety of AI 
## algorithms to play as game players, such as Negamax.


import turn_based_game

proc negamax_core(game: var Game, ai_choice: var string, depth: int, orig_depth: int, alpha_in: float, beta_in: float): float =

  var
    possible_moves: seq[string] = @[]
    starting_state: string
    move_alpha: float
    alpha: float = alpha_in
    beta: float = beta_in

  # echo "DEPTH " & $depth
  game.set_possible_moves(possible_moves)

  # check for border cases
  #
  if (depth == 0) or game.is_over() or len(possible_moves)==0:
    var score = game.scoring()
    # echo "SCORED " & $score
    if score == 0.0:
      return score
    else:
      return (score - 0.01 * float(depth) * abs(score) / score)

  # get state
  #
  starting_state = game.get_state()
  # echo "STARTING STATE ", starting_state

  # set up defaults/fall-throughs
  #
  var best_move = possible_moves[0]
  var best_value = -INF

  for move in possible_moves:

    # simulate the next move
    #
    discard game.make_move(move)
    game.finish_turn()

    # get the negative value result
    #
    move_alpha = -negamax_core(
      game,
      ai_choice,
      depth - 1,
      orig_depth,
      -beta,
      -alpha
    )

    game.restore_state(starting_state) # restore the game each time

    # evaluate
    #
    if best_value < move_alpha:
      best_value = move_alpha
      best_move = move
    if alpha < move_alpha:
      alpha = move_alpha
      if depth == orig_depth:
        ai_choice = best_move
      if alpha >= beta:
        break

  return best_value


proc negamax*(game: var Game, depth: int): string = 
  ## This is the main negamax algorithm.
  ##
  ## ``depth`` determines the number of *plies* for the algorithm
  ## to look ahead.
  ##
  ## returns a string ``move`` from the ``game``'s list of 
  ## available possible moves. If the game is over, it will
  ## likely return an empty string.


  var
    alpha: float
    beta: float
    ai_choice: string
    possible_moves: seq[string] = @[]

  alpha = -INF
  beta = INF


  # set the starting default
  game.set_possible_moves(possible_moves)
  if len(possible_moves) == 0:
    return ""
  ai_choice = possible_moves[0]

  alpha = negamax_core(
    game,
    ai_choice,
    depth,
    depth,
    alpha,
    beta
  )
  return ai_choice


type

  NegamaxPlayer* = ref object of Player
    ## this is the AI player to be used with the ``turn_based_game`` library
    depth*: int


method get_move*(self: NegamaxPlayer, game: Game): string = 
  ## Get the chosen move from the algorithm in the context of a
  ## ``turn_based_game`` library ``Game``.
  var new_game: Game
  when defined(js):
    new_game = game
  else:
    deepCopy(new_game, game)
  var choice = negamax(new_game, self.depth)
  return choice


