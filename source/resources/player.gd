extends Resource
class_name PlayerResource

var name: String: get = getName, set = fail
var _name: String
var avatar: Image: get = getAvatar, set = fail
var _avatar: Image
var races: Dictionary: get = getAllRaces, set = fail
var _races: Dictionary
var previousRecord: Dictionary: get = getRecord, set = fail
var _previousRecord: Dictionary
var mapVeto: MapResource: get = getVetodMaps, set = fail
var _mapVeto: MapResource
var virtualPoints: int = 0: get = getVirtualPoints, set = setVirtualPoints

func _init(
	newName: String, newAvatar: Image, newVeto: MapResource, newRace: Dictionary, newRecord: Dictionary
) -> void:
	_name = newName
	_avatar = newAvatar
	_mapVeto = newVeto
	_races = {}
	for index in newRace:
		_races[int(index)] = int(newRace[index])
	_previousRecord = {}
	for index in newRecord:
		var raceRecord: Dictionary = {"win": 0, "loss": 0}
		raceRecord["win"] = int(newRecord[index]["win"])
		raceRecord["loss"] = int(newRecord[index]["loss"])
		_previousRecord[int(index)] = raceRecord

func fail(_input) -> void:
	assert (false, "You should not change this on the fly")

func getName() -> String:
	return _name

func getAvatar() -> Image:
	return _avatar

func getAllRaces() -> Dictionary:
	return _races.duplicate()

func getReprRace() -> int:
	var counter: Dictionary = {}
	for race in Global.Race.values():
		counter[race] = 0
	for versus in _races:
		counter[_races[versus]] += 1
	for played in counter:
		if counter[played] == 4:
			return played
		if counter[played] == 3:
			return int(Global.Race.RANDOM)
	return int(Global.Race.RANDOM)

func getPlayedRaceVs(otherReprRace: int) -> int:
	return _races[otherReprRace]

func getRaceName() -> String:
	var counter: Dictionary = {}
	for race in Global.Race.values():
		counter[race] = 0
	for versus in _races:
		counter[_races[versus]] += 1
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
	return _previousRecord.duplicate()

func recordVs(race: int, win: bool) -> int:
	if win:
		return _previousRecord[race]["win"]
	return _previousRecord[race]["loss"]

func getPoints(untilRound: int) -> int:
	return Tournament.getPoints(self, untilRound)

func getGameNumber(untilRound: int) -> int:
	return Tournament.getGameNumber(self, untilRound)

func getOpponentPointSum(untilRound: int) -> int:
	return Tournament.getOpponentPointSum(self, untilRound)

func getVetodMaps() -> MapResource:
	return _mapVeto

func toDict() -> Dictionary:
	var returnDict: Dictionary = {}
	returnDict["name"] = _name
	returnDict["races"] = _races
	returnDict["previousRecord"] = _previousRecord
	returnDict["mapVeto"] = Global.maps.keys()[Global.maps.values().find(_mapVeto)]
	returnDict["virtualPoints"] = virtualPoints
	return returnDict
