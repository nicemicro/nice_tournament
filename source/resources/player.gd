extends Resource
class_name PlayerResource

var name: String setget fail, getName
var avatar: Image setget fail, getAvatar
var races: Dictionary setget fail, getAllRaces
var previousRecord: Dictionary setget fail, getRecord
var mapVeto: MapResource setget fail, getVetodMaps
var virtualPoints: int = 0 setget setVirtualPoints, getVirtualPoints

func _init(
	newName: String, newAvatar: Image, newVeto: MapResource, newRace: Dictionary, newRecord: Dictionary
) -> void:
	name = newName
	avatar = newAvatar
	races = {}
	for index in newRace:
		races[int(index)] = int(newRace[index])
	previousRecord = {}
	for index in newRecord:
		var raceRecord: Dictionary = {"win": 0, "loss": 0}
		raceRecord["win"] = int(newRecord[index]["win"])
		raceRecord["loss"] = int(newRecord[index]["loss"])
		previousRecord[int(index)] = raceRecord

func fail(input) -> void:
	assert (false, "You should not change this on the fly")

func getName() -> String:
	return name

func getAvatar() -> Image:
	return avatar

func getAllRaces() -> Dictionary:
	return races.duplicate()

func getRaceName() -> String:
	var counter: Dictionary = {}
	for race in Global.Race.values():
		counter[race] = 0
	for versus in races:
		counter[races[versus]] += 1
	for played in counter:
		if counter[played] == 4:
			return Global.RaceName[played]
		if counter[played] == 3:
			return "Racepicker (" + Global.RaceName[played] + ")"
	return "Racepicker"

func setVirtualPoints(point: int) -> void:
	virtualPoints = point

func getVirtualPoints() -> int:
	return virtualPoints

func getRecord() -> Dictionary:
	return previousRecord.duplicate()

func getVetodMaps() -> MapResource:
	return mapVeto

func toDict() -> Dictionary:
	var returnDict: Dictionary = {}
	returnDict["name"] = name
	returnDict["races"] = races
	returnDict["previousRecord"] = previousRecord
	returnDict["mapVeto"] = Global.maps.keys()[Global.maps.values().find(mapVeto)]
	returnDict["virtualPoints"] = virtualPoints
	return returnDict
