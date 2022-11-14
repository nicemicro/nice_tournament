extends TextureRect

onready var backButton: TextureButton = $GoBack/Button
onready var fwdButton: TextureButton = $GoForward/Button

const seedScenePath: String = "res://subscenes/broadcast/seed_display.tscn"

var roundContainers: Array = []

var roundStart: int = 0

func _ready():
	roundContainers.append($Level1)
	roundContainers.append($Level2)
	roundContainers.append($Level3)

func start():
	if len(Tournament.rounds) > 3:
		fwdButton.disabled = false
	var roundEnd = min(roundStart + 3, len(Tournament.rounds))
	var scenePath: String
	for levelNum in range(roundStart, roundEnd):
		var level = Tournament.rounds[levelNum]
		for roundRes in level:
			if roundRes is SeedRound:
				scenePath = seedScenePath
			else:
				continue
			var newScene = load(scenePath)
			var roundScene = newScene.instance()
			roundScene.attachResource(roundRes)
			roundContainers[levelNum-roundStart].add_child(roundScene)
