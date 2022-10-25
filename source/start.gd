extends Control

onready var mainMenu: VBoxContainer = $Menu
onready var exitButton: Button = $ExitButton
onready var playerManager: Control = $Players
onready var mapManager: Control = $Maps
onready var roundEditor: Control = $RoundEditor

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.loadMaps()
	mapManager.addAllMaps()
	mapManager.connect("backPressed", self, "showMainMenu")
	Global.loadPlayers()
	playerManager.addAllPlayers()
	playerManager.connect("backPressed", self, "showMainMenu")
	Global.loadTournament()
	roundEditor.addAllRounds()
	roundEditor.connect("backPressed", self, "showMainMenu")

func _on_Players_pressed():
	playerManager.visible = true
	mainMenu.visible = false
	exitButton.visible = false

func _on_Maps_pressed():
	mapManager.visible = true
	mainMenu.visible = false
	exitButton.visible = false

func _on_Tournament_pressed():
	roundEditor.visible = true
	mainMenu.visible = false
	exitButton.visible = false

func _on_Button_pressed():
	get_tree().quit()

func showMainMenu():
	mainMenu.visible = true
	exitButton.visible = true

func _on_Start_tree_exiting():
	Global.savePlayers()
	Global.saveMaps()
	Global.saveTournament()


