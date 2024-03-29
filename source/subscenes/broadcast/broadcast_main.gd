extends TextureRect

@onready var backButton: TextureButton = $Start/GoBack/Button
@onready var fwdButton: TextureButton = $Start/GoForward/Button
@onready var startScreen: Control = $Start
@onready var counterFooter: Control = $Counter
@onready var subScreenPoint: Control = $SubScreen

const seedScenePath: String = "res://subscenes/broadcast/seed_display.tscn"
const seedFullscreenPath: String = "res://subscenes/broadcast/full_screen_round/seed_full_screen.tscn"
const swissScenePath: String = "res://subscenes/broadcast/swiss_display.tscn"
const swissFullscreenPath: String = "res://subscenes/broadcast/full_screen_round/swiss_full_screen.tscn"
const eliminationScenePath: String = "res://subscenes/broadcast/elimination_display.tscn"
const eliminationFullscreenPath: String = "res://subscenes/broadcast/full_screen_round/elimination_full_screen.tscn"
const forwardPlayerScenePath: String = "res://subscenes/broadcast/forward_display.tscn"
const finalResultScreenPath: String = "res://subscenes/broadcast/end_result_display.tscn"

var roundContainers: Array = []
var roundNumberLabels: Array = []

var roundStart: int = 0

func _ready() -> void:
	roundContainers.append($Start/Level1)
	roundContainers.append($Start/Level2)
	roundContainers.append($Start/Level3)
	roundNumberLabels.append($Counter/Count1/Panel/Label)
	roundNumberLabels.append($Counter/Count2/Panel/Label)
	roundNumberLabels.append($Counter/Count3/Panel/Label)

func start() -> void:
	fwdButton.disabled = len(Tournament.rounds) <= roundStart + 2
	backButton.disabled = roundStart <= 0
	var roundEnd = min(roundStart + 3, len(Tournament.rounds))
	var newScene
	Tournament.progressTourney()
	for container in roundContainers:
		for node in container.get_children():
			node.queue_free()
	for levelNum in range(roundStart, roundEnd):
		roundNumberLabels[levelNum-roundStart].text = str(levelNum)
		var level = Tournament.rounds[levelNum]
		for roundRes in level:
			if roundRes is SeedRound:
				newScene = preload(seedScenePath)
			elif roundRes is SwissRound:
				newScene = preload(swissScenePath)
			elif roundRes is EliminationRound:
				newScene = preload(eliminationScenePath)
			elif roundRes is ForwardRound:
				newScene = preload(forwardPlayerScenePath)
			else:
				continue
			var roundScene = newScene.instantiate()
			roundScene.attachResource(roundRes)
			roundScene.connect("openFullScreen", Callable(self, "openNewSubscreen"))
			roundContainers[levelNum-roundStart].add_child(roundScene)
	if roundStart + 2 >= len(Tournament.rounds):
		newScene = preload(finalResultScreenPath)
		var roundScene = newScene.instantiate()
		roundScene.attachResource(Tournament.endResult)
		roundContainers[2].add_child(roundScene)
		roundNumberLabels[2].text = ""

func openNewSubscreen(roundRes: RoundResource) -> void:
	var newScene
	if roundRes is SeedRound:
		newScene = preload(seedFullscreenPath)
	elif roundRes is SwissRound:
		newScene = preload(swissFullscreenPath)
	elif roundRes is EliminationRound:
		newScene = preload(eliminationFullscreenPath)
	else:
		return
	var fullScreenScene = newScene.instantiate()
	fullScreenScene.attachResource(roundRes)
	fullScreenScene.connect("closeScreen", Callable(self, "showAllRounds"))
	subScreenPoint.add_child(fullScreenScene)
	startScreen.visible = false
	counterFooter.visible = false
	subScreenPoint.visible = true

func showAllRounds() -> void:
	startScreen.visible = true
	counterFooter.visible = true
	subScreenPoint.visible = false
	subScreenPoint.get_child(0).queue_free()
	start()

func _on_GoBackButton_pressed():
	roundStart = max(roundStart - 1, 0)
	start()

func _on_GoForwardButton_pressed():
	roundStart = min(roundStart + 1, len(Tournament.rounds) - 2)
	start()
