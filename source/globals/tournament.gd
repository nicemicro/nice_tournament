extends Node

# Rounds: an array of arrays. Each array is a level of parallel rounds.
# ie. [[seed_1], [group_matches, seed_2], [dual_tournament, seed_3], [single_elimination]]
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
	newRound.connect("roundFinished", self, "_roundFinished")
	if level == len(rounds):
		rounds.append([newRound])
	else:
		rounds[level].append(newRound)
	return true

func _roundFinished(finishedRound: RoundResource) -> void:
	progressTourney()

func progressTourney() -> void:
	var lastLevel: int = -1
	for levelIndex in range(len(rounds)):
		var level = rounds[levelIndex]
		var allDone: bool = true
		for roundRes in level:
			allDone = roundRes.isOver() and allDone
		if not allDone:
			break
		lastLevel = levelIndex
	if lastLevel >= len(rounds) - 1:
		print_debug("Seems like the tournament is over!")
		return
	var startedAlready: bool = true
	for roundRes in rounds[lastLevel + 1]:
		startedAlready = roundRes.isStarted() and startedAlready
	if startedAlready:
		# We already started this round, there's nothing to do for now.
		return
	var playersListed: Array = []
	for roundRes in rounds[lastLevel]:
		playersListed += roundRes.getOutPlayerList()
	for roundRes in rounds[lastLevel + 1]:
		playersListed = roundRes.receivePlayers(playersListed)

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

func getPoints(playerRes: PlayerResource) -> int:
	var counter: int = 0
	for level in rounds:
		for roundRes in level:
			counter += roundRes.getWins(playerRes)
	return counter

func getMatchesCount(playerOne: PlayerResource, playerTwo: PlayerResource) -> int:
	var counter: int = 0
	for level in rounds:
		for roundRes in level:
			for matchRes in roundRes.matchList:
				if (
					playerOne in [matchRes.playerOne, matchRes.playerTwo] and
					playerTwo in [matchRes.playerOne, matchRes.playerTwo]
				):
					counter += 1
	return counter

func getMatches(player: PlayerResource) -> Array:
	var matchList: Array = []
	for level in rounds:
		for roundRes in level:
			for matchRes in roundRes.matchList:
				if (
					player in [matchRes.playerOne, matchRes.playerTwo]
				):
					matchList.append(matchRes)
	return matchList

func getCurrentRecord(player: PlayerResource) -> Dictionary:
	var recordDict: Dictionary = {}
	var reprRace: int = player.getReprRace()
	var matchList: Array = getMatches(player)
	for race in Global.Race.values():
		recordDict[int(race)] = {"win": 0, "loss": 0}
	var vsPlayer: PlayerResource
	for matchRes in matchList:
		var vsRace: int
		if matchRes.playerOne == player and matchRes.playerTwo != null:
			vsPlayer = matchRes.playerTwo
		elif matchRes.playerTwo == player:
			vsPlayer = matchRes.playerOne
		else:
			assert(matchRes.PlayerTwo == null, "Something went wrong")
			continue
		vsRace = vsPlayer.getPlayedRaceVs(reprRace)
		recordDict[vsRace]["win"] += matchRes.getWins()[player]
		recordDict[vsRace]["loss"] += matchRes.getLoss()[player]
	return recordDict
