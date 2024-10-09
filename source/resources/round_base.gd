extends Resource
class_name RoundResource

var type: String = "": get = getType, set = fail
var _type: String = ""
var input: int = 0: get = getInput, set = setInput
var _input: int = 0
var output: int = 0: get = getOutput, set = setOutput
var _output: int = 0
var virtualInputMult: float = 0.0
var mapPool: Array = []: get = getMapPool, set = fail
var _mapPool: Array = []
var matchList: Array = []: get = getMatchList, set = fail
var _matchList: Array = []
var _players: Array = []
var _groupings: Array = [] # contains arrays of players who are considered to be groups

signal roundFinished

func fail(_anything) -> void:
	assert (false, "You should not change this on the fly")

func getType() -> String:
	return _type

func getOutput() -> int:
	return _output

func setOutput(newOutput: int) -> void:
	_output = newOutput

func getInput() -> int:
	return _input

func setInput(newInput: int) -> void:
	_input = newInput

func getMapPool() -> Array:
	return _mapPool.duplicate()

func getMatchList() -> Array:
	return _matchList.duplicate()

func addMap(newMap: MapResource) -> void:
	if newMap in _mapPool:
		printerr("Trying to add a map already on the list.")
		return
	if len(_matchList) > 0:
		printerr("Matches already generated, can't change map pool.")
		return
	_mapPool.append(newMap)

func removeMap(mapRes: MapResource) -> void:
	if not mapRes in _mapPool:
		printerr("Trying to act on a map not on the list.")
		return
	if len(_matchList) > 0:
		printerr("Matches already generated, can't change map pool.")
		return
	var index: int = _mapPool.find(mapRes)
	_mapPool.pop_at(index)

func moveMap(mapRes: MapResource, position: int) -> void:
	if position < 0 or position >= len(_mapPool):
		printerr("Trying to move a map to an unavailable position.")
		return
	if not mapRes in _mapPool:
		printerr("Trying to act on a map not on the list.")
		return
	if len(_matchList) > 0:
		printerr("Matches already generated, can't change map pool.")
		return
	var index: int = _mapPool.find(mapRes)
	_mapPool[index] = _mapPool[position]
	_mapPool[position] = mapRes

func _allPlayerReceived() -> bool:
	if len(_players) == 0:
		return false
	for playerRes in _players:
		if playerRes == null or not playerRes is PlayerResource:
			assert(playerRes == null or playerRes is String)
			return false
	return true

func _validMapPool() -> bool:
	return len(_mapPool) > 0
# Receives an array of players; returns the array of players that don't fit
# into this round based on the "input" variable
func receivePlayers(incoming: Array) -> Array:
	if not _validMapPool():
		printerr("There is no map pool set, can't start this now.")
		assert(false)
		return incoming.duplicate()
	if _allPlayerReceived():
		var outgoing: Array = []
		for playerRes in incoming:
			if not playerRes in _players:
				outgoing.append(playerRes)
		return outgoing
	_players = []
	var outgoings: Array = _receivePlayers(incoming)
	_groupings = []
	_generateGroupings()
	if _allPlayerReceived():
		_generateMatches()
	return outgoings

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

func _generateMatches() -> void:
	# Whenever the matches are generated, their signal "newWinRegistered" should be
	# connected here with the "_matchChanged" function!
	if len(_matchList) > 0:
		printerr("Can't generate mathes again")
		assert(false)
		return
	for playerGroup in _groupings:
		if len(playerGroup) == 0:
			continue
		if len(playerGroup) == 1:
			var maplist: Array = _generateMaplist([playerGroup[0]])
			var newMatchRes: MatchResource = MatchResource.new(
				playerGroup[0], null, maplist
			)
			_matchList.append(newMatchRes)
			continue
		for index1 in range(len(playerGroup) - 1):
			for index2 in range(index1 + 1, len(playerGroup), 1):
				var maplist: Array = _generateMaplist(
					[playerGroup[index1], playerGroup[index2]]
				)
				var newMatchRes: MatchResource = MatchResource.new(
					playerGroup[index1],
					playerGroup[index2],
					maplist
				)
				_matchList.append(newMatchRes)

# This is a prototype map generator that only returns one map! Needs to be
# overwritten for the specific rounds.
func _generateMaplist(playerList: Array) -> Array:
	var mapVetoList: Array = []
	for playerRes in playerList:
		mapVetoList.append(playerRes.mapVeto)
	var maplist: Array = _generateMaplistCore(
		mapVetoList, 1
	)
	return maplist

