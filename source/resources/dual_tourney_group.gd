extends RoundResource
class_name DualTourneyRound

var groupNum: int = 2 setget setGroupNum, getGroupNum
var neededWins: Array = [1, 2, 2] setget setWins, getWins

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

func setWins(newWins: Array) -> void:
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

func getWins() -> Array:
	return neededWins.duplicate()
