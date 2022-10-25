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

var players: Dictionary setget fail, getPlayers
var maps: Dictionary setget fail, getMaps

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

func getMaps() -> Dictionary:
	return maps.duplicate()

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
			icon
		)

func saveTournament() -> void:
	pass

func loadTournament() -> void:
	pass
