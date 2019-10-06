negamax Reference
==============================================================================

The following are the references for negamax.



Types
=====



.. _NegamaxPlayer.type:
NegamaxPlayer
---------------------------------------------------------

    .. code:: nim

        NegamaxPlayer* = ref object of Player
          depth*: int


    source line: `215 <../src/negamax.nim#L215>`__

    this is the AI player to be used with the ``turn_based_game`` library






Procs, Methods, Iterators
=========================


.. _get_move.e:
get_move
---------------------------------------------------------

    .. code:: nim

        method get_move*(self: NegamaxPlayer, game: Game): string =

    source line: `220 <../src/negamax.nim#L220>`__

    Get the chosen move from the algorithm in the context of a
    ``turn_based_game`` library ``Game``.


.. _negamax.p:
negamax
---------------------------------------------------------

    .. code:: nim

        proc negamax*(game: var Game, depth: int): string =

    source line: `175 <../src/negamax.nim#L175>`__

    This is the main negamax algorithm.
    
    ``depth`` determines the number of *plies* for the algorithm
    to look ahead.
    
    returns a string ``move`` from the ``game``'s list of
    available possible moves. If the game is over, it will
    likely return an empty string.







Table Of Contents
=================

1. `Introduction to negamax <https://github.com/JohnAD/negamax>`__
2. Appendices

    A. `negamax Reference <negamax-ref.rst>`__
