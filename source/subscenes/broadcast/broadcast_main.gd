extends TextureRect

onready var backButton: TextureButton = $Start/GoBack/Button
onready var fwdButton: TextureButton = $Start/GoForward/Button
onready var startScreen: Control = $Start
onready var subScreenPoint: Control = $SubScreen

const seedScenePath: String = "res://subscenes/broadcast/seed_display.tscn"
const seedFullscreenPath: String = "res://subscenes/broadcast/full_screen_round/seed_full_screen.tscn"
const swissScenePath: String = "res://subscenes/broadcast/swiss_display.tscn"
const swissFullscreenPath: String = "res://subscenes/broadcast/full_screen_round/swiss_full_screen.tscn"
const eliminationScenePath: String = "res://subscenes/broadcast/elimination_display.tscn"
const eliminationFullscreenPath: String = "res://subscenes/broadcast/full_screen_round/elimination_full_screen.tscn"

var roundContainers: Array = []

var roundStart: int = 0

func _ready() -> void:
	roundContainers.append($Start/Level1)
	roundContainers.append($Start/Level2)
	roundContainers.append($Start/Level3)

func start() -> void:
	fwdButton.disabled = len(Tournament.rounds) <= roundStart + 3
	backButton.disabled = roundStart <= 0
	var roundEnd = min(roundStart + 3, len(Tournament.rounds))
	var newScene
	Tournament.progressTourney()
	for container in roundContainers:
		for node in container.get_children():
			node.queue_free()
	for levelNum in range(roundStart, roundEnd):
		var level = Tournament.rounds[levelNum]
		for roundRes in level:
			if roundRes is SeedRound:
				newScene = preload(seedScenePath)
			elif roundRes is SwissRound:
				newScene = preload(swissScenePath)
			elif roundRes is EliminationRound:
				newScene = preload(eliminationScenePath)
			else:
				continue
			var roundScene = newScene.instance()
			roundScene.attachResource(roundRes)
			roundScene.connect("openFullScreen", self, "openNewSubscreen")
			roundContainers[levelNum-roundStart].add_child(roundScene)

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
	var fullScreenScene = newScene.instance()
	fullScreenScene.attachResource(roundRes)
	fullScreenScene.connect("closeScreen", self, "showAllRounds")
	subScreenPoint.add_child(fullScreenScene)
	startScreen.visible = false
	subScreenPoint.visible = true

func showAllRounds() -> void:
	startScreen.visible = true
	subScreenPoint.visible = false
	subScreenPoint.get_child(0).queue_free()
	start()

func _on_GoBackButton_pressed():
	roundStart = max(roundStart - 1, 0)
	start()

func _on_GoForwardButton_pressed():
	roundStart = min(roundStart + 1, len(Tournament.rounds) - 3)
	start()
