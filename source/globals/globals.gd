extends Node

enum  Race {
	PROTOSS,
	ZERG,
	TERRAN,
	RANDOM,
}

const RaceName: Dictionary = {
	Race.PROTOSS: "Protoss",
	Race.ZERG: "Zerg",
	Race.TERRAN: "Terran",
	Race.RANDOM: "Random"
}

var players: Dictionary = {}: get = getPlayers, set = fail
var _players: Dictionary = {}
var maps: Dictionary = {}: get = getMaps, set = fail
var _maps: Dictionary = {}
var previousResults: Dictionary = {}: get = getPreviousResults, set = fail
var _previousResults: Dictionary = {}


func fail(_input) -> void:
	assert (false, "You should not change this on the fly")

func registerNewPlayer(newPlayer: PlayerResource) -> void:
	var time = Time.get_time_dict_from_system(true)
	var time_return: int = time.hour * 10000 + time.minute * 100 + time.second
	var newId: String
	newId = "%x" % (time_return * 10000 + (randi() % 10000))
	_players[newId] = newPlayer

func registerNewMap(newMap: MapResource) -> void:
	var time = Time.get_time_dict_from_system(true)
	var time_return: int = time.hour * 10000 + time.minute * 100 + time.second
	var newId: String
	newId = "%x" % (time_return * 10000 + (randi() % 10000))
	_maps[newId] = newMap
	
func getPlayers() -> Dictionary:
	return _players.duplicate()

func getPlayerNames() -> Array:
	var names: Array = []
	for playerId in _players:
		names.append(_players[playerId].getName())
	return names

func getPlayerId(playerRes: PlayerResource) -> String:
	if playerRes == null:
		return ""
	if not playerRes in _players.values():
		printerr("Trying to get ID for a player not on the list")
		assert(false)
		return ""
	return _players.keys()[_players.values().find(playerRes)]

func getMapId(mapRes: MapResource) -> String:
	return _maps.keys()[_maps.values().find(mapRes)]

func getMaps() -> Dictionary:
	return _maps.duplicate()

func getPreviousResults() -> Dictionary:
	return _previousResults

func saveMaps() -> void:
	var mapData: Dictionary = {}
	for mapId in _maps:
		mapData[mapId] = _maps[mapId].toDict()
		_maps[mapId].icon.save_png("user://" + mapId + ".png")
	var fileSave = FileAccess.open("user://maps.json", FileAccess.WRITE)
	fileSave.store_line(JSON.stringify(mapData))
	fileSave.close()

func loadMaps() -> void:
	var mapData: Dictionary
	var icon: Image
	if not FileAccess.file_exists("user://maps.json"):
		return
	var file = FileAccess.open("user://maps.json", FileAccess.READ)
	var test_json_conv = JSON.new()
	test_json_conv.parse(file.get_as_text())
	mapData = test_json_conv.get_data()
	for id in mapData:
		icon = Image.new()
		icon.load("user://" + id + ".png")
		_maps[id] = MapResource.new(
			mapData[id]["name"],
			icon,
			processPreviousRecordData(mapData[id]["previousRecord"])
		)

func savePlayers() -> void:
	var playerData: Dictionary = {}
	for playerId in _players:
		playerData[playerId] = _players[playerId].toDict()
		_players[playerId].avatar.save_png("user://" + playerId + ".png")
	var fileSave = FileAccess.open("user://players.json", FileAccess.WRITE)
	fileSave.store_line(JSON.stringify(playerData))
	fileSave.close()

func loadPreviousData() -> void:
	if not FileAccess.file_exists("user://previous_games.json"):
		return
	var file = FileAccess.open("user://previous_games.json", FileAccess.READ)
	var test_json_conv = JSON.new()
	test_json_conv.parse(file.get_as_text())
	var tempResults = test_json_conv.get_data()
	for playerName in tempResults:
		_previousResults[playerName] = {}
		for raceId in tempResults[playerName]:
			var raceNum: int = int(raceId)
			_previousResults[playerName][raceNum] = {
				"results": {},
				"rank": null
			}
			if "results" in tempResults[playerName][raceId]:
				for vsId in tempResults[playerName][raceId]["results"]:
					var vsNum = int(vsId)
					_previousResults[playerName][raceNum]["results"][vsNum] = (
						tempResults[playerName][raceId]["results"][vsId]
					)
			if "rank" in tempResults[playerName][raceId]:
				_previousResults[playerName][raceNum]["rank"] = (
					tempResults[playerName][raceId]["rank"]
				)

func loadPlayers() -> void:
	var playerData: Dictionary
	var avatar: Image
	var mapVeto: MapResource
	loadPreviousData()
	if not FileAccess.file_exists("user://players.json"):
		return
	var file = FileAccess.open("user://players.json", FileAccess.READ)
	var test_json_conv = JSON.new()
	test_json_conv.parse(file.get_as_text())
	playerData = test_json_conv.get_data()
	for id in playerData:
		avatar = Image.new()
		avatar.load("user://" + id + ".png")
		mapVeto = _maps[playerData[id]["mapVeto"]]
		_players[id] = PlayerResource.new(
			playerData[id]["name"],
			avatar,
			mapVeto,
			playerData[id]["races"],
			playerData[id]["previousRecord"]
		)
		_players[id].setVirtualPoints(playerData[id]["virtualPoints"])

