extends RoundResource
class_name SwissRound

var neededWins: int = 2 setget setNeededWins, getNeededWins

func _init() -> void:
	virtualInputMult = 0
	input = 4

func getOutput() -> int:
	return input

func setOutput(newOutput: int) -> void:
	fail(newOutput)

func setNeededWins(newNum: int) -> void:
	if newNum < 1:
		return
	neededWins = newNum

func getNeededWins() -> int:
	return neededWins

func receivePlayers(incoming: Array) -> Array:
	if len(_players) > 0:
		printerr("Players already set.")
		return incoming.duplicate()
	var outgoing: Array = _receivePlayers(incoming)
	_orderPlayerArray()
	_generateGroupings()
	_generateMatches()
	return outgoing

func _orderPlayerArray() -> void:
	pass

func toDict() -> Dictionary:
	var returnDict: Dictionary = {}
	returnDict["type"] = "swiss"
	returnDict = _toDict(returnDict)
	returnDict["neededWins"] = neededWins
	return returnDict
