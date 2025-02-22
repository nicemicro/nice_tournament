extends RoundResource
class_name SwissRound

var neededWins: int = 2: get = getNeededWins, set = setNeededWins

func _init() -> void:
	virtualInputMult = 0
	input = 4
	_type = "swiss"

func getOutput() -> int:
	return input

func setOutput(newOutput: int) -> void:
	fail(newOutput)

func setNeededWins(newNum: int) -> void:
	if newNum < 1:
		return
	neededWins = newNum

func getNeededWins() -> int:
	return neededWins

class _customSorter:
	static func sortByPointsDesc(a, b):
		if a["points"] > b["points"]:
			return true
		if a["points"] < b["points"]:
			return false
		if "gameNumber" in a and "gameNumber" in b:
			if a["gameNumber"] < b["gameNumber"]:
				return true
			if a["gameNumber"] > b["gameNumber"]:
				return false
		if not "opponentPoints" in a or not "opponentPoints" in b:
			return false
		return (a["opponentPoints"] > b["opponentPoints"])

	static func sortByPointsAsc(a, b):
		return (a["points"] < b["points"])

	static func playerGroupDesc(a, b):
		var aMax: float = 0.0
		var bMax: float = 0.0
		if null in a:
			aMax = -1.0
		else:
			for player in a:
				if player.getPoints(-1) > aMax:
					aMax = player.getPoints(-1)
		if null in b:
			bMax = -1.0
		else:
			for player in b:
				if player.getPoints(-1) > bMax:
					bMax = player.getPoints(-1)
		return aMax > bMax

func sortPlayersByPoint(
	noVirtPts: bool = false,
	givePoints: bool = false
) -> Array:
	var playerList: Array = _players.duplicate()
	var playerCopy: Array = []
	var orderedPlayerList: Array = []
	var currentRound: int = Tournament.getLevelNum(self)
	for playerRes in playerList:
		var playerDict: Dictionary = {}
		playerDict["player"] = playerRes
		playerDict["points"] = (
			playerRes.getPoints(currentRound + 1)
		)
		if not noVirtPts:
			playerDict["points"] += playerRes.virtualPoints * virtualInputMult
		playerDict["opponentPoints"] = (
			playerRes.getOpponentPointSum(currentRound + 1)
		)
		playerDict["gameNumber"] = playerRes.getGameNumber(currentRound + 1, true)
		playerCopy.append(playerDict)
	playerCopy.sort_custom(Callable(_customSorter, "sortByPointsDesc"))
	if givePoints:
		return playerCopy
	#print("-------------- round ", currentRound, " ----------------")
	for playerDict in playerCopy:
		#print(
			#playerDict["player"].name, " ",
			#playerDict["points"], " ",
			#playerDict["gameNumber"], " ",
			#playerDict["opponentPoints"], " ",
		#)
		orderedPlayerList.append(playerDict["player"])
	return orderedPlayerList

func _receivePlayers(incoming: Array) -> Array:
	var outgoing: Array  = super._receivePlayers(incoming)
	if not _allPlayerReceived():
		var playerNum: int = len(_players)
		_players = []
		for index in range(playerNum):
			_players.append(null)
			outgoing.pop_front()
	return outgoing

func _createMatchMatrix(playerList: Array) -> Array:
	var currentRound: int = Tournament.getLevelNum(self)
	var pointMatrix: Array = []
	for index in range(len(playerList)):
		var pointList: Array = []
		for index2 in range(index):
			var playerOne: PlayerResource = playerList[index]
			var pointOne: float = -1
			if playerOne != null:
				pointOne = (
					playerOne.getPoints(currentRound) +
					playerOne.virtualPoints * virtualInputMult
				)
			var playerTwo: PlayerResource = playerList[index2]
			var pointTwo: float = (
				playerTwo.getPoints(currentRound) +
				playerTwo.virtualPoints * virtualInputMult
			)
			var badnessPoint: float = 0.0
			badnessPoint += Tournament.getMatchesCount(playerOne, playerTwo) * 1000
			badnessPoint += (pointOne - pointTwo) * (pointOne - pointTwo)
			#when the virtual points are taken into account, we try to pair the
			#winners of lower VPs with the losers of higher VPs as a tiebreaker
			if (
				playerOne != null and
				virtualInputMult > 0 and
				abs(pointOne - pointTwo) <= 1
			):
				badnessPoint += float(int(10 / (abs(float(
					playerOne.virtualPoints * virtualInputMult -
					playerTwo.virtualPoints * virtualInputMult
				)) + 1))) / 1000.0
			#the position of the players from the list is used as additional tiebreaker
			badnessPoint += float(index - index2) / 10000.0
			if playerList[index] == null:
				badnessPoint += float(index - index2) / 5000.0
			pointList.append(badnessPoint)
		pointMatrix.append(pointList)
	return pointMatrix

