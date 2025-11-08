extends Control

#Getting GUI Elements
@onready var loading_animations: Control = $CanvasLayer/Loading_Animations
@onready var loading: ColorRect = $CanvasLayer/Loading_Animations/Loading
@onready var mm_loading: Panel = $CanvasLayer/Loading_Animations/MM_Loading


@onready var main_menu_btn: Button = $CanvasLayer/Main_Menu_Btn
@onready var la: LineEdit = $CanvasLayer/LA_Container/LA
@onready var la_slider: HSlider = $CanvasLayer/LA_Container/LA_Slider
@onready var roi: LineEdit = $CanvasLayer/ROI_Container/ROI
@onready var roi_slider: HSlider = $CanvasLayer/ROI_Container/ROI_Slider
@onready var ly: LineEdit = $CanvasLayer/LY_Container/LY
@onready var ly_slider: HSlider = $CanvasLayer/LY_Container/LY_Slider

@onready var calculate_btn: Button = $CanvasLayer/Calculate_Btn
@onready var simple_i_btn: CheckButton = $CanvasLayer/SimpleI_Btn
@onready var blur_window: Panel = $CanvasLayer/Blur_Window
@onready var result_window: Panel = $CanvasLayer/Result_Window
@onready var history_window: Panel = $CanvasLayer/History_Window

@onready var animations: AnimationPlayer = $Animations
@onready var anim_timer: Timer = $Anim_Timer
@onready var loading_timer: Timer = $Loading_Timer
@onready var history_timer_2: Timer = $History_Timer2

@onready var pa_value: RichTextLabel = $CanvasLayer/Result_Window/ScrollContainer/CenterContainer/Breakdown_C/PA_Value
@onready var m_emi_value: RichTextLabel = $CanvasLayer/Result_Window/ScrollContainer/CenterContainer/Breakdown_C/M_EMI_Value
@onready var ti_value: RichTextLabel = $CanvasLayer/Result_Window/ScrollContainer/CenterContainer/Breakdown_C/TI_Value
@onready var ta_value: RichTextLabel = $CanvasLayer/Result_Window/ScrollContainer/CenterContainer/Breakdown_C/TA_Value
@onready var et_value: RichTextLabel = $CanvasLayer/Result_Window/ScrollContainer/CenterContainer/Breakdown_C/ET_Value

@onready var chart: ProgressBar = $CanvasLayer/Result_Window/Chart_GUI/Chart
@onready var av: RichTextLabel = $CanvasLayer/Result_Window/Chart_GUI/AV
@onready var iv: RichTextLabel = $CanvasLayer/Result_Window/Chart_GUI/IV
@onready var loss: RichTextLabel = $CanvasLayer/Result_Window/Chart_GUI/ScrollContainer/CenterContainer/Loss



#Variables
var isLoaded: bool = false

var _p_amount: float
var _roi: float
var _year: float
var _emi: float

var isDraggingLA: bool = false
var isDraggingROI: bool = false
var isDraggingLY: bool = false
var fromHistory: bool = false

func _ready() -> void:
	SaveLoad.getCalculation.connect(_on_history_view_btn_pressed)
	
	disable(mm_loading)
	disable(result_window)
	disable(blur_window)
	enable(loading_animations)
	enable(loading)
	loading_timer.start()
	animations.play("Loading")

func _process(delta: float) -> void:
	changeDraggedValues()

func calculateEMI(p_amount_f: float,_roi_f: float, months_f: float,si_btn: bool) -> void:
	if si_btn:
		#EMI With Simple Interest
		_emi = snapped(((p_amount_f+((p_amount_f*float(_roi_f*100*12)*float(months_f/12))/100))/months_f),0.1)
		et_value.text = "Simple"
	else:
		#EMI With Compound Interest
		_emi = snapped((p_amount_f*_roi_f*((1+_roi_f)**months_f))/(((1+_roi_f)**months_f)-1),0.1)
		et_value.text = "Reducing"

func fixAnimation() -> void:
	var lenY = (get_viewport_rect().get_center().y) + 100
	
	animations.get_animation("history_down").track_set_key_value(0,1,[lenY*2,-0.25, 0.0, 0.25, 0.0])
	animations.get_animation("history_down").track_set_key_value(1,0,[-(lenY*2),-0.25, 0.0, 0.25, 0.0])
	animations.get_animation("history_window").track_set_key_value(0,0,[-(lenY*2),-0.25, 0.0, 0.25, 0.0])
	animations.get_animation("open_close_result_menu").track_set_key_value(0,0,[-(lenY*2),-0.25, 0.0, 0.25, 0.0])

