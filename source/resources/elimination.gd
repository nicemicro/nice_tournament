extends RoundResource
class_name EliminationRound

var pairNum: int = 2 setget setPairNum, getPairNum
var neededWins: int = 3 setget setNeededWins, getNeededWins

func _init() -> void:
	virtualInputMult = 0

func getOutput() -> int:
	return pairNum * 2

func setOutput(newOutput: int) -> void:
	fail(newOutput)

func getInput() -> int:
	return pairNum * 2

func setInput(newInput: int) -> void:
	fail(newInput)

func setPairNum(newNum: int) -> void:
	if newNum < 1:
		return
	pairNum = newNum

func getPairNum() -> int:
	return pairNum

func setNeededWins(newNum: int) -> void:
	if newNum < 1:
		return
	neededWins = newNum

func getNeededWins() -> int:
	return neededWins

func toDict() -> Dictionary:
	var returnDict: Dictionary = {}
	returnDict["type"] = "elimination"
	returnDict = _toDict(returnDict)
	returnDict["pairNum"] = pairNum
	returnDict["neededWins"] = neededWins
	return returnDict
