extends VBoxContainer

onready var playerOneContainer: CenterContainer = $Container/PlayerOne
onready var playerTwoContainer: CenterContainer = $Container/PlayerTwo
onready var mapPoolContainer: VBoxContainer = $Container/Middle/MapPool
onready var currentMapName: Label = $Container/Middle/MapName
onready var currentMapImage: TextureRect = $Container/Middle/MapImage

var matchRes: MatchResource

const playerBoxScebePath: String = "res://subscenes/broadcast/full_screen_round/player_box.tscn"

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
	var newScene: PackedScene = preload(playerBoxScebePath)
	var newPlayerNode = newScene.instance()
	newPlayerNode.attachResource(matchRes.playerOne)
	playerOneContainer.add_child(newPlayerNode)
	newPlayerNode = newScene.instance()
	newPlayerNode.attachResource(matchRes.playerTwo)
	playerTwoContainer.add_child(newPlayerNode)
	for mapRes in matchRes.mapPool:
		var mapLabel: Label = Label.new()
		mapLabel.text = mapRes.name
		mapPoolContainer.add_child(mapLabel)
	if matchRes.getNextMap() != null:
		currentMapName.text = matchRes.getNextMap().name
		var texture: ImageTexture = ImageTexture.new()
		texture.create_from_image(matchRes.getNextMap().icon)
		currentMapImage.texture = texture
	else:
		currentMapName.text = ""
		var texture: ImageTexture = ImageTexture.new()
		texture.create(150, 150, Image.FORMAT_RGB8)
		currentMapImage.texture = texture
