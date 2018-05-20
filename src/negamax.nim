import math
import tables
import turn_based_game


let INF = 999999.9
let NEGINF = -999999.9

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
  var best_value = NEGINF

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

  var
    alpha: float
    beta: float
    ai_choice: string
    possible_moves: seq[string] = @[]

  alpha = NEGINF
  beta = INF


  # set the starting default
  game.set_possible_moves(possible_moves)
  if len(possible_moves) == 0:
    return nil
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
    depth*: int


# TODO: verify that default depth=0 works-ish
#
method get_move*(self: NegamaxPlayer, game: Game): string = 
  var new_game: Game
  deepCopy(new_game, game)
  var choice = negamax(new_game, self.depth)
  return choice


