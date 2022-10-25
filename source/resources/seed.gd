extends RoundResource
class_name SeedRound

var seededPlayers: Array = [] setget fail, getSeededPlayers

func _init() -> void:
	virtualInputMult = 1

func fail(input) -> void:
	assert (false, "You should not change this on the fly")

func getSeededPlayers() -> Array:
	return seededPlayers.duplicate()

func addPlayer(newPlayer: PlayerResource) -> void:
	if newPlayer in seededPlayers:
		printerr("Trying to add a player already on the list")
	else:
		seededPlayers.append(newPlayer)
	output = len(seededPlayers)

func hasPlayer(player: PlayerResource) -> bool:
	return player in seededPlayers
