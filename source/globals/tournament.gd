extends Node

# Rounds: an array of arrays. Each array is a level of parallel rounds.
# ie. [[seed_1], [group_matches, seed_2], [double_elimination, seed_3], [single elimination]]
var rounds: Array = []

func isPlayerSeeded(player: PlayerResource) -> bool:
	for level in rounds:
		for gameRound in level:
			if gameRound is SeedRound and gameRound.hasPlayer(player):
				return true
	return false
