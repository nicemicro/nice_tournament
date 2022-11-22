extends RoundResource
class_name ForwardRound

func getOutput() -> int:
	return input

func setOutput(newOutput: int) -> void:
	fail(newOutput)

func isOver() -> bool:
	return isStarted()

func receivePlayers(incoming: Array) -> Array:
	if len(_players) > 0:
		printerr("Players already set.")
		assert(false)
		return incoming.duplicate()
	var outgoing: Array = _receivePlayers(incoming)
	return outgoing

func toDict() -> Dictionary:
	var returnDict: Dictionary = {}
	returnDict["type"] = "forward"
	returnDict = _toDict(returnDict)
	return returnDict
