extends RoundResource
class_name EndResultRound

class _customSorter:
	static func sortByPointsDesc(a, b):
		if a["points"] > b["points"]:
			return true
		if a["points"] < b["points"]:
			return false
		if not "opponentPoints" in a or not "opponentPoints" in b:
			return false
		return (a["opponentPoints"] > b["opponentPoints"])

func _validMapPool() -> bool:
	return true

func _sortPlayersByPoint(playerList: Array) -> Array:
	if len(playerList) == 0:
		return []
	var playerCopy: Array = []
	var orderedPlayerList: Array = []
	for playerRes in playerList:
		if not playerRes is PlayerResource:
			assert(playerRes is String)
			orderedPlayerList.append(playerRes)
			continue
		orderedPlayerList.append(null)
		var playerDict: Dictionary = {}
		playerDict["player"] = playerRes
		playerDict["points"] = (
			float(playerRes.getPoints(-1)) / playerRes.getGameNumber(-1)
		)
		playerDict["opponentPoints"] = (
			playerRes.getOpponentPointSum(-1)
		)
		playerCopy.append(playerDict)
	playerCopy.sort_custom(Callable(_customSorter, "sortByPointsDesc"))
	var index: int = 0
	for playerDict in playerCopy:
		while orderedPlayerList[index] != null:
			index += 1
		orderedPlayerList[index] = playerDict["player"]
	return orderedPlayerList

func receivePlayers(incomingPlayers: Array, playerGroup: Dictionary = {}) -> Array:
	assert(len(playerGroup.keys()) >= len(incomingPlayers), "Grouping should contain everything in incoming")
	var groupPlayer: Dictionary
	for player in incomingPlayers:
		assert(player is PlayerResource or player is String)
		var group: RoundResource = playerGroup[player]
		if not group in groupPlayer.keys():
			groupPlayer[group] = []
		groupPlayer[group].append(player)
	var orderedPlayers: Array = []
	for group in groupPlayer.values():
		if len(group) > 2:
			group = _sortPlayersByPoint(group)
		orderedPlayers += group
	_players = orderedPlayers + _players
#	print("  > ", incoming)
#	print("    >> ", _players)
	return []

func getFinalOrder() -> Array:
	return _players
