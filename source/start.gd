extends Control

@onready var mainMenu: VBoxContainer = $Menu
@onready var exitButton: Button = $ExitButton
@onready var saveButton: Button = $SaveButton
@onready var playerManager: Control = $Players
@onready var mapManager: Control = $Maps
@onready var roundEditor: Control = $TournamentEditor
@onready var broadcastScreen: TextureRect = $BroadcastBG

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.loadMaps()
	mapManager.addAllMaps()
	mapManager.connect("backPressed", Callable(self, "showMainMenu"))
	Global.loadPlayers()
	playerManager.addAllPlayers()
	playerManager.connect("backPressed", Callable(self, "showMainMenu"))
	Global.loadTournament()
	roundEditor.addAllRounds()
	roundEditor.connect("backPressed", Callable(self, "showMainMenu"))

func _on_Players_pressed():
	playerManager.visible = true
	hideMainMenu()

func _on_Maps_pressed():
	mapManager.visible = true
	hideMainMenu()

func _on_Tournament_pressed():
	roundEditor.visible = true
	hideMainMenu()

func _on_Play_pressed():
	broadcastScreen.visible = true
	hideMainMenu()
	broadcastScreen.start()

func _on_Button_pressed():
	get_tree().quit()

func hideMainMenu():
	mainMenu.visible = false
	exitButton.visible = false
	saveButton.visible = false

func showMainMenu():
	mainMenu.visible = true
	exitButton.visible = true
	saveButton.visible = true

func _on_Start_tree_exiting():
	Global.savePlayers()
	Global.saveMaps()
	Global.saveTournament()

func _on_SaveButton_pressed():
	Global.savePlayers()
	Global.saveMaps()
	Global.saveTournament()
