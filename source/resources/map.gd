extends Resource
class_name MapResource

var name: String: get = getName, set = fail
var icon: Image: get = getIcon, set = fail
var previousRecord: Dictionary = {}: get = getRecord, set = fail

func _init(newName: String, newIcon: Image, newRecord: Dictionary):
	name = newName
	icon = newIcon
	previousRecord = newRecord

func fail(input) -> void:
	assert (false, "You should not change this on the fly")

func getName() -> String:
	return name

func getIcon() -> Image:
	return icon

func getRecord() -> Dictionary:
	return previousRecord.duplicate()

func toDict() -> Dictionary:
	var returnDict: Dictionary = {}
	returnDict["name"] = name
	returnDict["previousRecord"] = previousRecord
	return returnDict
