extends Control

#Getting GUI Elements
@onready var loading_animations: Control = $CanvasLayer/Loading_Animations
@onready var loading: ColorRect = $CanvasLayer/Loading_Animations/Loading
@onready var mm_loading: Panel = $CanvasLayer/Loading_Animations/MM_Loading

@onready var main_menu_btn: Button = $CanvasLayer/Main_Menu_Btn
@onready var mi: LineEdit = $CanvasLayer/MI_Container/MI
@onready var mi_slider: HSlider = $CanvasLayer/MI_Container/MI_Slider
@onready var roi: LineEdit = $CanvasLayer/ROI_Container/ROI
@onready var roi_slider: HSlider = $CanvasLayer/ROI_Container/ROI_Slider
@onready var tp: LineEdit = $CanvasLayer/TP_Container/TP
@onready var tp_slider: HSlider = $CanvasLayer/TP_Container/TP_Slider
@onready var mi_heading: RichTextLabel = $CanvasLayer/MI_Container/Heading

@onready var calculate_btn: Button = $CanvasLayer/Calculate_Btn
@onready var lumpsum_btn: CheckButton = $CanvasLayer/Lumpsum_Btn
@onready var blur_window: Panel = $CanvasLayer/Blur_Window
@onready var result_window: Panel = $CanvasLayer/Result_Window
@onready var history_window: Panel = $CanvasLayer/History_Window
@onready var animations: AnimationPlayer = $Animations
@onready var anim_timer: Timer = $Anim_Timer
@onready var loading_timer: Timer = $Loading_Timer
@onready var history_timer_2: Timer = $History_Timer2

@onready var ti_value: RichTextLabel = $CanvasLayer/Result_Window/ScrollContainer/CenterContainer/Breakdown_C/TI_Value
@onready var tp_value: RichTextLabel = $CanvasLayer/Result_Window/ScrollContainer/CenterContainer/Breakdown_C/TP_Value
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
var _sip: float

var isDraggingMI: bool = false
var isDraggingROI: bool = false
var isDraggingTP: bool = false
var fromHistory: bool = false

func _ready() -> void:
	SaveLoad.getCalculation.connect(_on_history_view_btn_pressed)
	
	disable(result_window)
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


func calculateSIP(p_amount_f: float,_roi_f: float, months_f: float,ls_Btn: bool) -> void:
	if ls_Btn:
		#Lumpsum SIP Calculation
		_sip = snapped((p_amount_f*((1+(float(roi.text)/100)/1)**float(tp.text))),0.1)
		it_value.text = str("Lumpsum")
	else:
		#SIP Calculation
		_sip = snapped((p_amount_f*(((1+_roi_f)**months_f-1)/_roi_f)*(1+_roi_f)),0.1)
		it_value.text = str("SIP")


func enable(element: Variant) -> void:
	element.visible = true
	
func disable(element: Variant) -> void:
	element.visible = false

func setResult(amount_s: String,percentage_s: String,years_s: String,btn: bool) -> void:
	if btn:
		ti_value.text = str(float(amount_s))
		ta_value.text = str(_sip)
		tp_value.text = str(snapped(float(ta_value.text)-float(ti_value.text),0.1))
	else:
		ti_value.text = str(float(amount_s) * (_year))
		ta_value.text = str(_sip)
		tp_value.text = str(snapped(float(ta_value.text)-float(ti_value.text),0.1))
	
	var intrestPercent: float = (float(tp_value.text)/float(ti_value.text)*100)
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

func getResult(amount_f: String,percentage_f: String,years_f: String,btn: bool) -> void:
	_p_amount = float(amount_f)
	#Second Formula (Buggy): _roi = ((1.0+float(roi.text))**(1.0/12.0-1.0))/10.0
	_roi = pow(1.0+(float(percentage_f)/100),1.0/12.0)-1  #Monthly Interest
	_year = float(years_f)*12 #Total Months
	calculateSIP(_p_amount,_roi,_year,btn)
	setResult(amount_f,percentage_f,years_f,btn)
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
	if isDraggingMI:
		mi.text = str(mi_slider.value)
	elif isDraggingROI:
		roi.text = str(roi_slider.value)
	elif isDraggingTP:
		tp.text = str(tp_slider.value)

#Slider Siginals
func _on_mi_slider_drag_started() -> void:
	isDraggingMI = true


func _on_mi_slider_drag_ended(value_changed: bool) -> void:
	isDraggingMI = false


func _on_roi_slider_drag_started() -> void:
	isDraggingROI = true


func _on_roi_slider_drag_ended(value_changed: bool) -> void:
	isDraggingROI = false


func _on_tp_slider_drag_started() -> void:
	isDraggingTP = true


func _on_tp_slider_drag_ended(value_changed: bool) -> void:
	isDraggingTP = false


func _on_mi_text_changed(new_text: String) -> void:
	mi_slider.value = float(new_text)


func _on_roi_text_changed(new_text: String) -> void:
	roi_slider.value = float(new_text)


func _on_tp_text_changed(new_text: String) -> void:
	tp_slider.value = float(new_text)


func _on_calculate_btn_pressed() -> void:
	getResult(mi.text,roi.text,tp.text,lumpsum_btn.button_pressed)

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


func _on_mi_editing_toggled(toggled_on: bool) -> void:
	_p_amount = float(mi.text)
	if (float(mi.text)<100.0):
		mi.text = str(100.0)


func _on_roi_editing_toggled(toggled_on: bool) -> void:
	_roi = float(roi.text)
	if (float(roi.text)<1.0):
		roi.text = str(1.0)
	elif (float(roi.text)>100.0):
		roi.text = str(100.0)


func _on_tp_editing_toggled(toggled_on: bool) -> void:
	_year = float(tp.text)
	if (float(tp.text)<1.0):
		tp.text = str(1.0)
	elif (float(tp.text)>100.0):
		tp.text = str(100.0)


func _on_main_menu_btn_pressed() -> void:
	loadMainMenu()

func _on_loading_timer_timeout() -> void:
	if !isLoaded:
		disable(loading_animations)
		disable(loading)
		isLoaded = true
	else:
		get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")


func _on_lumpsum_btn_toggled(toggled_on: bool) -> void:
	if toggled_on:
		mi_heading.text = "Total Investment:"
		mi.text = "100000.0"
		mi_slider.min_value = 10000.0
		mi_slider.value = 10000.0
		mi_slider.max_value = 1000000.0
		mi_slider.step = 10000.0
	else:
		mi_heading.text = "Monthly Investment:"
		mi.text = "1000.0"
		mi_slider.min_value = 500.0
		mi_slider.value = 500.0
		mi_slider.max_value = 10000.0
		mi_slider.step = 500.0

func _on_history_view_btn_pressed(amount,percentage,years,roipp,btnChecked):
	#print(amount," ",percentage," ",years," ",btnChecked)
	fromHistory = true
	getResult(amount,percentage,years,btnChecked)


func _on_history_btn_pressed() -> void:
	fixAnimation()


func _on_history_timer_2_timeout() -> void:
	disable(history_window)
