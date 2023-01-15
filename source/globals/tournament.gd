extends Node

# Rounds: an array of arrays. Each array is a level of parallel rounds.
# ie. [[seed_1], [group_matches, seed_2], [dual_tournament, seed_3], [single_elimination]]
var rounds: Array = []
var endResult: EndResultRound

var roundTypeNames: Dictionary = {
	"dual": DualTourneyRound,
	"elimination": EliminationRound,
	"forward": ForwardRound,
	"group": GroupRound,
	"seed": SeedRound,
	"swiss": SwissRound
}

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

func addRoundNum(playersListed: Array, prefix: String):
	for index in range(len(playersListed)):
		if playersListed[index] is String:
			playersListed[index] = (
				prefix + "-" + playersListed[index]
			)

func progressTourney() -> void:
	endResult = EndResultRound.new()
	var playersListed: Array = []
	for level in rounds:
		for roundRes in level:
			var playerNumToSend: int = min(len(playersListed), roundRes.input)
			var playersToSend: Array = playersListed.slice(0, playerNumToSend - 1)
			playersListed = playersListed.slice(
				playerNumToSend, len(playersListed) - 1
			)
			playersListed = (
				roundRes.receivePlayers(playersToSend) + playersListed
			)
		addRoundNum(playersListed, str(rounds.find(level) - 1))
		endResult.receivePlayers(playersListed)
		playersListed = []
		for roundRes in level:
			playersListed += roundRes.getOutPlayerList()
	addRoundNum(playersListed, str(len(rounds)-1))
	endResult.receivePlayers(playersListed)

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

func getPoints(playerRes: PlayerResource, untilRound: int) -> int:
	assert(untilRound < len(rounds))
	var counter: int = 0
	var roundNum: int = 0
	if untilRound == -1:
		untilRound = len(rounds)
	while roundNum < untilRound:
		var level: Array = rounds[roundNum]
		for roundRes in level:
			counter += roundRes.getWins(playerRes)
		roundNum += 1
	return counter

func getGameNumber(playerRes: PlayerResource, untilRound: int) -> int:
	assert(untilRound < len(rounds))
	var counter: int = 0
	var roundNum: int = 0
	if untilRound == -1:
		untilRound = len(rounds)
	while roundNum < untilRound:
		var level: Array = rounds[roundNum]
		for roundRes in level:
			counter += roundRes.getMatchPlayed(playerRes)
		roundNum += 1
	return counter

func getOpponentPointSum(playerRes: PlayerResource, untilRound: int) -> int:
	assert(untilRound < len(rounds))
	var counter: int = 0
	var matchList: Array = getMatches(playerRes, untilRound)
	for matchRes in matchList:
		var opponent: PlayerResource
		if matchRes.playerOne == playerRes and matchRes.playerTwo != null:
			opponent = matchRes.playerTwo
		elif matchRes.playerTwo == playerRes:
			opponent = matchRes.playerOne
		else:
			assert(
				matchRes.playerTwo == null,
				"This match is irrelevant for this player"
			)
			continue
		counter += getPoints(opponent, untilRound)
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

func getMatches(player: PlayerResource, untilRound: int = -1) -> Array:
	assert(untilRound < len(rounds))
	var matchList: Array = []
	var roundNum: int = 0
	if untilRound == -1:
		untilRound = len(rounds)
	while roundNum < untilRound:
		var level: Array = rounds[roundNum]
		for roundRes in level:
			for matchRes in roundRes.matchList:
				if (
					player in [matchRes.playerOne, matchRes.playerTwo]
				):
					matchList.append(matchRes)
		roundNum += 1
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
			assert(matchRes.playerTwo == null, "Something went wrong")
			continue
		vsRace = vsPlayer.getPlayedRaceVs(reprRace)
		recordDict[vsRace]["win"] += matchRes.getWins()[player]
		recordDict[vsRace]["loss"] += matchRes.getLoss()[player]
	return recordDict

func getRoundType(roundRes: RoundResource) -> String:
	for roundName in roundTypeNames:
		if roundRes is roundTypeNames[roundName]:
			return roundName
	assert(false)
	return ""

func getRoundName(roundRes: RoundResource) -> String:
	var roundIndex: int
	for levelIndex in range(len(rounds)):
		roundIndex = rounds[levelIndex].find(roundRes)
		if roundIndex == -1:
			continue
		var roundName: String = (
			getRoundType(roundRes) + "-" +
			str(roundIndex + 1)
		)
		return roundName
	return ""

func getLevelNum(roundRes: RoundResource) -> int:
	for index in range(len(rounds)):
		if roundRes in rounds[index]:
			return index
	return -1