func enable(element: Variant) -> void:
	element.visible = true
	
func disable(element: Variant) -> void:
	element.visible = false

func setResult(amount_s: String,percentage_s: String,years_s: String) -> void:
	pa_value.text = str(amount_s)
	m_emi_value.text = str(_emi)
	ta_value.text = str((_emi * (float(years_s) * 12)))
	ti_value.text = str(snapped(float(ta_value.text) - float(amount_s),0.1))
	
	var intrestPercent: float = (float(ti_value.text)/float(pa_value.text)*100)
	chart.value = intrestPercent
	
	av.text = str(snapped(100-intrestPercent,0.1)) + "%"
	iv.text = str(snapped(intrestPercent,0.1)) + "%"
	loss.text = str(snapped(intrestPercent,0.1)) + "%"
	
	if intrestPercent < 100:
		enable(av)
		enable(iv)
		disable(loss)
	else:
		disable(av)
		disable(iv)
		enable(loss)

func getResult(amount_f: String,percentage_f: String,years_f: String,btn: bool) -> void:
	_p_amount = float(amount_f)
	_roi = (float(percentage_f)/100)/12 #Monthly Interest
	_year = float(years_f)*12 #Total Months
	
	calculateEMI(_p_amount,_roi,_year,btn)
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

func changeDraggedValues()->void:
	if isDraggingLA:
		la.text = str(la_slider.value)
	elif isDraggingROI:
		roi.text = str(roi_slider.value)
	elif isDraggingLY:
		ly.text = str(ly_slider.value)

#Slider Siginals
func _on_la_slider_drag_started() -> void:
	isDraggingLA = true


func _on_la_slider_drag_ended(value_changed: bool) -> void:
	isDraggingLA = false


func _on_roi_slider_drag_started() -> void:
	isDraggingROI = true


func _on_roi_slider_drag_ended(value_changed: bool) -> void:
	isDraggingROI = false


func _on_ly_slider_drag_started() -> void:
	isDraggingLY = true


func _on_ly_slider_drag_ended(value_changed: bool) -> void:
	isDraggingLY = false


func _on_la_text_changed(new_text: String) -> void:
	la_slider.value = float(new_text)


func _on_roi_text_changed(new_text: String) -> void:
	roi_slider.value = float(new_text)


func _on_ly_text_changed(new_text: String) -> void:
	ly_slider.value = float(new_text)


func _on_calculate_btn_pressed() -> void:
	getResult(la.text,roi.text,ly.text,simple_i_btn.button_pressed)

func _on_close_btn_pressed() -> void:
	fixAnimation()
	if !fromHistory:
		animations.play_backwards("open_close_result_menu")
	else:
		enable(history_window)
		animations.play_backwards("history_down")
	anim_timer.start()


func _on_anim_timer_timeout() -> void:
	disable(result_window)
	disable(blur_window)
	enable(main_menu_btn)
	calculate_btn.disabled = false
	
	if fromHistory:
		enable(blur_window)
		enable(history_window)
		disable(main_menu_btn)
		fromHistory = false


func _on_la_editing_toggled(toggled_on: bool) -> void:
	la.text = str(float(la.text))
	if (float(la.text)<1000.0):
		la.text = str(1000.0)


func _on_roi_editing_toggled(toggled_on: bool) -> void:
	roi.text = str(float(roi.text))
	if (float(roi.text)<1.0):
		roi.text = str(1.0)
	elif (float(roi.text)>100.0):
		roi.text = str(100.0)


func _on_ly_editing_toggled(toggled_on: bool) -> void:
	ly.text = str(float(ly.text))
	if (float(ly.text)<1.0):
		ly.text = str(1.0)
	elif (float(ly.text)>100.0):
		ly.text = str(100.0)


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
	#print(amount," ",percentage," ",years," ",btnChecked)
	fromHistory = true
	getResult(amount,percentage,years,btnChecked)
	


func _on_history_btn_pressed() -> void:
	fixAnimation()


func _on_history_timer_2_timeout() -> void:
	disable(history_window)
