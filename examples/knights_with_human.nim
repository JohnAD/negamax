#
# Knights, played via console, human vs. human
#

import turn_based_game
import knights

var game = Knights()

game.setup(@[Player(name: "WhiteKnight"), Player(name: "BlackKnight")])

game.play()