func _generateMaplistCore(vetoMaps: Array, neededMaps: int) -> Array:
	var maplist: Array = []
	var index: int = 0
	while len(maplist) < neededMaps:
		if not _mapPool[index] in vetoMaps:
			maplist.append(_mapPool[index])
		index += 1
		if index >= len(_mapPool):
			index = 0
			if len(maplist) == 0:
				assert(false, "No non-vetod maps! This would end up in an infinite loop!")
				return maplist
	return maplist

func getGroupings() -> Array:
	var groupList: Array = []
	for playerGroup in _groupings:
		var playerGroupList: Array = []
		for player in playerGroup:
			if player == null:
				playerGroupList.append(null)
				continue
			if player is String:
				playerGroupList.append(player)
				continue
			var playerDict: Dictionary = {}
			if player is PlayerResource:
				playerDict["player"] = player
				playerDict["win"] = getWins(player)
				playerDict["loss"] = getLoss(player)
			playerGroupList.append(playerDict)
		groupList.append(playerGroupList)
	return groupList

func getWins(playerRes: PlayerResource) -> int:
	var winCount: int = 0
	for matchRes in _matchList:
		if matchRes.playerOne == playerRes or matchRes.playerTwo == playerRes:
			var matchWins: Dictionary = matchRes.getWins()
			winCount += matchWins[playerRes]
	return winCount

func getLoss(playerRes: PlayerResource) -> int:
	var winCount: int = 0
	for matchRes in _matchList:
		if matchRes.playerOne == playerRes or matchRes.playerTwo == playerRes:
			winCount += matchRes.getLoss()[playerRes]
	return winCount

func getMatchPlayed(playerRes: PlayerResource) -> int:
	var count: int = 0
	for matchRes in _matchList:
		if matchRes.playerOne == playerRes or matchRes.playerTwo == playerRes:
			count += matchRes.getPlayedRounds()
	return count

func _matchChanged(changeMatch: MatchResource) -> void:
	if isOver():
		emit_signal("roundFinished", self)

# Checks whether all matches to be played has been played or not
func isOver() -> bool:
	return false

func isStarted() -> bool:
	if len(_players) == 0:
		return false
	for player in _players:
		if player is String or player == null:
			return false
	return true

func _getProvisinalOutPlayerList() -> Array:
	var provisionalList: Array = []
	var name: String = Tournament.getRoundName(self)
	for playerIndex in range(len(_players)):
		provisionalList.append(
			name + "/" + str(playerIndex + 1)
		)
	return provisionalList

func _getOutPlayerList() -> Array:
	return _players

func getOutPlayerList() -> Array:
	if not isStarted():
		return _getProvisinalOutPlayerList()
	return _getOutPlayerList()

func loadPlayersMatches(playerList: Array, newMatchList: Array) -> void:
	if len(_players) > 0 or len(_matchList) > 0:
		printerr("Can't load players and matches once they exist")
		assert(false)
		return
	_players = playerList.duplicate()
	_matchList = newMatchList.duplicate()
	_generateLoadedGroupings()

func _generateLoadedGroupings() -> void:
	_generateGroupings()

func _toDict(data: Dictionary) -> Dictionary:
	var mapPoolDict: Dictionary = {}
	var playerDict: Dictionary = {}
	var matchDict: Dictionary = {}
	for mapIndex in range(len(_mapPool)):
		var map: MapResource = _mapPool[mapIndex]
		mapPoolDict[mapIndex] = Global.getMapId(map)
	for playerIndex in range(len(_players)):
		if _players[playerIndex] is PlayerResource:
			playerDict[playerIndex] = Global.getPlayerId(_players[playerIndex])
		else:
			playerDict = {}
			break
	for matchIndex in range(len(_matchList)):
		var matchRes: MatchResource = _matchList[matchIndex]
		matchDict[matchIndex] = matchRes.toDict()
	data["type"] = self.type
	data["input"] = input
	data["output"] = output
	data["virtualInputMult"] = virtualInputMult
	data["mapPool"] = mapPoolDict
	data["players"] = playerDict
	data["matches"] = matchDict
	return data

func toDict() -> Dictionary:
	var returnDict: Dictionary = {}
	returnDict = _toDict(returnDict)
	return returnDict
