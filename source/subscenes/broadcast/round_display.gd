extends PanelContainer

onready var titleLabel: Label = $Main/Title
onready var detailContainer: VBoxContainer = $Main/Container
onready var openButton: TextureButton = $Main/OpenButton

var roundRes: RoundResource

# Called when the node enters the scene tree for the first time.
func _ready():
	if roundRes != null:
		displayResData()

func attachResource(newRes: RoundResource):
	if roundRes != null:
		printerr("Resource already set")
		return
	roundRes = newRes
	if detailContainer != null:
		displayResData()

func displayResData():
	pass

func _on_OpenButton_pressed():
	pass # Replace with function body.
