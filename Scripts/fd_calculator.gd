extends Control

#Getting GUI Elements
@onready var loading_animations: Control = $CanvasLayer/Loading_Animations
@onready var loading: ColorRect = $CanvasLayer/Loading_Animations/Loading
@onready var mm_loading: Panel = $CanvasLayer/Loading_Animations/MM_Loading

@onready var main_menu_btn: Button = $CanvasLayer/Main_Menu_Btn
@onready var ia: LineEdit = $CanvasLayer/IA_Container/IA
@onready var ia_slider: HSlider = $CanvasLayer/IA_Container/IA_Slider
@onready var roi: LineEdit = $CanvasLayer/ROI_Container/ROI
@onready var roi_slider: HSlider = $CanvasLayer/ROI_Container/ROI_Slider
@onready var iy: LineEdit = $CanvasLayer/IY_Container/IY
@onready var iy_slider: HSlider = $CanvasLayer/IY_Container/IY_Slider

@onready var compound_i_window: Panel = $CanvasLayer/CompoundI_Window
@onready var compound_i_btn: CheckButton = $CanvasLayer/CompoundI_Btn
@onready var compnd_i_timer: Timer = $CompndI_Timer
@onready var ok_btn: Button = $CanvasLayer/CompoundI_Window/Main/Ok_Btn
@onready var cancel_btn: Button = $CanvasLayer/CompoundI_Window/Main/Cancel_Btn
@onready var interest_pp: OptionButton = $CanvasLayer/CompoundI_Window/Main/Interest_PP

@onready var calculate_btn: Button = $CanvasLayer/Calculate_Btn
@onready var blur_window: Panel = $CanvasLayer/Blur_Window
@onready var result_window: Panel = $CanvasLayer/Result_Window
@onready var animations: AnimationPlayer = $Animations
@onready var result_timer: Timer = $Result_Timer
@onready var loading_timer: Timer = $Loading_Timer
@onready var history_window: Panel = $CanvasLayer/History_Window
@onready var history_timer_2: Timer = $History_Timer2

@onready var pa_value: RichTextLabel = $CanvasLayer/Result_Window/ScrollContainer/CenterContainer/Breakdown_C/PA_Value
@onready var ti_value: RichTextLabel = $CanvasLayer/Result_Window/ScrollContainer/CenterContainer/Breakdown_C/TI_Value
@onready var ta_value: RichTextLabel = $CanvasLayer/Result_Window/ScrollContainer/CenterContainer/Breakdown_C/TA_Value
@onready var it_value: RichTextLabel = $CanvasLayer/Result_Window/ScrollContainer/CenterContainer/Breakdown_C/IT_Value

@onready var chart: ProgressBar = $CanvasLayer/Result_Window/Chart_GUI/Chart
@onready var av: RichTextLabel = $CanvasLayer/Result_Window/Chart_GUI/AV
@onready var iv: RichTextLabel = $CanvasLayer/Result_Window/Chart_GUI/IV
@onready var profit: RichTextLabel = $CanvasLayer/Result_Window/Chart_GUI/ScrollContainer/CenterContainer/Profit



#Variables
var isLoaded: bool = false

var _p_amount: float
var _roi: float
var _year: float
var _fd: float

var isDraggingIA: bool = false
var isDraggingROI: bool = false
var isDraggingIY: bool = false
var fromHistory: bool = false

var selected_roipp: int

func _ready() -> void:
	SaveLoad.getCalculation.connect(_on_history_view_btn_pressed)
	
	fixPos()
	selected_roipp = interest_pp.get_selected_id()
	disable(result_window)
	disable(compound_i_window)
	enable(compound_i_window.get_child(0))
	disable(blur_window)
	enable(loading_animations)
	enable(loading)
	loading_timer.start()
	animations.play("Loading")

func _process(delta: float) -> void:
	changeDraggedValues()

