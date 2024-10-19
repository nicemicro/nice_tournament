extends RoundResource
class_name EliminationRound

var pairNum: int = 2: get = getPairNum, set = setPairNum
var neededWins: int = 3: get = getNeededWins, set = setNeededWins
var inputType: int = 0: get = getInputType, set = changeInputType
var inputOrder: int = 0: get = getInputOrder, set = changeInputOrder

func _init() -> void:
	_type = "elimination"
	virtualInputMult = 0

func getOutput() -> int:
	return pairNum * 2

func setOutput(newOutput: int) -> void:
	fail(newOutput)

func getInput() -> int:
	return pairNum * 2

func setInput(newInput: int) -> void:
	fail(newInput)

func setPairNum(newNum: int) -> void:
	if newNum < 1:
		return
	pairNum = newNum

func getPairNum() -> int:
	return pairNum

func setNeededWins(newNum: int) -> void:
	if newNum < 1:
		return
	neededWins = newNum

func getNeededWins() -> int:
	return neededWins

func getInputType() -> int:
	return inputType

func changeInputType(newType: int) -> void:
	if newType >= 0 and newType <= 2:
		inputType = newType

func getInputOrder() -> int:
	return inputOrder

func changeInputOrder(newOrder: int) -> void:
	if newOrder >= 0 and newOrder <= 1:
		inputOrder = newOrder

func _receivePlayers(incoming: Array) -> Array:
	var outgoing: Array  = super._receivePlayers(incoming)
	var playerOriginal: Array = _players.duplicate()
	#TODO: deal with the possiblity of having odd number of players
	_players = []
	if len(playerOriginal) % 2 == 1 and inputType == 0:
		_players.append(playerOriginal.pop_front())
	while len(playerOriginal) >= 2:
		if inputType == 0:
			_players.append(playerOriginal.pop_front())
			_players.append(playerOriginal.pop_back())
		elif inputType == 1:
			_players.append(playerOriginal.pop_front())
			_players.append(playerOriginal.pop_front())
		elif inputType == 2:
			_players.append(playerOriginal.pop_front())
			_players.append(playerOriginal.pop_at(
				int(len(playerOriginal) / 2)
			))
	if len(playerOriginal) % 2 == 1 and inputType > 0:
		# In case of a stacked or straight system, the last player is alone.
		_players.append(playerOriginal.pop_back())
	return outgoing

func _generateGroupings() -> void:
	var playersCopy: Array = _players.duplicate()
	if len(_players) % 2 == 1 and inputType == 0:
		_groupings.append([playersCopy.pop_front()])
	while len(playersCopy) >= 2:
		if inputOrder == 0:
			_groupings.append([
				playersCopy.pop_front(),
				playersCopy.pop_front(),
			])
		else:
			_groupings.push_front([
				playersCopy.pop_front(),
				playersCopy.pop_front(),
			])
	if len(_players) % 2 == 1 and inputType > 0:
		if inputOrder == 0:
			_groupings.append([playersCopy.pop_front()])
		else:
			_groupings.push_front([playersCopy.pop_front()])

func _generateMaplist(playerList: Array) -> Array:
	var mapVetoList: Array = []
	for playerRes in playerList:
		mapVetoList.append(playerRes.mapVeto)
	var maplist: Array = _generateMaplistCore(
		mapVetoList, neededWins * 2 - 1
	)
	return maplist

func isOver() -> bool:
	if len(matchList) == 0:
		return false
	for matchRes in matchList:
		if not matchRes.isOver():
			return false
	return true

func _getProvisinalOutPlayerList() -> Array:
	var provisionalList: Array = []
	var name: String = Tournament.getRoundName(self)
	for groupIndex in range(len(_groupings)):
		provisionalList.append(name + "/" + str(groupIndex + 1) + " W")
	for groupIndex in range(len(_groupings)):
		provisionalList.append(name + "/" + str(groupIndex + 1) + " L")
	return provisionalList

func _getOutPlayerList() -> Array:
	var outPlayerList: Array = []
	var name: String = Tournament.getRoundName(self)
	for matchRes in matchList:
		if matchRes.isOver():
			outPlayerList.append(matchRes.getWinner())
		else:
			outPlayerList.append(
				name + "/" + str(matchList.find(matchRes) + 1) + " W"
			)
	for matchRes in matchList:
		if not matchRes.isOver():
			outPlayerList.append(
				name + "/" + str(matchList.find(matchRes) + 1) + " L"
			)
		elif (
			matchRes.playerOne in outPlayerList and
			matchRes.playerTwo != null
		):
			outPlayerList.append(matchRes.playerTwo)
		elif matchRes.playerTwo in outPlayerList:
			outPlayerList.append(matchRes.playerOne)
		else:
			assert(matchRes.playerTwo == null, "Unreachable!")
	return outPlayerList

func _generateLoadedGroupings() -> void:
	#var playersCopy: Array = _players.duplicate()
	for matchRes in matchList:
		if matchRes.playerTwo == null:
			_groupings.append([matchRes.playerOne])
			continue
		_groupings.append([matchRes.playerOne, matchRes.playerTwo])

func toDict() -> Dictionary:
	var returnDict: Dictionary = {}
	returnDict = _toDict(returnDict)
	returnDict["pairNum"] = pairNum
	returnDict["neededWins"] = neededWins
	returnDict["inputType"] = inputType
	returnDict["inputOrder"] = inputOrder
	return returnDict
