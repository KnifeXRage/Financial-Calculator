extends Control

@onready var date_time: RichTextLabel = $Background/Date_Time
@onready var amount_vals: RichTextLabel = $Background/ScrollContainer/His_Vals/Amount
@onready var percent_vals: RichTextLabel = $Background/ScrollContainer/His_Vals/Percent_Vals
@onready var year_vals: RichTextLabel = $Background/ScrollContainer/His_Vals/Year_Vals
@onready var btn_state: RichTextLabel = $Background/ScrollContainer/His_Vals/Btn_State

@onready var seperator_3: RichTextLabel = $Background/ScrollContainer/His_Vals/Seperator_3

var isChecked: bool = false
var roippVar: int = 0

func setValues(dateTime: String,amount: float, percent: float,years: float,roipp: int = 0, checked: bool = false) -> void:
	date_time.text = str(dateTime)
	amount_vals.text = str(amount)
	percent_vals.text = str(percent) + "%"
	if years == 0:
		seperator_3.visible = false
		year_vals.visible = false
		year_vals.text = ""
	else:
		seperator_3.visible = true
		year_vals.visible = true
		year_vals.text = str(years)
	
	btn_state.text = setBtnTextForChecked(roipp)
	if checked == true:
		isChecked = true
		roippVar = roipp

func setBtnTextForChecked(roipp: int) -> String:
	var returnCharDict: Dictionary = {"1":"Y","2":"H","3":"S","4":"Q","5":"R","6":"I","7":"E","8":"L","12":"M"}
	return returnCharDict[str(roipp)]

func _on_view_btn_pressed() -> void:
	SaveLoad.getCalculation.emit(amount_vals.text,percent_vals.text,year_vals.text,roippVar, isChecked)
