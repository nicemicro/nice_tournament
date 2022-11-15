extends "res://subscenes/broadcast/full_screen_round/round_full_screen.gd"

onready var playerContainer: GridContainer = $PanelContainer/Main/Container/Players
const playerBoxScenePath: String = "res://subscenes/broadcast/full_screen_round/player_box.tscn"


func _ready() -> void:
	if roundRes != null:
		displayResData()

func attachResource(newRes: RoundResource):
	if not newRes is SeedRound:
		printerr("This UI is for displaying Seed Rounds only.")
		return
	.attachResource(newRes)

func displayResData():
	for player in roundRes.seededPlayers:
		var newScene = preload(playerBoxScenePath)
		var newPlayerScene = newScene.instance()
		newPlayerScene.attachResource(player)
		playerContainer.add_child(newPlayerScene)
