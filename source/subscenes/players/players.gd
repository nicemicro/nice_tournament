extends Control

@onready var playerContainer: GridContainer = $ScrollContainer/GridContainer

var playerAddWindow: Window = null

const addPlayerScenePath: String = "res://subscenes/players/add_player.tscn"
const playerInfoScenePath: String = "res://subscenes/players/player_info.tscn"

signal backPressed

func addAllPlayers():
	for playerId in Global.players:
		displayPlayer(Global.players[playerId])

func _on_Back_pressed():
	self.visible = false
	emit_signal("backPressed")

func _on_AddNew_pressed():
	var newScene = preload(addPlayerScenePath)
	var playerAddWindow = newScene.instantiate()
	playerAddWindow.connect("popup_hide", Callable(self, "removeAddPlayerNode"))
	playerAddWindow.connect("playerCreated", Callable(self, "savePlayer"))
	add_child(playerAddWindow)
	playerAddWindow.show()

func removeAddPlayerNode():
	playerAddWindow.queue_free()
	playerAddWindow = null

func savePlayer(newPlayer: PlayerResource):
	Global.registerNewPlayer(newPlayer)
	displayPlayer(newPlayer)

func displayPlayer(playerRes: PlayerResource):
	var newScene = preload(playerInfoScenePath)
	var playerInfo = newScene.instantiate()
	playerInfo.setUpPlayer(playerRes)
	playerContainer.add_child(playerInfo)
