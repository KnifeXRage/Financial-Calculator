extends Control

@onready var title: RichTextLabel = $CanvasLayer/Background/Title
@onready var timer: Timer = $Timer
@onready var animation: AnimationPlayer = $Animation

var HEADING_FONTS = preload("res://Themes/heading_fonts.tres")

#Fonts
const DISPUTED_HOUSING = preload("res://Fonts/DisputedHousing-2vYxK.otf")
const HOME_VIDEO = preload("res://Fonts/HomeVideo-BLG6G.ttf")
const PASTI_REGULAR = preload("res://Fonts/PastiRegular-mLXnm.otf")
const QUANGO = preload("res://Fonts/Quango-xlVR.otf")
const SWANSEA = preload("res://Fonts/Swansea-q3pd.ttf")
const WILTYPE= preload("res://Fonts/Wiltype-9MA1y.ttf")

var currData: Dictionary = {
	"FontIndex" = 0,
	"History" = 0
}

func _ready() -> void:
	fixAnim()
	timer.start()
	if SaveLoad.exit:
		title.position.y = 80
		animation.play_backwards("Opening")
	else:
		animation.play("Opening")
	
	var loaded = SaveLoad.load_data("Settings")
	if !(loaded=={}):
		changeFontType(loaded["FontIndex"])

func fixAnim() -> void:
	var centerOfScreen = get_viewport_rect().get_center().y - 95.5
	animation.get_animation("Opening").track_set_key_value(0,0,[centerOfScreen,-0.25, 0.0, 0.25, 0.0])
	animation.get_animation("Opening").track_set_key_value(0,1,[centerOfScreen,-0.25, 0.0, 0.25, 0.0])
	animation.get_animation("Opening").track_set_key_value(0,2,[80.0,-0.25, 0.0, 0.25, 0.0])

func changeType(type: Font) -> void:
	HEADING_FONTS.default_font = type

func changeSize(size: int) -> void:
	HEADING_FONTS.default_font_size = size

func changeFontType(val: int) -> void:
	if val == 0:
		changeType(HOME_VIDEO)
		changeSize(50)
	elif val == 1:
		changeType(PASTI_REGULAR)
		changeSize(50)
	elif val == 2:
		changeType(SWANSEA)
		changeSize(50)
	elif val == 3:
		changeType(DISPUTED_HOUSING)
		changeSize(50)
	elif val == 4:
		changeType(WILTYPE)
		changeSize(70)
	elif val == 5:
		changeType(QUANGO)
		changeSize(60)
	else:
		changeType(null)
		changeSize(50)


func _on_timer_timeout() -> void:
	if SaveLoad.exit:
		get_tree().quit()
	else:
		get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