func processPreviousRecordData(data: Dictionary) -> Dictionary:
	var processedData: Dictionary = {}
	for outerKey in data:
		processedData[int(outerKey)] = {}
		for innerKey in data[outerKey]:
			processedData[int(outerKey)][int(innerKey)] = data[outerKey][innerKey]
	return processedData

func saveTournament() -> void:
	var tourneyData: Dictionary = {}
	for levelIndex in range(len(Tournament.rounds)):
		var levelArray: Array = Tournament.rounds[levelIndex]
		var levelData: Dictionary = {}
		for roundIndex in range(len(levelArray)):
			levelData[roundIndex] = levelArray[roundIndex].toDict()
		tourneyData[levelIndex] = levelData
	var fileSave = FileAccess.open("user://tournament.json", FileAccess.WRITE)
	fileSave.store_line(JSON.stringify(tourneyData))
	fileSave.close()

func loadTournament() -> void:
	var tourneyData: Dictionary
	if not FileAccess.file_exists("user://tournament.json"):
		return
	var file = FileAccess.open("user://tournament.json", FileAccess.READ)
	var test_json_conv = JSON.new()
	test_json_conv.parse(file.get_as_text())
	tourneyData = test_json_conv.get_data()
	for levelDict in tourneyData.values():
		var levelRounds: Array = []
		for roundDict in levelDict.values():
			var newRound: RoundResource
			match roundDict["type"]:
				"dual":
					newRound = processDualTourney(roundDict)
				"elimination":
					newRound = processElimination(roundDict)
				"group":
					newRound = processGroup(roundDict)
				"seed":
					newRound = processSeedRound(roundDict)
				"swiss":
					newRound = processSwissRound(roundDict)
				"forward":
					newRound = processForwardRound(roundDict)
			processMapPool(newRound, roundDict["mapPool"])
			newRound.virtualInputMult = roundDict["virtualInputMult"]
			var playerList: Array = processPlayers(roundDict["players"])
			var matchList: Array = processMatches(roundDict["matches"])
			newRound.loadPlayersMatches(playerList, matchList)
			levelRounds.append(newRound)
		Tournament.rounds.append(levelRounds)

func processMapPool(roundRes: RoundResource, mapDict: Dictionary) -> void:
	for mapId in mapDict.values():
		roundRes.addMap(_maps[mapId])

func processPlayers(playerDict: Dictionary) -> Array:
	var playerList: Array = []
	for playerId in playerDict.values():
		if playerId == "":
			playerList.append(null)
			continue
		playerList.append(_players[playerId])
	return playerList

func processMatches(matchDict: Dictionary) -> Array:
	var matchList: Array = []
	for matchData in matchDict.values():
		var playerOne: PlayerResource = _players[matchData["playerOne"]]
		var playerTwo: PlayerResource
		if matchData["playerTwo"] == "":
			playerTwo = null
		else:
			playerTwo = _players[matchData["playerTwo"]]
		var mapList: Array
		for mapId in matchData["mapPool"].values():
			mapList.append(_maps[mapId])
		var matchRes: MatchResource = MatchResource.new(playerOne, playerTwo, mapList)
		for matchResult in matchData["results"].values():
			if matchResult == "1":
				matchRes.addWin(playerOne)
			elif matchResult == "2":
				matchRes.addWin(playerTwo)
			else:
				assert(false, "Unreachable")
		matchList.append(matchRes)
	return matchList

func processForwardRound(roundData: Dictionary) -> ForwardRound:
	var roundRes: ForwardRound
	roundRes = ForwardRound.new()
	roundRes.input = int(roundData["input"])
	return roundRes

func processSwissRound(roundData: Dictionary) -> SwissRound:
	var roundRes: SwissRound
	roundRes = SwissRound.new()
	roundRes.input = int(roundData["input"])
	roundRes.neededWins = int(roundData["neededWins"])
	return roundRes

func processSeedRound(roundData: Dictionary) -> SeedRound:
	var roundRes: SeedRound
	roundRes = SeedRound.new()
	return roundRes

func processGroup(roundData: Dictionary) -> GroupRound:
	var roundRes: GroupRound
	roundRes = GroupRound.new()
	roundRes.groupNum = int(roundData["groupNum"])
	roundRes.groupSize = int(roundData["groupSize"])
	roundRes.neededWins = int(roundData["neededWins"])
	return roundRes

func processElimination(roundData: Dictionary) -> EliminationRound:
	var roundRes: EliminationRound
	roundRes = EliminationRound.new()
	roundRes.pairNum = int(roundData["pairNum"])
	roundRes.neededWins = int(roundData["neededWins"])
	return roundRes

func processDualTourney(roundData: Dictionary) -> DualTourneyRound:
	var roundRes: DualTourneyRound
	var neededWins: Array = [0, 0, 0]
	roundRes = DualTourneyRound.new()
	roundRes.groupNum = int(roundData["groupNum"])
	neededWins[0] = int(roundData["neededWins"]["0"])
	neededWins[1] = int(roundData["neededWins"]["1"])
	neededWins[2] = int(roundData["neededWins"]["2"])
	roundRes.neededWins = neededWins
	return roundRes
