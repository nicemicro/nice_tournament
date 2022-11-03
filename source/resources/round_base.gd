extends Resource
class_name RoundResource

var input: int = 0
var output: int = 0 setget setOutput, getOutput
var virtualInputMult: float = 0.0
var mapPool: Array = []

func getOutput() -> int:
	return output

func setOutput(newOutput: int) -> void:
	output = newOutput
