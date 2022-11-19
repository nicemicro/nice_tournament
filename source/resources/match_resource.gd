extends Resource
class_name MatchResource

var playerOne: PlayerResource setget fail, getPlayerOne
var playerTwo: PlayerResource setget fail, getPlayerTwo
var mapPool: Array = [] setget fail, getMapPool
var results: Array = [] setget fail, getResults

signal newWinRegistered

func fail(input) -> void:
	assert (false, "You should not change this on the fly")

func _init(newPlayerOne: PlayerResource, newPlayerTwo: PlayerResource, newMaps: Array) -> void:
	for element in newMaps:
		if not element is MapResource:
			printerr("All elements of the array should be maps.")
			assert(false)
			return
	playerOne = newPlayerOne
	playerTwo = newPlayerTwo
	mapPool = newMaps.duplicate()
	results = []

func getWins() -> Dictionary:
	var winDict: Dictionary = {}
	var countOne: int = 0
	var countTwo: int = 0
	for result in results:
		if result == playerOne:
			countOne += 1
		elif result == playerTwo:
			countTwo += 1
		else:
			assert(false, "Unreachable")
	winDict[playerOne] = countOne
	winDict[playerTwo] = countTwo
	return winDict

func getLoss() -> Dictionary:
	var lossDict: Dictionary = {}
	var winDict: Dictionary = getWins()
	lossDict[playerOne] = winDict[playerTwo]
	lossDict[playerTwo] = winDict[playerOne]
	return lossDict

func getWinner() -> PlayerResource:
	var neededWin: int = (len(mapPool) + 1) / 2
	var winDict: Dictionary = getWins()
	if winDict[playerOne] >= neededWin:
		return playerOne
	if winDict[playerTwo] >= neededWin:
		return playerTwo
	return null

func isOver() -> bool:
	return not (getWinner() == null)

func getNextMap() -> MapResource:
	if len(results) == len(mapPool):
		return null
	return mapPool[len(results)]

func addWin(winner: PlayerResource) -> void:
	if not winner in [playerOne, playerTwo]:
		printerr("Unrelated player trying to be added to a match.")
		assert(false)
		return
	results.append(winner)
	emit_signal("newWinRegistered", self)

func getPlayerOne() -> PlayerResource:
	return playerOne

func getPlayerTwo() -> PlayerResource:
	return playerTwo

func getMapPool() -> Array:
	return mapPool.duplicate()

func getResults() -> Array:
	return results.duplicate()

func toDict() -> Dictionary:
	var matchDict: Dictionary = {}
	var mapPoolDict: Dictionary = {}
	var resultDict: Dictionary = {}
	for mapIndex in range(len(mapPool)):
		var map: MapResource = mapPool[mapIndex]
		mapPoolDict[mapIndex] = Global.getMapId(map)
	for resultIndex in range(len(results)):
		if results[resultIndex] == playerOne:
			resultDict[resultIndex] = "1"
		elif results[resultIndex] == playerTwo:
			resultDict[resultIndex] = "2"
		else:
			assert(false, "Unreachable!")
	matchDict["playerOne"] = Global.getPlayerId(playerOne)
	matchDict["playerTwo"] = Global.getPlayerId(playerTwo)
	matchDict["mapPool"] = mapPoolDict
	matchDict["results"] = resultDict
	return matchDict
