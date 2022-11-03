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
	#TODO: add saved rounds here
	addNewLevel()
	selectedLevel = len(levelContainers) - 1
	levelContainers[selectedLevel].setSelected(true)

func _on_Back_pressed():
	self.visible = false
	emit_signal("backPressed")

func _on_NewMenu_pressed(itemId: int):
	var roundRes: RoundResource
	var scenePath: String
	match itemId:
		0:
			roundRes = SeedRound.new()
			scenePath = seedScenePath
	Tournament.addRound(roundRes, selectedLevel)
	addNewRound(roundRes, scenePath)
	if len(levelContainers) - 1 == selectedLevel:
		addNewLevel()

func addNewRound(roundRes: RoundResource, scenePath: String) -> void:
	var newScene = load(scenePath)
	var seedScene = newScene.instance()
	seedScene.attachResource(roundRes)
	levelContainers[selectedLevel].addRound(seedScene)

func levelSelected(index: int):
	selectedLevel = index
	for levelContainer in levelContainers:
		levelContainer.setSelected(levelContainer.level == selectedLevel)

func addNewLevel() -> void:
	var newScene = preload(levelContainerScenePath)
	var newNode = newScene.instance()
	newNode.setLevel(len(levelContainers))
	newNode.connect("selected", self, "levelSelected")
	levelContainers.append(newNode)
	tournamentContainer.add_child(newNode)
