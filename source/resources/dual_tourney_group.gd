extends RoundResource
class_name DualTourneyRound

var groupNum: int = 2: get = getGroupNum, set = setGroupNum
var neededWins: Array = [1, 2, 2]: get = getNeededWins, set = setNeededWins

func _init() -> void:
	virtualInputMult = 0

func getOutput() -> int:
	return groupNum * 4

func setOutput(newOutput: int) -> void:
	fail(newOutput)

func getInput() -> int:
	return groupNum * 4

func setInput(newInput: int) -> void:
	fail(newInput)

func setGroupNum(newNum: int) -> void:
	if newNum < 1:
		return
	groupNum = newNum

func getGroupNum() -> int:
	return groupNum

func setNeededWins(newWins: Array) -> void:
	if len(newWins) != 3:
		printerr("The required wins should be a 3 element array of ints")
		return
	for winNum in newWins:
		if not winNum is int:
			printerr("The required wins should be a 3 element array of ints")
			return
		if winNum < 1:
			printerr("The required wins has to be at least 1")
			return
	neededWins = newWins.duplicate()

func getNeededWins() -> Array:
	return neededWins.duplicate()

func toDict() -> Dictionary:
	var returnDict: Dictionary = {}
	returnDict = _toDict(returnDict)
	returnDict["groupNum"] = groupNum
	returnDict["neededWins"] = {}
	returnDict["neededWins"][0] = neededWins[0]
	returnDict["neededWins"][1] = neededWins[1]
	returnDict["neededWins"][2] = neededWins[2]
	return returnDict
