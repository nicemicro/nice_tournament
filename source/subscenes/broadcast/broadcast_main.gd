extends TextureRect

onready var backButton: TextureButton = $Start/GoBack/Button
onready var fwdButton: TextureButton = $Start/GoForward/Button
onready var startScreen: Control = $Start
onready var subScreenPoint: Control = $SubScreen

const seedScenePath: String = "res://subscenes/broadcast/seed_display.tscn"
const seedFullscreenPath: String = "res://subscenes/broadcast/full_screen_round/seed_full_screen.tscn"
const swissScenePath: String = "res://subscenes/broadcast/swiss_display.tscn"

var roundContainers: Array = []

var roundStart: int = 0

func _ready() -> void:
	roundContainers.append($Start/Level1)
	roundContainers.append($Start/Level2)
	roundContainers.append($Start/Level3)

func start() -> void:
	if len(Tournament.rounds) > 3:
		fwdButton.disabled = false
	var roundEnd = min(roundStart + 3, len(Tournament.rounds))
	var newScene
	Tournament.progressTourney()
	for levelNum in range(roundStart, roundEnd):
		var level = Tournament.rounds[levelNum]
		for roundRes in level:
			if roundRes is SeedRound:
				newScene = preload(seedScenePath)
			elif roundRes is SwissRound:
				newScene = preload(swissScenePath)
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
