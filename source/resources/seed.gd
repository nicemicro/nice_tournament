extends RoundResource
class_name SeedRound

var seededPlayers: Array = [] setget setSeededPlayers, getSeededPlayers

func _init() -> void:
	virtualInputMult = 1

func getSeededPlayers() -> Array:
	return seededPlayers.duplicate()
 
func setSeededPlayers(input) -> void:
	fail(input)

func addPlayer(newPlayer: PlayerResource) -> void:
	if newPlayer in seededPlayers:
		printerr("Trying to add a player already on the list")
	else:
		seededPlayers.append(newPlayer)
	output = len(seededPlayers)

func removePlayer(player: PlayerResource) -> void:
	if not hasPlayer(player):
		printerr("Trying to act on a player not on the list")
		return
	var index: int = seededPlayers.find(player)
	seededPlayers.pop_at(index)

func movePlayer(player: PlayerResource, position: int) -> void:
	if position < 0 or position >= len(seededPlayers):
		printerr("Trying to move a player to an unavailable position")
		return
	if not hasPlayer(player):
		printerr("Trying to act on a player not on the list")
		return
	var index: int = seededPlayers.find(player)
	seededPlayers[index] = seededPlayers[position]
	seededPlayers[position] = player

func hasPlayer(player: PlayerResource) -> bool:
	return player in seededPlayers

func getOutput() -> int:
	return len(seededPlayers)

func setOutput(newOutput: int) -> void:
	fail(newOutput)
