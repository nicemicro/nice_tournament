extends Resource
class_name MapResource

var name: String: get = getName, set = fail
var _name: String
var icon: Image: get = getIcon, set = fail
var _icon: Image
var previousRecord: Dictionary = {}: get = getRecord, set = fail
var _previousRecord: Dictionary = {}

func _init(newName: String, newIcon: Image, newRecord: Dictionary):
	_name = newName
	_icon = newIcon
	_previousRecord = newRecord

func fail(_input) -> void:
	assert (false, "You should not change this on the fly")

func getName() -> String:
	return _name

func getIcon() -> Image:
	return _icon

func getRecord() -> Dictionary:
	return _previousRecord.duplicate()

func getFullRecord() -> Dictionary:
	var fullRecord: Dictionary
	var newRecord: Dictionary = Tournament.getMapRecord(self)
	for race in Global.Race.values():
		fullRecord[int(race)] = {}
		for vsRace in Global.Race.values():
			if race == vsRace:
				continue
			fullRecord[int(race)][int(vsRace)] = (
				newRecord[int(race)][int(vsRace)] +
				_previousRecord[int(race)][int(vsRace)]
			)
	return fullRecord

func toDict() -> Dictionary:
	var returnDict: Dictionary = {}
	returnDict["name"] = _name
	returnDict["previousRecord"] = _previousRecord
	return returnDict
