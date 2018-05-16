import math
import tables
import turn_based_game


let INF = 999999.9
let NEGINF = -999999.9

# NOTES: negamax _requires_ set_possible_moves of type seq

proc negamax_core(game: var Game, ai_choice: var string, depth: int, orig_depth: int, alpha_in: float, beta_in: float): float =

  let
    alpha_orig = alpha_in

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
  if depth == orig_depth:
    ai_choice = best_move
  var best_value = NEGINF

  for move in possible_moves:

    # simulate the next move
    #
    # echo "1>", game.status()
    # echo "1:", game.current_player_number
    game.restore_state(starting_state) # reset the game each time
    # echo "TRY MOVE " & $move
    # echo "2>", game.status()
    # echo "2:", game.current_player_number
    discard game.make_move(move)
    # echo "3>", game.status()
    # echo "2:", game.current_player_number
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

  alpha = INF
  beta = NEGINF

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


# def negamax(game, depth, origDepth, scoring, alpha=+inf, beta=-inf,
#              tt=None):
#     """
#     This implements Negamax with transposition tables.
#     This method is not meant to be used directly. See ``easyAI.Negamax``
#     for an example of practical use.
#     This function is implemented (almost) acccording to
#     http://en.wikipedia.org/wiki/Negamax
#     """
    
#     alphaOrig = alpha
        
        
#     if (depth == 0) or game.is_over():
#         score = scoring(game)
#         if score == 0:
#             return score
#         else:
#             return  (score - 0.01*depth*abs(score)/score)
    
    
#     possible_moves = game.possible_moves()

    
    
#     state = game
#     best_move = possible_moves[0]
#     if depth == origDepth:
#         state.ai_move = possible_moves[0]
        
#     bestValue = -inf
    
    
#     for move in possible_moves:
        
#         game = state.copy() # re-initialize move
        
#         game.make_move(move)
#         game.switch_player()
        
#         move_alpha = - negamax(game, depth-1, origDepth, scoring,
#                                -beta, -alpha, tt)
                
#         # bestValue = max( bestValue,  move_alpha )
#         if bestValue < move_alpha:
#             bestValue = move_alpha
#             best_move = move

#         if  alpha < move_alpha :
#                 alpha = move_alpha
#                 # best_move = move
#                 if depth == origDepth:
#                     state.ai_move = move
#                 if (alpha >= beta):
#                     break

#     if tt != None:
        
#         assert best_move in possible_moves
#         tt.store(game=state, depth=depth, value = bestValue,
#                  move= best_move,
#                  flag = UPPERBOUND if (bestValue <= alphaOrig) else (
#                         LOWERBOUND if (bestValue >= beta) else EXACT))

#     return bestValue
