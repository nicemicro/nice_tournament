extends Control

onready var addNewButton: MenuButton = $AddNew
onready var tournamentContainer: HBoxContainer = $Container/HBoxContainer

var addNewMenu: PopupMenu
var levelContainers: Array = []
var selectedLevel: int = -1

const levelContainerScenePath: String = "res://subscenes/tournament/level_container.tscn"
const seedScenePath: String = "res://subscenes/tournament/seeded_players.tscn"

signal backPressed

func _ready():
	addNewMenu = addNewButton.get_popup()
	addNewMenu.connect("id_pressed", self, "_on_NewMenu_pressed")

func addAllRounds():
	var newScene
	var newNode
	var counter: int = 0
	newScene = preload(levelContainerScenePath) 
	newNode = newScene.instance()
	newNode.setSelected(true)
	newNode.setLevel(counter)
	newNode.connect("selected", self, "levelSelected")
	selectedLevel = counter
	levelContainers.append(newNode)
	tournamentContainer.add_child(newNode)

func _on_Back_pressed():
	self.visible = false
	emit_signal("backPressed")

func _on_NewMenu_pressed(itemId: int):
	match itemId:
		0:
			addNewSeedRound()

func addNewSeedRound() -> void:
	#TODO first we need to add the seed round resource to the list!
	var newScene = preload(seedScenePath)
	var seedScene = newScene.instance()
	levelContainers[selectedLevel].addRound(seedScene)

func levelSelected(index: int):
	selectedLevel = index
	levelContainers[selectedLevel].setSelected(true)
