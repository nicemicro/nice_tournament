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

class _playerSorter:
	static func sortByPoints(a, b):
		return (a["points"] > b["points"])

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
	playerCopy.sort_custom(_playerSorter, "sortByPoints")
	for playerDict in playerCopy:
		orderedPlayerList.append(playerDict["player"])
	return orderedPlayerList

func _removeReplays(playerList: Array) -> Array:
	playerList = playerList.duplicate()
	var modifiedPlayerList: Array = []
	for index in range((len(playerList) + 1) / 2):
		modifiedPlayerList.append(playerList.pop_front())
		if len(playerList) == 0:
			break
		#TODO: actually look for someone not played with
		modifiedPlayerList.append(playerList.pop_front())
	return modifiedPlayerList

func _receivePlayers(incoming: Array) -> Array:
	var outgoing: Array  = ._receivePlayers(incoming)
	_players = _sortPlayersByPoint(_players)
	_players = _removeReplays(_players)
	return outgoing

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

func getOutPlayerList() -> Array:
	if not isOver():
		return []
	return _sortPlayersByPoint(_players)

func toDict() -> Dictionary:
	var returnDict: Dictionary = {}
	returnDict["type"] = "swiss"
	returnDict = _toDict(returnDict)
	returnDict["neededWins"] = neededWins
	return returnDict
