extends Control

onready var addNewButton: MenuButton = $AddNew
onready var tournamentContainer: HBoxContainer = $Container/HBoxContainer

var addNewMenu: PopupMenu
var levelContainers: Array = []
var selectedLevel: int = -1

const levelContainerScenePath: String = "res://subscenes/tournament/level_container.tscn"
const seedScenePath: String = "res://subscenes/tournament/seeded_players.tscn"
const GroupEditScenePath: String = "res://subscenes/tournament/group_edit.tscn"
const DualTourneyEditScenePath: String = "res://subscenes/tournament/dual_tourney_edit.tscn"
const EliminationEditScenePath: String = "res://subscenes/tournament/elimination_edit.tscn"
const SwissRoundEditScenePath: String = "res://subscenes/tournament/swiss_round_edit.tscn"

signal backPressed

func _ready():
	addNewMenu = addNewButton.get_popup()
	addNewMenu.connect("id_pressed", self, "_on_NewMenu_pressed")

func addAllRounds():
	var newScene
	var newNode
	var counter: int = 0
	var scenePath: String
	for level in Tournament.rounds:
		addNewLevel()
		for roundRes in level:
			if roundRes is SeedRound:
				scenePath = seedScenePath
			elif roundRes is GroupRound:
				scenePath = GroupEditScenePath
			elif roundRes is DualTourneyRound:
				scenePath = DualTourneyEditScenePath
			elif roundRes is EliminationRound:
				scenePath = EliminationEditScenePath
			elif roundRes is SwissRound:
				scenePath = SwissRoundEditScenePath
			addNewRound(roundRes, scenePath)
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
		1:
			roundRes = GroupRound.new()
			scenePath = GroupEditScenePath
		2:
			roundRes = DualTourneyRound.new()
			scenePath = DualTourneyEditScenePath
		3:
			roundRes = EliminationRound.new()
			scenePath = EliminationEditScenePath
		4:
			roundRes = SwissRound.new()
			scenePath = SwissRoundEditScenePath
	Tournament.addRound(roundRes, selectedLevel)
	addNewRound(roundRes, scenePath)
	if len(levelContainers) - 1 == selectedLevel:
		addNewLevel()

func addNewRound(roundRes: RoundResource, scenePath: String) -> void:
	var newScene = load(scenePath)
	var RoundScene = newScene.instance()
	RoundScene.attachResource(roundRes)
	levelContainers[selectedLevel].addRound(RoundScene)

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
