extends RoundResource
class_name SwissRound

var neededWins: int = 2 setget setNeededWins, getNeededWins

func _init() -> void:
	virtualInputMult = 0
	input = 4

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
		return (a["points"] > b["points"])

	static func sortByPointsAsc(a, b):
		return (a["points"] < b["points"])

	static func playerGroupDesc(a, b):
		var aMax: float = 0.0
		var bMax: float = 0.0
		if null in a:
			aMax = -1.0
		else:
			for player in a:
				if player.getPoints() > aMax:
					aMax = player.getPoints()
		if null in b:
			bMax = -1.0
		else:
			for player in b:
				if player.getPoints() > bMax:
					bMax = player.getPoints()
		return aMax > bMax

func _sortPlayersByPoint(playerList: Array) -> Array:
	var playerCopy: Array = []
	var orderedPlayerList: Array = []
	for playerRes in playerList:
		var playerDict: Dictionary = {}
		playerDict["player"] = playerRes
		playerDict["points"] = (
			playerRes.getPoints() + playerRes.virtualPoints * virtualInputMult
		)
		playerCopy.append(playerDict)
	playerCopy.sort_custom(_customSorter, "sortByPointsDesc")
	for playerDict in playerCopy:
		orderedPlayerList.append(playerDict["player"])
	return orderedPlayerList

func _receivePlayers(incoming: Array) -> Array:
	var outgoing: Array  = ._receivePlayers(incoming)
	if not null in _players:
		_players = _sortPlayersByPoint(_players)
	return outgoing

func _createMatchMatrix(playerList: Array) -> Array:
	var pointMatrix: Array = []
	for index in range(len(playerList)):
		var pointList: Array = []
		for index2 in range(index):
			var playerOne: PlayerResource = playerList[index]
			var pointOne: float = 0
			if playerOne != null:
				pointOne = (
					playerOne.getPoints() +
					playerOne.virtualPoints * virtualInputMult
				)
			var playerTwo: PlayerResource = playerList[index2]
			var pointTwo: float = (
				playerTwo.getPoints() +
				playerTwo.virtualPoints * virtualInputMult
			)
			var badnessPoint: float = 0.0
			badnessPoint += Tournament.getMatchesCount(playerOne, playerTwo) * 1000
			badnessPoint += (pointOne - pointTwo) * (pointOne - pointTwo)
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
	allPairings.sort_custom(_customSorter, "sortByPointsAsc")
	_groupings = allPairings[0]["list"]
	_groupings.sort_custom(_customSorter, "playerGroupDesc")
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
		var provisionalList: Array = []
		for playerRes in _players:
			provisionalList.append(null)
		return provisionalList
	return _sortPlayersByPoint(_players)

func _generateLoadedGroupings() -> void:
	var playersCopy: Array = _players.duplicate()
	for matchRes in matchList:
		if matchRes.playerTwo == null:
			_groupings.append([matchRes.playerOne])
			continue
		_groupings.append([matchRes.playerOne, matchRes.playerTwo])

func toDict() -> Dictionary:
	var returnDict: Dictionary = {}
	returnDict["type"] = "swiss"
	returnDict = _toDict(returnDict)
	returnDict["neededWins"] = neededWins
	return returnDict
