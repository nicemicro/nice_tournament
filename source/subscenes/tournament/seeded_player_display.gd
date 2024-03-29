extends HBoxContainer

@onready var nameLabel: Label = $NameRace
@onready var virtPointInput: LineEdit = $VirtualPoints
@onready var actionMenuButton: MenuButton = $Action

var player: PlayerResource

signal action

# Called when the node enters the scene tree for the first time.
func _ready():
	if player != null:
		showPlayerDetails()
	var actionList = actionMenuButton.get_popup()
	actionList.connect("id_pressed", Callable(self, "_on_ActionMenuPoint_pressed"))

func attachResource(newRes: PlayerResource) -> void:
	if (player != null):
		printerr("Resource already set")
		return
	player = newRes
	if nameLabel != null:
		showPlayerDetails()
		
func showPlayerDetails() -> void:
	nameLabel.text = (
		player.name + " (" +
		player.getRaceName() + ")"
	)
	if player.virtualPoints != 0:
		virtPointInput.text = str(player.virtualPoints)

func _on_VirtualPoints_text_changed(new_text):
	if str(int(new_text)) != new_text:
		virtPointInput.text = ""
	player.virtualPoints = int(virtPointInput.text)

func _on_ActionMenuPoint_pressed(id: int) -> void:
	emit_signal("action", player, id)
