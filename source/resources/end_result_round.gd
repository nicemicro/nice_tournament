extends RoundResource
class_name EndResultRound

func _validMapPool() -> bool:
	return true

func receivePlayers(incoming: Array) -> Array:
	_players = incoming + _players
#	print("  > ", incoming)
#	print("    >> ", _players)
	return []

func getFinalOrder() -> Array:
	return _players
