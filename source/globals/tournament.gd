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

func addRound(newRound: RoundResource, level: int) -> bool:
	if level < 0 or level > len(rounds):
		assert(false, "Rounds tried to be created at higher levels than possible")
		return false
	if level == len(rounds):
		rounds.append([newRound])
	else:
		rounds[level].append(newRound)
	return true

func availableInput(refRoundRes: RoundResource) -> int:
	var prevRound: int = -1
	for roundIndex in range(len(rounds)):
		if refRoundRes in rounds[roundIndex]:
			prevRound = roundIndex - 1
			break
	if prevRound == -1:
		return 0
	var sumPrevOut: int = 0
	var sumOtherIn: int = 0
	for prevRoundRes in rounds[prevRound]:
		sumPrevOut += prevRoundRes.output
	for thisRoundRes in rounds[prevRound + 1]:
		if thisRoundRes == refRoundRes:
			break
		sumOtherIn += thisRoundRes.input
	return sumPrevOut - sumOtherIn
