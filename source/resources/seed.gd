extends RoundResource
class_name SeedRound

func _init() -> void:
	virtualInputMult = 1
	_type = "seed"

func addPlayer(newPlayer: PlayerResource) -> void:
	if newPlayer in _players:
		printerr("Trying to add a player already on the list")
	else:
		_players.append(newPlayer)
	output = len(_players)

func removePlayer(player: PlayerResource) -> void:
	if not hasPlayer(player):
		printerr("Trying to act on a player not on the list")
		return
	var index: int = _players.find(player)
	_players.pop_at(index)

func movePlayer(player: PlayerResource, position: int) -> void:
	if position < 0 or position >= len(_players):
		printerr("Trying to move a player to an unavailable position")
		return
	if not hasPlayer(player):
		printerr("Trying to act on a player not on the list")
		return
	var index: int = _players.find(player)
	_players[index] = _players[position]
	_players[position] = player

func hasPlayer(player: PlayerResource) -> bool:
	return player in _players

func getOutput() -> int:
	return len(_players)

func setOutput(newOutput: int) -> void:
	fail(newOutput)

func receivePlayers(incoming: Array) -> Array:
	return incoming

func isOver() -> bool:
	return true

func isStarted() -> bool:
	return true

func getOutPlayerList() -> Array:
	var outPlayers: Array = []
	var maxVirualPoint: int = 0
	for playerRes in _players:
		maxVirualPoint = max(maxVirualPoint, playerRes.virtualPoints)
	for point in range(maxVirualPoint, -1, -1):
		for playerRes in _players:
			if playerRes.virtualPoints == point:
				outPlayers.append(playerRes)
	return outPlayers

func getSeededPlayers() -> Array:
	return _players.duplicate()

func toDict() -> Dictionary:
	var returnDict: Dictionary = {}
	returnDict = _toDict(returnDict)
	return returnDict
