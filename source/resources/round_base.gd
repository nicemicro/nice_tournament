extends Resource
class_name RoundResource

var input: int = 0 setget setInput, getInput
var output: int = 0 setget setOutput, getOutput
var virtualInputMult: float = 0.0
var mapPool: Array = [] setget fail, getMapPool

func fail(input) -> void:
	assert (false, "You should not change this on the fly")

func getOutput() -> int:
	return output

func setOutput(newOutput: int) -> void:
	output = newOutput

func getInput() -> int:
	return input

func setInput(newInput: int) -> void:
	input = newInput

func getMapPool() -> Array:
	return mapPool.duplicate()

func addMap(newMap: MapResource) -> void:
	if newMap in mapPool:
		printerr("Trying to add a map already on the list")
		return
	mapPool.append(newMap)

func removeMap(mapRes: MapResource) -> void:
	if not mapRes in mapPool:
		printerr("Trying to act on a map not on the list")
		return
	var index: int = mapPool.find(mapRes)
	mapPool.pop_at(index)

func moveMap(mapRes: MapResource, position: int) -> void:
	if position < 0 or position >= len(mapPool):
		printerr("Trying to move a map to an unavailable position")
		return
	if not mapRes in mapPool:
		printerr("Trying to act on a map not on the list")
		return
	var index: int = mapPool.find(mapRes)
	mapPool[index] = mapPool[position]
	mapPool[position] = mapRes

func _toDict(data: Dictionary) -> Dictionary:
	var mapPoolDict: Dictionary = {}
	for mapIndex in range(len(mapPool)):
		var map: MapResource = mapPool[mapIndex]
		mapPoolDict[mapIndex] = Global.maps.keys()[Global.maps.values().find(map)]
	data["input"] = input
	data["output"] = output
	data["virtualInputMult"] = virtualInputMult
	data["mapPool"] = mapPoolDict
	return data

func toDict() -> Dictionary:
	var returnDict: Dictionary = {}
	returnDict = _toDict(returnDict)
	return returnDict