func _findAllPairings(playerList: Array, pointMatrix: Array, ignore: int) -> Array:
	if len(playerList) <= 2:
		assert(len(playerList) == 2, "Even numbered players should be handled elsewhere.")
		var origIndexOne: int = _players.find(playerList[0])
		var origIndexTwo: int = _players.find(playerList[1])
		var point: float = pointMatrix[origIndexTwo][origIndexOne]
		return [{"list": [playerList], "points": point}]
	var comboList: Array = []
	for index in range(1, len(playerList)):
		var origIndexOne: int = _players.find(playerList[0])
		var origIndexTwo: int = _players.find(playerList[index])
		var point: float = pointMatrix[origIndexTwo][origIndexOne]
		if point > ignore and index > 1:
			continue
		var copyList: Array = playerList.duplicate()
		var firstPair: Array = []
		var newComboList: Array = []
		firstPair.append(copyList.pop_at(0))
		firstPair.append(copyList.pop_at(index - 1)) # (one element already dropped!)
		for generatedComboList in _findAllPairings(copyList, pointMatrix, ignore):
			var newElement: Dictionary = {}
			newElement["list"] = [firstPair] + generatedComboList["list"]
			newElement["points"] = point + generatedComboList["points"]
			newComboList.append(newElement)
		comboList += newComboList
	return comboList

func _generateGroupings() -> void:
	if not _allPlayerReceived():
		super._generateGroupings()
		return
	var playerList = _players.duplicate()
	if len(playerList) % 2 == 1:
		playerList.append(null)
	var matchMatrix: Array = _createMatchMatrix(playerList)
	var maxBadness: int = 0
	for matchArray in matchMatrix:
		if len(matchArray) > 0:
			if matchArray.max() > maxBadness:
				maxBadness = matchArray.max()
	var allPairings: Array = (
		_findAllPairings(playerList, matchMatrix, maxBadness / 2)
	)
	allPairings.sort_custom(Callable(_customSorter, "sortByPointsAsc"))
	_groupings = allPairings[0]["list"]
	_groupings.sort_custom(Callable(_customSorter, "playerGroupDesc"))
	if _groupings[-1][1] == null:
		_groupings[-1].pop_back()

func _generateMaplist(playerList: Array) -> Array:
	var mapVetoList: Array = []
	for playerRes in playerList:
		mapVetoList.append(playerRes.mapVeto)
	var maplist: Array = _generateMaplistCore(
		mapVetoList, neededWins * 2 - 1
	)
	return maplist

func isOver() -> bool:
	if len(matchList) == 0:
		return false
	for matchRes in matchList:
		if not matchRes.isOver():
			return false
	return true

func _getOutPlayerList() -> Array:
	if not isOver():
		return _getProvisinalOutPlayerList()
	return sortPlayersByPoint(true)

func _generateLoadedGroupings() -> void:
	#var playersCopy: Array = _players.duplicate()
	for matchRes in matchList:
		if matchRes.playerTwo == null:
			_groupings.append([matchRes.playerOne])
			continue
		_groupings.append([matchRes.playerOne, matchRes.playerTwo])

func getMatchPlayed(playerRes: PlayerResource, countUnpaired: bool) -> int:
	var count: int = super.getMatchPlayed(playerRes, countUnpaired)
	if count > 0 or not countUnpaired:
		return count
	for matchRes in _matchList:
		if (
			matchRes.playerTwo == playerRes or matchRes.playerOne == playerRes and
			matchRes.playerTwo == null or matchRes.playerOne == null
		):
			count += int(neededWins + neededWins / 2)
	return count

func toDict() -> Dictionary:
	var returnDict: Dictionary = {}
	returnDict["type"] = "swiss"
	returnDict = _toDict(returnDict)
	returnDict["neededWins"] = neededWins
	return returnDict
