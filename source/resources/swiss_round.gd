extends RoundResource
class_name SwissRound

var neededWins: int = 2 setget setWins, getWins

func _init() -> void:
	virtualInputMult = 0

func getOutput() -> int:
	return input

func setOutput(newOutput: int) -> void:
	fail(newOutput)

func setWins(newNum: int) -> void:
	if newNum < 1:
		return
	neededWins = newNum

func getWins() -> int:
	return neededWins

func toDict() -> Dictionary:
	var returnDict: Dictionary = {}
	returnDict["type"] = "swiss"
	returnDict = _toDict(returnDict)
	returnDict["neededWins"] = neededWins
	return returnDict
