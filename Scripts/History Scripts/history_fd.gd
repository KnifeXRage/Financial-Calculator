extends Panel

@onready var main_menu_btn: Button = $"../Main_Menu_Btn"
@onready var history_btn: Button = $"../History_Btn"
@onready var blur_window: Panel = $"../Blur_Window"
@onready var history_window: Panel = $"."
@onready var history_box: VBoxContainer = $History_Scroll/History_Box
@onready var animations: AnimationPlayer = $"../../Animations"
@onready var history_timer: Timer = $"../../History_Timer"
@onready var no_history_text: RichTextLabel = $No_History_Text
@onready var history_scroll: ScrollContainer = $History_Scroll
@onready var compound_i_btn: CheckButton = $"../CompoundI_Btn"
@onready var clear_btn: Button = $Clear_Btn
@onready var interest_pp: OptionButton = $"../CompoundI_Window/Main/Interest_PP"


@onready var ia: LineEdit = $"../IA_Container/IA"
@onready var roi: LineEdit = $"../ROI_Container/ROI"
@onready var iy: LineEdit = $"../IY_Container/IY"


const HISTORY_BOX = preload("res://Scenes/history_box.tscn")

#VARIABLES
var currChildCount: int = 0
var currData: Dictionary = {}

func _ready() -> void:
	clear_btn.disabled = true
	if !(SaveLoad.historyEnabled):
		disable(history_btn)
	
	disable(history_window)
	disable(history_scroll)
	enable(no_history_text)
	loadHistory()

func hisBtnChar(state: bool,currId: int) -> int:
	if state:
		return currId
	return 3

func getDT() -> String:
	var dt: String = Time.get_datetime_string_from_system()
	dt = dt.replace("T"," (")
	dt += ")"
	return dt

func removeSecondsFromDT(dateTime: String) -> String:
	var loopI = -4
	while (loopI<0):
		dateTime[loopI] = ""
		loopI += 1
	dateTime += ")"
	return dateTime

func createHistory(currDT: String = getDT(),amount: String = ia.text,percent: String = roi.text,years: String = iy.text,selRoi: int = hisBtnChar(compound_i_btn.button_pressed,interest_pp.get_selected_id()), btnPressed: bool = compound_i_btn.button_pressed) -> void:
	currChildCount += 1
	enable(history_scroll)
	disable(no_history_text)
	
	var box = HISTORY_BOX.instantiate()
	history_box.add_child(box)
	history_box.move_child(box,0)
	box.setValues(removeSecondsFromDT(currDT),float(amount),float(percent),float(years),selRoi, btnPressed)
	
	currData[currDT] = {
		"amount" = amount,
		"percent" = percent,
		"years" = years,
		"roipp" = selRoi,
		"btnPressed" = btnPressed
	}
	clear_btn.disabled = false

func saveHistory() -> void:
	SaveLoad.save_data(currData,"FD")

func loadHistory() -> void:
	currChildCount = 0
	var loaded: Dictionary = SaveLoad.load_data("FD")
	if !(loaded == {}):
		enable(history_scroll)
		disable(no_history_text)
		var keys: Array = loaded.keys()
		for i in range(len(keys)):
			createHistory(keys[i],loaded[keys[i]]["amount"],loaded[keys[i]]["percent"],loaded[keys[i]]["years"],hisBtnChar(loaded[keys[i]]["btnPressed"],loaded[keys[i]]["roipp"]), loaded[keys[i]]["btnPressed"])
			currChildCount += 1

func clearHistory() -> void:
	clear_btn.disabled = true
	disable(history_scroll)
	enable(no_history_text)
	no_history_text.text = "History Cleared"
	currData = {}
	currChildCount = 0
	SaveLoad.delete_data("FD")
	for c in range(len(history_box.get_children())):
		history_box.get_child(c).queue_free()


func enable(element: Variant) -> void:
	element.visible = true
	
func disable(element: Variant) -> void:
	element.visible = false

func _on_history_btn_pressed() -> void:
	enable(history_window)
	enable(blur_window)
	disable(history_btn)
	disable(main_menu_btn)
	animations.play("history_window")


func _on_close_btn_pressed() -> void:
	animations.play_backwards("history_window")
	history_timer.start()


func _on_history_timer_timeout() -> void:
	disable(history_window)
	disable(blur_window)
	enable(history_btn)
	enable(main_menu_btn)
	no_history_text.text = "No History"


func _on_calculate_btn_pressed() -> void:
	if (SaveLoad.historyEnabled):
		createHistory()
		saveHistory()


func _on_clear_btn_pressed() -> void:
	clearHistory()
