extends Resource
class_name MapResource

var name: String setget fail, getName
var icon: Image setget fail, getIcon

func _init(newName: String, newIcon: Image):
	name = newName
	icon = newIcon

func fail(input) -> void:
	assert (false, "You should not change this on the fly")

func getName() -> String:
	return name

func getIcon() -> Image:
	return icon

func toDict() -> Dictionary:
	var returnDict: Dictionary = {}
	returnDict["name"] = name
	return returnDict