func loadMainMenu()-> void:
	var lenX = (get_viewport_rect().get_center().x)
	var lenY = (get_viewport_rect().get_center().y)
	
	animations.get_animation("main_menu_loading").track_set_key_value(0,1,[lenX*2,-0.25, 0.0, 0.25, 0.0])
	animations.get_animation("main_menu_loading").track_set_key_value(1,1,[lenY*2,-0.25, 0.0, 0.25, 0.0])
	animations.get_animation("main_menu_loading").track_set_key_value(2,0,[lenX*2-80,-0.25, 0.0, 0.25, 0.0])
	
	enable(loading_animations)
	enable(mm_loading)
	animations.play("main_menu_loading")
	loading_timer.start()

func fixAnimation() -> void:
	var lenY = (get_viewport_rect().get_center().y) + 100
	
	animations.get_animation("history_down").track_set_key_value(0,1,[lenY*2,-0.25, 0.0, 0.25, 0.0])
	animations.get_animation("history_down").track_set_key_value(1,0,[-(lenY*2),-0.25, 0.0, 0.25, 0.0])
	animations.get_animation("history_window").track_set_key_value(0,0,[-(lenY*2),-0.25, 0.0, 0.25, 0.0])
	animations.get_animation("open_close_result_menu").track_set_key_value(0,0,[-(lenY*2),-0.25, 0.0, 0.25, 0.0])


func fixPos() -> void:
	var pos = (get_viewport_rect().get_center().y) - 176
	animations.get_animation("compoundI_menu").track_set_key_value(0,1,[pos,-0.25, 0.0, 0.25, 0.0])

func calculateFD(p_amount_f: float,roi_f: float, years_f: float, selected: int,btn: bool) -> void:
	if !(btn):
		#FD With Simple Interest
		_fd = snapped((p_amount_f+((p_amount_f*roi_f*years_f)/100)),0.1)
	else:
		#FD With Compound Interest
		_fd = snapped((p_amount_f*((1+(roi_f/(selected*100)))**(selected*years_f))),0.1)

func compdIMenu(opCl: bool) -> void:
	fixPos()
	if opCl:
		enable(compound_i_window)
		compound_i_btn.button_pressed = true
		animations.play("compoundI_menu")
	else:
		animations.play_backwards("compoundI_menu")
		compnd_i_timer.start()

func enable(element: Variant) -> void:
	element.visible = true
	
func disable(element: Variant) -> void:
	element.visible = false

func setResult(amount_s: String,percentage_s: String,years_s: String) -> void:
	pa_value.text = str(amount_s)
	ta_value.text = str(_fd)
	ti_value.text = str(snapped(float(ta_value.text) - float(amount_s),0.1))
	
	var intrestPercent: float = (float(ti_value.text)/float(pa_value.text)*100)
	chart.value = intrestPercent
	
	av.text = str(snapped(100-intrestPercent,0.1)) + "%"
	iv.text = str(snapped(intrestPercent,0.1)) + "%"
	profit.text = str(snapped(intrestPercent,0.1)) + "%"
	
	if intrestPercent < 100:
		enable(av)
		enable(iv)
		disable(profit)
	else:
		disable(av)
		disable(iv)
		enable(profit)
	

func getResult(amount_f: String,percentage_f: String,years_f: String,roipp:int,btn: bool) -> void:
	_p_amount = float(amount_f)
	_roi = float(percentage_f)
	_year = float(years_f)
	
	if btn:
		it_value.text = interest_pp.get_item_text(interest_pp.get_item_index(roipp))
	else:
		it_value.text = "Simple"
	
	calculateFD(_p_amount,_roi,_year,roipp,btn)
	setResult(amount_f,percentage_f,years_f)
	fixAnimation()
	
	if fromHistory:
		animations.play("history_down")
		history_timer_2.start()
	else:
		animations.play("open_close_result_menu")
	
	enable(result_window)
	disable(main_menu_btn)
	enable(blur_window)
	calculate_btn.disabled = true

func changeDraggedValues()->void:
	if isDraggingIA:
		ia.text = str(ia_slider.value)
	elif isDraggingROI:
		roi.text = str(roi_slider.value)
	elif isDraggingIY:
		iy.text = str(iy_slider.value)

