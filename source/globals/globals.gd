extends Node

enum  Race {
	PROTOSS
	ZERG
	TERRAN
	RANDOM
}

const RaceName: Dictionary = {
	Race.PROTOSS: "Protoss",
	Race.ZERG: "Zerg",
	Race.TERRAN: "Terran",
	Race.RANDOM: "Random"
}

var players: Dictionary = {} setget fail, getPlayers
var maps: Dictionary = {} setget fail, getMaps

func fail(input) -> void:
	assert (false, "You should not change this on the fly")

func registerNewPlayer(newPlayer: PlayerResource) -> void:
	var time = Time.get_time_dict_from_system(true)
	var time_return: int = time.hour * 10000 + time.minute * 100 + time.second
	var newId: String
	newId = "%x" % (time_return * 10000 + (randi() % 10000))
	players[newId] = newPlayer

func registerNewMap(newMap: MapResource) -> void:
	var time = Time.get_time_dict_from_system(true)
	var time_return: int = time.hour * 10000 + time.minute * 100 + time.second
	var newId: String
	newId = "%x" % (time_return * 10000 + (randi() % 10000))
	maps[newId] = newMap
	
func getPlayers() -> Dictionary:
	return players.duplicate()

func getPlayerId(playerRes: PlayerResource) -> String:
	return players.keys()[players.values().find(playerRes)]

func getMapId(mapRes: MapResource) -> String:
	return maps.keys()[maps.values().find(mapRes)]

func getMaps() -> Dictionary:
	return maps.duplicate()

func saveMaps() -> void:
	var mapData: Dictionary = {}
	for mapId in maps:
		mapData[mapId] = maps[mapId].toDict()
		maps[mapId].icon.save_png("user://" + mapId + ".png")
	var fileSave = File.new()
	fileSave.open("user://maps.json", File.WRITE)
	fileSave.store_line(to_json(mapData))
	fileSave.close()

func loadMaps() -> void:
	var file = File.new()
	var mapData: Dictionary
	var icon: Image
	if not file.file_exists("user://maps.json"):
		return
	file.open("user://maps.json", File.READ)
	mapData = parse_json(file.get_as_text())
	for id in mapData:
		icon = Image.new()
		icon.load("user://" + id + ".png")
		maps[id] = MapResource.new(
			mapData[id]["name"],
			icon,
			processPreviousRecordData(mapData[id]["previousRecord"])
		)

func savePlayers() -> void:
	var playerData: Dictionary = {}
	for playerId in players:
		playerData[playerId] = players[playerId].toDict()
		players[playerId].avatar.save_png("user://" + playerId + ".png")
	var fileSave = File.new()
	fileSave.open("user://players.json", File.WRITE)
	fileSave.store_line(to_json(playerData))
	fileSave.close()

func loadPlayers() -> void:
	var file = File.new()
	var playerData: Dictionary
	var avatar: Image
	var mapVeto: MapResource
	if not file.file_exists("user://players.json"):
		return
	file.open("user://players.json", File.READ)
	playerData = parse_json(file.get_as_text())
	for id in playerData:
		avatar = Image.new()
		avatar.load("user://" + id + ".png")
		mapVeto = maps[playerData[id]["mapVeto"]]
		players[id] = PlayerResource.new(
			playerData[id]["name"],
			avatar,
			mapVeto,
			playerData[id]["races"],
			playerData[id]["previousRecord"]
		)
		players[id].setVirtualPoints(playerData[id]["virtualPoints"])

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
	var fileSave = File.new()
	fileSave.open("user://tournament.json", File.WRITE)
	fileSave.store_line(to_json(tourneyData))
	fileSave.close()

func loadTournament() -> void:
	var file = File.new()
	var tourneyData: Dictionary
	if not file.file_exists("user://tournament.json"):
		return
	file.open("user://tournament.json", File.READ)
	tourneyData = parse_json(file.get_as_text())
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
			processMapPool(newRound, roundDict["mapPool"])
			newRound.virtualInputMult = roundDict["virtualInputMult"]
			var playerList: Array = processPlayers(roundDict["players"])
			var matchList: Array = processMatches(roundDict["matches"])
			newRound.loadPlayersMatches(playerList, matchList)
			levelRounds.append(newRound)
		Tournament.rounds.append(levelRounds)

func processMapPool(roundRes: RoundResource, mapDict: Dictionary) -> void:
	for mapId in mapDict.values():
		roundRes.addMap(maps[mapId])

func processPlayers(playerDict: Dictionary) -> Array:
	var playerList: Array = []
	for playerId in playerDict.values():
		playerList.append(players[playerId])
	return playerList

func processMatches(matchDict: Dictionary) -> Array:
	var matchList: Array = []
	for matchData in matchDict.values():
		var playerOne: PlayerResource = players[matchData["playerOne"]]
		var playerTwo: PlayerResource = players[matchData["playerTwo"]]
		var mapList: Array
		for mapId in matchData["mapPool"].values():
			mapList.append(maps[mapId])
		var matchRes: MatchResource = MatchResource.new(playerOne, playerTwo, mapList)
		for matchResult in matchData["results"].values():
			if matchResult == "1":
				matchRes.addWin(playerOne)
			elif matchResult == "2":
				matchRes.addWin(playerTwo)
			else:
				assert(false, "Unreachable")
	return matchList

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
