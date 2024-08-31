extends Resource
class_name MatchResource

var playerOne: PlayerResource: get = getPlayerOne, set = fail
var _playerOne: PlayerResource
var playerTwo: PlayerResource: get = getPlayerTwo, set = fail
var _playerTwo: PlayerResource
var mapPool: Array = []: get = getMapPool, set = fail
var _mapPool: Array = []
var results: Array = []: get = getResults, set = fail
var _results: Array = []

signal newWinRegistered

func fail(input) -> void:
	assert (false, "You should not change this on the fly")

func _init(newPlayerOne: PlayerResource, newPlayerTwo: PlayerResource, newMaps: Array) -> void:
	for element in newMaps:
		if not element is MapResource:
			printerr("All elements of the array should be maps.")
			assert(false)
			return
	_playerOne = newPlayerOne
	_playerTwo = newPlayerTwo
	_mapPool = newMaps.duplicate()
	_results = []

func getPlayedRounds() -> int:
	var count: int = 0
	for result in _results:
		count += 1
	return count

func getWins() -> Dictionary:
	if _playerTwo == null:
		return {_playerOne: (len(_mapPool) + 1) / 2}
	var winDict: Dictionary = {}
	var countOne: int = 0
	var countTwo: int = 0
	for result in _results:
		if result == _playerOne:
			countOne += 1
		elif result == _playerTwo:
			countTwo += 1
		else:
			assert(false, "Unreachable")
	winDict[_playerOne] = countOne
	winDict[_playerTwo] = countTwo
	return winDict

func getLoss() -> Dictionary:
	if _playerTwo == null:
		return {_playerOne: 0}
	var lossDict: Dictionary = {}
	var winDict: Dictionary = getWins()
	lossDict[_playerOne] = winDict[_playerTwo]
	lossDict[_playerTwo] = winDict[_playerOne]
	return lossDict

func getWinner() -> PlayerResource:
	if _playerTwo == null:
		return _playerOne
	var neededWin: int = (len(_mapPool) + 1) / 2
	var winDict: Dictionary = getWins()
	if winDict[_playerOne] >= neededWin:
		return _playerOne
	if winDict[_playerTwo] >= neededWin:
		return _playerTwo
	return null

func isOver() -> bool:
	return not (getWinner() == null)

func getNextMap() -> MapResource:
	if isOver():
		return null
	return _mapPool[len(_results)]

func addWin(winner: PlayerResource) -> void:
	if not winner in [_playerOne, _playerTwo]:
		printerr("Unrelated player trying to be added to a match.")
		assert(false)
		return
	_results.append(winner)
	emit_signal("newWinRegistered", self)

func getPlayerOne() -> PlayerResource:
	return _playerOne

func getPlayerTwo() -> PlayerResource:
	return _playerTwo

func getMapPool() -> Array:
	return _mapPool.duplicate()

func getResults() -> Array:
	return _results.duplicate()

func toDict() -> Dictionary:
	var matchDict: Dictionary = {}
	var mapPoolDict: Dictionary = {}
	var resultDict: Dictionary = {}
	for mapIndex in range(len(_mapPool)):
		var map: MapResource = _mapPool[mapIndex]
		mapPoolDict[mapIndex] = Global.getMapId(map)
	for resultIndex in range(len(_results)):
		if _results[resultIndex] == _playerOne:
			resultDict[resultIndex] = "1"
		elif _results[resultIndex] == _playerTwo:
			resultDict[resultIndex] = "2"
		else:
			assert(false, "Unreachable!")
	matchDict["playerOne"] = Global.getPlayerId(_playerOne)
	matchDict["playerTwo"] = Global.getPlayerId(playerTwo)
	matchDict["mapPool"] = mapPoolDict
	matchDict["results"] = resultDict
	return matchDict
