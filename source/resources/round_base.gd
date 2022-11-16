extends Resource
class_name RoundResource

var input: int = 0 setget setInput, getInput
var output: int = 0 setget setOutput, getOutput
var virtualInputMult: float = 0.0
var mapPool: Array = [] setget fail, getMapPool
var matchList: Array = [] setget fail, getMatchList
var _players: Array = []
var _groupings: Array = [] # contains arrays of players who are considered to be groups

signal roundFinished

func fail(input) -> void:
	assert (false, "You should not change this on the fly")

func getOutput() -> int:
	return output

func setOutput(newOutput: int) -> void:
	output = newOutput

func getInput() -> int:
	return input

func setInput(newInput: int) -> void:
	input = newInput

func getMapPool() -> Array:
	return mapPool.duplicate()

func getMatchList() -> Array:
	return matchList.duplicate()

func addMap(newMap: MapResource) -> void:
	if newMap in mapPool:
		printerr("Trying to add a map already on the list.")
		return
	if len(matchList) > 0:
		printerr("Matches already generated, can't change map pool.")
		return
	mapPool.append(newMap)

func removeMap(mapRes: MapResource) -> void:
	if not mapRes in mapPool:
		printerr("Trying to act on a map not on the list.")
		return
	if len(matchList) > 0:
		printerr("Matches already generated, can't change map pool.")
		return
	var index: int = mapPool.find(mapRes)
	mapPool.pop_at(index)

func moveMap(mapRes: MapResource, position: int) -> void:
	if position < 0 or position >= len(mapPool):
		printerr("Trying to move a map to an unavailable position.")
		return
	if not mapRes in mapPool:
		printerr("Trying to act on a map not on the list.")
		return
	if len(matchList) > 0:
		printerr("Matches already generated, can't change map pool.")
		return
	var index: int = mapPool.find(mapRes)
	mapPool[index] = mapPool[position]
	mapPool[position] = mapRes

# Receives an array of players; returns the array of players that don't fit
# into this round based on the "input" variable
func receivePlayers(incoming: Array) -> Array:
	if len(_players) > 0:
		printerr("Players already set.")
		return incoming.duplicate()
	var outgoing: Array = _receivePlayers(incoming)
	_generateGroupings()
	_generateMatches()
	return outgoing

func _receivePlayers(incoming: Array) -> Array:
	var outgoing: Array = []
	for playerRes in incoming:
		if len(_players) >= getInput():
			outgoing.append(playerRes)
		else:
			_players.append(playerRes)
	return outgoing

func _generateGroupings() -> void:
	for index in range((len(_players) + 1) / 2):
		if index * 2 + 1 >= len(_players):
			_groupings.append([_players[index * 2]])
		else:
			_groupings.append([
				_players[index * 2],
				_players[index * 2 + 1],
			])

func getGroupings() -> Array:
	var groupList: Array = []
	for playerGroup in _groupings:
		var playerGroupList: Array = []
		for playerRes in playerGroup:
			var playerDict: Dictionary = {
				"player": playerRes,
				"win": getWins(playerRes),
				"loss": getLoss(playerRes)
			}
			playerGroupList.append(playerDict)
		groupList.append(playerGroupList)
	return groupList

func getWins(playerRes: PlayerResource) -> int:
	var winCount: int = 0
	for matchRes in matchList:
		if matchRes.playerOne == playerRes or matchRes.playerTwo == playerRes:
			winCount += matchRes.getWins()[matchRes]
	return winCount

func getLoss(playerRes: PlayerResource) -> int:
	var winCount: int = 0
	for matchRes in matchList:
		if matchRes.playerOne == playerRes or matchRes.playerTwo == playerRes:
			winCount += matchRes.getLoss()[matchRes]
	return winCount

func _generateMatches() -> void:
	# Whenever the matches are generated, their signal "newWinRegistered" should be
	# connected here with the "_matchChanged" function!
	pass

func _matchChanged(changeMatch: MatchResource) -> void:
	if isOver():
		emit_signal("roundFinished", self)

# Checks whether all matches to be played has been played or not
func isOver() -> bool:
	return false

func isStarted() -> bool:
	return (len(_players) > 0)

func getOutPlayerList() -> Array:
	if not isOver():
		return []
	return _players

func _toDict(data: Dictionary) -> Dictionary:
	var mapPoolDict: Dictionary = {}
	var playerDict: Dictionary = {}
	for mapIndex in range(len(mapPool)):
		var map: MapResource = mapPool[mapIndex]
		mapPoolDict[mapIndex] = Global.maps.keys()[Global.maps.values().find(map)]
	for playerIndex in range(len(_players)):
		var player: PlayerResource = _players[playerIndex]
		playerDict[playerIndex] = Global.players.keys()[Global.players.values().find(player)]
	data["input"] = input
	data["output"] = output
	data["virtualInputMult"] = virtualInputMult
	data["mapPool"] = mapPoolDict
	data["players"] = playerDict
	return data

func toDict() -> Dictionary:
	var returnDict: Dictionary = {}
	returnDict = _toDict(returnDict)
	return returnDict