#Slider Siginals
func _on_ia_slider_drag_started() -> void:
	isDraggingIA = true


func _on_ia_slider_drag_ended(value_changed: bool) -> void:
	isDraggingIA = false


func _on_roi_slider_drag_started() -> void:
	isDraggingROI = true


func _on_roi_slider_drag_ended(value_changed: bool) -> void:
	isDraggingROI = false


func _on_iy_slider_drag_started() -> void:
	isDraggingIY = true


func _on_iy_slider_drag_ended(value_changed: bool) -> void:
	isDraggingIY = false


func _on_ia_text_changed(new_text: String) -> void:
	ia_slider.value = float(new_text)


func _on_roi_text_changed(new_text: String) -> void:
	roi_slider.value = float(new_text)


func _on_iy_text_changed(new_text: String) -> void:
	iy_slider.value = float(new_text)


func _on_ia_editing_toggled(toggled_on: bool) -> void:
	ia.text = str(float(ia.text))
	if (float(ia.text)<1000.0):
		ia.text = str(1000.0)


func _on_roi_editing_toggled(toggled_on: bool) -> void:
	roi.text = str(float(roi.text))
	if (float(roi.text)<1.0):
		roi.text = str(1.0)
	elif (float(roi.text)>100.0):
		roi.text = str(100.0)


func _on_iy_editing_toggled(toggled_on: bool) -> void:
	iy.text = str(float(iy.text))
	if (float(iy.text)<1.0):
		iy.text = str(1.0)
	elif (float(iy.text)>100.0):
		iy.text = str(100.0)


func _on_calculate_btn_pressed() -> void:
	getResult(ia.text,roi.text,iy.text,selected_roipp, compound_i_btn.button_pressed)


func _on_close_btn_pressed() -> void:
	fixAnimation()
	if !fromHistory:
		animations.play_backwards("open_close_result_menu")
	else:
		enable(history_window)
		animations.play_backwards("history_down")
	result_timer.start()


func _on_result_timer_timeout() -> void:
	disable(result_window)
	disable(blur_window)
	enable(main_menu_btn)
	calculate_btn.disabled = false
	
	if fromHistory:
		enable(blur_window)
		enable(history_window)
		disable(main_menu_btn)
		fromHistory = false

func _on_compound_i_btn_toggled(toggled_on: bool) -> void:
	compdIMenu(toggled_on)
	compound_i_btn.disabled = true
	interest_pp.selected = 0
	selected_roipp = interest_pp.get_selected_id()
	it_value.text = "Simple"


func _on_compnd_i_timer_timeout() -> void:
	compound_i_btn.disabled = false
	compound_i_window.visible = false


func _on_interest_pp_item_selected(index: int) -> void:
	selected_roipp = interest_pp.get_selected_id()

func _on_ok_btn_pressed() -> void:
	compdIMenu(false)
	compound_i_btn.disabled = true
	selected_roipp = interest_pp.get_selected_id()
	it_value.text = interest_pp.get_item_text(interest_pp.selected)

func _on_cancel_btn_pressed() -> void:
	compdIMenu(false)
	compound_i_btn.button_pressed = false
	compound_i_btn.disabled = true
	interest_pp.selected = 0
	selected_roipp = interest_pp.get_selected_id()


func _on_main_menu_btn_pressed() -> void:
	loadMainMenu()


func _on_loading_timer_timeout() -> void:
	if !isLoaded:
		disable(loading_animations)
		disable(loading)
		isLoaded = true
	else:
		get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func _on_history_view_btn_pressed(amount,percentage,years,roipp,btnChecked):
	print(amount," ",percentage," ",years," ",roipp," ", btnChecked)
	fromHistory = true
	getResult(amount,percentage,years,roipp, btnChecked)


func _on_history_btn_pressed() -> void:
	fixAnimation()


func _on_history_timer_2_timeout() -> void:
	disable(history_window)
