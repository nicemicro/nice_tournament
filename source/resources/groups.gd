extends RoundResource
class_name GroupRound

var groupNum: int = 2 setget setGroupNum, getGroupNum
var groupSize: int = 3 setget setGroupSize, getGroupSize
var neededWins: int = 2 setget setNeededWins, getNeededWins

func _init() -> void:
	virtualInputMult = 0

func getOutput() -> int:
	return groupNum * groupSize

func setOutput(newOutput: int) -> void:
	fail(newOutput)

func getInput() -> int:
	return groupNum * groupSize

func setInput(newInput: int) -> void:
	fail(newInput)

func setGroupNum(newNum: int) -> void:
	if newNum < 1:
		return
	groupNum = newNum

func getGroupNum() -> int:
	return groupNum

func setGroupSize(newNum: int) -> void:
	if newNum < 3:
		return
	groupSize = newNum

func getGroupSize() -> int:
	return groupSize

func setNeededWins(newNum: int) -> void:
	if newNum < 1:
		return
	neededWins = newNum

func getNeededWins() -> int:
	return neededWins

func toDict() -> Dictionary:
	var returnDict: Dictionary = {}
	returnDict = _toDict(returnDict)
	returnDict["groupNum"] = groupNum
	returnDict["groupSize"] = groupSize
	returnDict["neededWins"] = neededWins
	return returnDict
