extends VBoxContainer

@onready var playerOneContainer: MarginContainer = $Container/PlayerOne
@onready var playerTwoContainer: MarginContainer = $Container/PlayerTwo
@onready var mapPoolContainer: VBoxContainer = $Container/Middle/MapPool
@onready var currentMapName: Label = $Container/Middle/MapName
@onready var currentMapImage: TextureRect = $Container/Middle/MapImage
@onready var currentMapVs: Label = $Container/Middle/VsData

var matchRes: MatchResource
var matchControlNodes: Array = []
var playerNodes: Array = []

const playerBoxScenePath: String = "res://subscenes/broadcast/full_screen_round/player_container_big.tscn"
const mapGameControlPath: String = "res://subscenes/broadcast/full_screen_round/map_game_control.tscn"

func _ready() -> void:
	if matchRes != null:
		displayResData()

func attachResource(newRes: MatchResource) -> void:
	if matchRes != null:
		printerr("Resource already set")
		return
	matchRes = newRes
	if playerOneContainer != null:
		displayResData()

func displayResData() -> void:
	var newPlayerScene: PackedScene = preload(playerBoxScenePath)
	var mapControlScene: PackedScene = preload(mapGameControlPath)
	var newPlayerNode = newPlayerScene.instantiate()
	newPlayerNode.attachResource(matchRes.playerOne, matchRes.playerTwo)
	newPlayerNode.setMatchPoint(matchRes.getWins()[matchRes.playerOne])
	playerNodes.append(newPlayerNode)
	playerOneContainer.add_child(newPlayerNode)
	newPlayerNode = newPlayerScene.instantiate()
	newPlayerNode.setMirror(true)
	newPlayerNode.attachResource(matchRes.playerTwo, matchRes.playerOne)
	newPlayerNode.setMatchPoint(matchRes.getWins()[matchRes.playerTwo])
	playerNodes.append(newPlayerNode)
	playerTwoContainer.add_child(newPlayerNode)
	for index in range(len(matchRes.mapPool)):
		var mapRes: MapResource = matchRes.mapPool[index]
		var mapControlNode = mapControlScene.instantiate()
		mapControlNode.setMapName(mapRes.name)
		if len(matchRes.results) == index and not matchRes.isOver():
			mapControlNode.setActive()
			mapControlNode.connect("leftWon", Callable(self, "playerOneWon"))
			mapControlNode.connect("rightWon", Callable(self, "playerTwoWon"))
		elif len(matchRes.results) > index:
			mapControlNode.setWinner(
				matchRes.results[index] == matchRes.playerOne
			)
		matchControlNodes.append(mapControlNode)
		mapPoolContainer.add_child(mapControlNode)
	showNextMap()

func showNextMap():
	if matchRes.getNextMap() != null:
		currentMapName.text = matchRes.getNextMap().name
		var texture: ImageTexture = ImageTexture.create_from_image(matchRes.getNextMap().icon)
		currentMapImage.texture = texture
		var raceOne: int = (
			matchRes.playerOne.getPlayedRaceVs(matchRes.playerTwo.getReprRace())
		)
		var raceTwo: int = (
			matchRes.playerTwo.getPlayedRaceVs(matchRes.playerOne.getReprRace())
		)
		if raceOne == raceTwo:
			currentMapVs.text = ""
			return
		currentMapVs.text = (
			Global.RaceName[raceOne][0] + " " +
			str(int(matchRes.getNextMap().getFullRecord()[raceOne][raceTwo])) +
			":" +
			str(int(matchRes.getNextMap().getFullRecord()[raceTwo][raceOne])) +
			" " +
			Global.RaceName[raceTwo][0]
		)
		return
	currentMapName.text = "(Match over)"
	var image: Image = Image.create_empty(150, 150, true, Image.FORMAT_RGB8)
	var texture: ImageTexture = ImageTexture.create_from_image(image)
	currentMapImage.texture = texture
	currentMapVs.text = ""

func playerOneWon() -> void:
	disconnectControlSignal()
	matchRes.addWin(matchRes.playerOne)
	playerNodes[0].setMatchPoint(matchRes.getWins()[matchRes.playerOne])
	showNextMap()
	connectControlSignals()

func playerTwoWon() -> void:
	disconnectControlSignal()
	matchRes.addWin(matchRes.playerTwo)
	playerNodes[1].setMatchPoint(matchRes.getWins()[matchRes.playerTwo])
	showNextMap()
	connectControlSignals()

func disconnectControlSignal() -> void:
	matchControlNodes[len(matchRes.results)].disconnect("leftWon", Callable(self, "playerOneWon"))
	matchControlNodes[len(matchRes.results)].disconnect("rightWon", Callable(self, "playerTwoWon"))

func connectControlSignals():
	if len(matchRes.results) < len(matchRes.mapPool) and not matchRes.isOver():
		matchControlNodes[len(matchRes.results)].connect("leftWon", Callable(self, "playerOneWon"))
		matchControlNodes[len(matchRes.results)].connect("rightWon", Callable(self, "playerTwoWon"))
		matchControlNodes[len(matchRes.results)].setActive()
