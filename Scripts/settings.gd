extends Panel

@onready var settings_menu: Panel = $"."
@onready var main_window: Panel = $Main
@onready var animations: AnimationPlayer = $"../Animations"
@onready var ok_btn: Button = $Main/Exit_SC/Ok_Btn
@onready var credit_btn: Button = $Main/Exit_SC/Credit_Btn
@onready var settings_timer: Timer = $"../Settings_Timer"
@onready var font_options: OptionButton = $Main/Font_Settings/Font_Options
@onready var history_on_off: OptionButton = $Main/History_Settings/History_OnOff

@onready var credits_timer: Timer = $"../Credits_Timer"
@onready var loading_animations: Control = $"../Loading_Animations"
@onready var loading: ColorRect = $"../Loading_Animations/Loading"

#Themes
var DEFAULT = preload("res://Themes/default.tres")
var HEADING_FONTS = preload("res://Themes/heading_fonts.tres")
var MEDIUM_FONTS = preload("res://Themes/medium_fonts.tres")
var SMALL_FONTS = preload("res://Themes/small_fonts.tres")
var GREEN_BUTTON_FONT = preload("res://Themes/green_button.tres")
var RED_BUTTON_FONT = preload("res://Themes/red_button.tres")
var SBLUE_BUTTON = preload("res://Themes/sblue_button.tres")

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
	enable(main_window)
	var loaded = SaveLoad.load_data("Settings")
	if !(loaded=={}):
		changeFontType(loaded["FontIndex"])
		isHistory(loaded["History"])
		font_options.selected = loaded["FontIndex"]
		history_on_off.selected = loaded["History"]

func enable(element: Variant) -> void:
	element.visible = true
	
func disable(element: Variant) -> void:
	element.visible = false

func fixPos() -> void:
	var pos = (get_viewport_rect().get_center().y) - 350
	animations.get_animation("Setting_Menu").track_set_key_value(0,1,[pos,-0.25, 0.0, 0.25, 0.0])

func changeSize(default: int,header: int, medium: int,small: int) -> void:
	DEFAULT.default_font_size = default
	HEADING_FONTS.default_font_size = header
	MEDIUM_FONTS.default_font_size = medium
	SMALL_FONTS.default_font_size = small
	GREEN_BUTTON_FONT.default_font_size = medium
	RED_BUTTON_FONT.default_font_size = medium
	SBLUE_BUTTON.default_font_size = medium

func changeType(font: FontFile) -> void:
	DEFAULT.default_font = font
	HEADING_FONTS.default_font = font
	MEDIUM_FONTS.default_font = font
	SMALL_FONTS.default_font = font
	GREEN_BUTTON_FONT.default_font = font
	RED_BUTTON_FONT.default_font = font
	SBLUE_BUTTON.default_font = font

func changeFontType(val: int) -> void:
	if val == 0:
		changeType(HOME_VIDEO)
		changeSize(40,50,30,18)
	elif val == 1:
		changeType(PASTI_REGULAR)
		changeSize(40,50,35,18)
	elif val == 2:
		changeType(SWANSEA)
		changeSize(40,50,35,18)
	elif val == 3:
		changeType(DISPUTED_HOUSING)
		changeSize(40,50,30,18)
	elif val == 4:
		changeType(WILTYPE)
		changeSize(50,70,50,25)
	elif val == 5:
		changeType(QUANGO)
		changeSize(45,60,40,22)
	else:
		changeType(null)
		changeSize(40,50,30,18)

func isHistory(value: int)-> void:
	if value == 1:
		SaveLoad.historyEnabled = true
	else:
		SaveLoad.historyEnabled = false

func saveSettings(value1: int,value2: int)-> void:
	currData["FontIndex"] = value1
	changeFontType(value1)
	currData["History"] = value2
	isHistory(value2)
	SaveLoad.save_data(currData,"Settings")

func _on_settings_btn_pressed() -> void:
	fixPos()
	enable(settings_menu)
	animations.play("Setting_Menu")


func _on_ok_btn_pressed() -> void:
	animations.play_backwards("Setting_Menu")
	settings_timer.start()


func _on_settings_timer_timeout() -> void:
	disable(settings_menu)


func _on_font_options_item_selected(index: int) -> void:
	saveSettings(index,history_on_off.selected)


func _on_history_on_off_item_selected(index: int) -> void:
	saveSettings(font_options.selected,index)


func _on_ch_btn_pressed() -> void:
	SaveLoad.delete_data("EMI")
	SaveLoad.delete_data("FD")
	SaveLoad.delete_data("SIP")
	SaveLoad.delete_data("GST")


func _on_credit_btn_pressed() -> void:
	loading.size.y = get_viewport_rect().get_center().y*2
	loading.position.y = 0
	enable(loading_animations)
	enable(loading)
	animations.play_backwards("Loading")
	credits_timer.start()

func _on_credits_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://Scenes/credits_window.tscn")
