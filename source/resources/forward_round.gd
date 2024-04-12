extends RoundResource
class_name ForwardRound

func _init() -> void:
	_type = "forward"

func getOutput() -> int:
	return input

func setOutput(newOutput: int) -> void:
	fail(newOutput)

func _validMapPool() -> bool:
	return true

func _generateGroupings() -> void:
	for player in _players:
		_groupings.append([player])

func _generateMatches() -> void:
	return

func isOver() -> bool:
	return isStarted()

func toDict() -> Dictionary:
	var returnDict: Dictionary = {}
	returnDict = _toDict(returnDict)
	return returnDict
