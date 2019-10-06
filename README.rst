Introduction to negamax
==============================================================================
ver 0.0.3

.. image:: https://raw.githubusercontent.com/yglukhov/nimble-tag/master/nimble.png
   :height: 34
   :width: 131
   :alt: nimble

Negamax is a nim library for executing the Negamax AI algorithm on a
turn-based game. The library uses the ``turn_based_game`` nimble library as
the framework for the game itself.

The negamax algorithm searches and weighs possible future moves. It is a
varation of the minimax algorithm that is optimized for games where the
"value" of a game's state for one player is directly inverse of the value
to the oppossing player. This is known as a
[zero-sum game](https://en.wikipedia.org/wiki/Zero-sum_game).

This algorithm is desgined to do _alpha/beta pruning_, which shortens the
search tree.

This algorithem is currently recursive. The author is currently working on
a non-recursive one as well.

Negamax has the following restrictions:

1. It only works for two-player games.
2. It does not work with games that involve any randomness.
3. It requires that the value of the board be zero-sum in nature.

Algorithm details:

* https://en.wikipedia.org/wiki/Negamax
* https://en.wikipedia.org/wiki/Minimax

Usage
==========

The bulk of the work is in making the game itself. See the _turn_based_game_
library for details.

* turn_based_game (repo): <https://github.com/JohnAD/turn_based_game>

Once made, simply import the negamax library and use a ``NegamaxPlayer``
instead of a normal ``Player``. Include the ``depth`` of the search as an object
parameter. The depth is measured in **plies**. One **ply** is a single play.
So, one full round of play between two players is two plies.

The Negamax AI specifically requires that the

* ``scoring``,
* ``get_state``, and
* ``restore_state``

methods be defined. Again, see the _turn_based_game_ docs for details.

Simple Example
===============

.. code:: nim

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

For the content pulled by "import knights", see
https://github.com/JohnAD/negamax/blob/master/examples/knights.nim

Videos
============

The following two videos (to be watched in sequence), demonstrate how to use
this library and the ``turn_based_game`` library:

* Using "turn_based_game": https://www.youtube.com/watch?v=u6w8vT-oBjE
* Using "negamax": https://www.youtube.com/watch?v=op4Mcgszshk

Credit
=============

The code for this engine mimics that written in Python at the EasyAI library
located at <https://github.com/Zulko/easyAI>. That library contains both
the game rule engine (called TwoPlayerGame) as well as a variety of AI
algorithms to play as game players, such as Negamax.



Table Of Contents
=================

1. `Introduction to negamax <https://github.com/JohnAD/negamax>`__
2. Appendices

    A. `negamax Reference <https://github.com/JohnAD/negamax/blob/master/docs/negamax-ref.rst>`__
