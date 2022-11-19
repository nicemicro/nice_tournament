extends VBoxContainer

onready var playerOneContainer: CenterContainer = $Container/PlayerOne
onready var playerTwoContainer: CenterContainer = $Container/PlayerTwo
onready var mapPoolContainer: VBoxContainer = $Container/Middle/MapPool
onready var currentMapName: Label = $Container/Middle/MapName
onready var currentMapImage: TextureRect = $Container/Middle/MapImage

var matchRes: MatchResource
var matchControlNodes: Array = []

const playerBoxScebePath: String = "res://subscenes/broadcast/full_screen_round/player_box.tscn"
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
	var newPlayerScene: PackedScene = preload(playerBoxScebePath)
	var mapControlScene: PackedScene = preload(mapGameControlPath)
	var newPlayerNode = newPlayerScene.instance()
	newPlayerNode.attachResource(matchRes.playerOne)
	playerOneContainer.add_child(newPlayerNode)
	newPlayerNode = newPlayerScene.instance()
	newPlayerNode.attachResource(matchRes.playerTwo)
	playerTwoContainer.add_child(newPlayerNode)
	for index in range(len(matchRes.mapPool)):
		var mapRes: MapResource = matchRes.mapPool[index]
		var mapControlNode = mapControlScene.instance()
		mapControlNode.setMapName(mapRes.name)
		if len(matchRes.results) == index and not matchRes.isOver():
			mapControlNode.setActive()
			mapControlNode.connect("leftWon", self, "playerOneWon")
			mapControlNode.connect("rightWon", self, "playerTwoWon")
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
		var texture: ImageTexture = ImageTexture.new()
		texture.create_from_image(matchRes.getNextMap().icon)
		currentMapImage.texture = texture
	else:
		currentMapName.text = "(Match over)"
		var texture: ImageTexture = ImageTexture.new()
		texture.create(150, 150, Image.FORMAT_RGB8)
		currentMapImage.texture = texture

func playerOneWon() -> void:
	disconnectControlSignal()
	matchRes.addWin(matchRes.playerOne)
	showNextMap()
	connectControlSignals()

func playerTwoWon() -> void:
	disconnectControlSignal()
	matchRes.addWin(matchRes.playerTwo)
	showNextMap()
	connectControlSignals()

func disconnectControlSignal() -> void:
	matchControlNodes[len(matchRes.results)].disconnect("leftWon", self, "playerOneWon")
	matchControlNodes[len(matchRes.results)].disconnect("rightWon", self, "playerTwoWon")

func connectControlSignals():
	if len(matchRes.results) < len(matchRes.mapPool) and not matchRes.isOver():
		matchControlNodes[len(matchRes.results)].connect("leftWon", self, "playerOneWon")
		matchControlNodes[len(matchRes.results)].connect("rightWon", self, "playerTwoWon")
		matchControlNodes[len(matchRes.results)].setActive()
