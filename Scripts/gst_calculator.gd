extends Control

#Getting GUI Elements
@onready var loading_animations: Control = $CanvasLayer/Loading_Animations
@onready var loading: ColorRect = $CanvasLayer/Loading_Animations/Loading
@onready var mm_loading: Panel = $CanvasLayer/Loading_Animations/MM_Loading

@onready var main_menu_btn: Button = $CanvasLayer/Main_Menu_Btn
@onready var price: LineEdit = $CanvasLayer/Price_Container/Price
@onready var price_slider: HSlider = $CanvasLayer/Price_Container/Price_Slider
@onready var slab_options: OptionButton = $CanvasLayer/Slab_Container/Slab_Options
@onready var custom_slab: LineEdit = $CanvasLayer/Slab_Container/Custom_Slab
@onready var custom_slider: HSlider = $CanvasLayer/Slab_Container/Custom_Slider

@onready var inclusive_btn: CheckButton = $CanvasLayer/Inclusive_Btn
@onready var calculate_btn: Button = $CanvasLayer/Calculate_Btn
@onready var blur_window: Panel = $CanvasLayer/Blur_Window
@onready var result_window: Panel = $CanvasLayer/Result_Window
@onready var history_window: Panel = $CanvasLayer/History_Window
@onready var history_timer_2: Timer = $History_Timer2

@onready var pp_value: RichTextLabel = $CanvasLayer/Result_Window/ScrollContainer/CenterContainer/Breakdown_C/PP_Value
@onready var ga_value: RichTextLabel = $CanvasLayer/Result_Window/ScrollContainer/CenterContainer/Breakdown_C/GA_Value
@onready var gt_value: RichTextLabel = $CanvasLayer/Result_Window/ScrollContainer/CenterContainer/Breakdown_C/GT_Value
@onready var ta_value: RichTextLabel = $CanvasLayer/Result_Window/ScrollContainer/CenterContainer/Breakdown_C/TA_Value

@onready var chart: ProgressBar = $CanvasLayer/Result_Window/Chart_GUI/Chart
@onready var av: RichTextLabel = $CanvasLayer/Result_Window/Chart_GUI/AV
@onready var iv: RichTextLabel = $CanvasLayer/Result_Window/Chart_GUI/IV
@onready var gstL: RichTextLabel = $CanvasLayer/Result_Window/Chart_GUI/ScrollContainer/CenterContainer/GST_Loss


@onready var animations: AnimationPlayer = $Animations
@onready var anim_timer: Timer = $Anim_Timer
@onready var loading_timer: Timer = $Loading_Timer

#Variables
var isLoaded: bool = false

var calc_gst: float
var product_p: float
var gst_slab: float

var isCustomSlab: bool = false
var isDraggingPrice: bool = false
var isDraggingCS: bool = false
var fromHistory: bool = false

func _ready() -> void:
	SaveLoad.getCalculation.connect(_on_history_view_btn_pressed)
	
	disable(blur_window)
	disable(result_window)
	disable(custom_slab)
	disable(custom_slider)
	enable(loading_animations)
	enable(loading)
	animations.play("Loading")
	loading_timer.start()

func _process(delta: float) -> void:
	if isDraggingPrice:
		price.text = str(price_slider.value)
	elif isDraggingCS:
		custom_slab.text = str(custom_slider.value)
		
	if isCustomSlab:
		if custom_slab.text == "":
			calculate_btn.disabled = true
		else:
			calculate_btn.disabled = false
	else:
		calculate_btn.disabled = false

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


func enable(element: Variant) -> void:
	element.visible = true
	
func disable(element: Variant) -> void:
	element.visible = false
	
func calculateGST(amount: float,slab: float,btn: bool) -> void:
	if btn:
		#Calculate Inclusive GST
		product_p = snapped((amount*100/(100+slab)),0.001)
		calc_gst = snapped(amount - product_p,0.001)
		gt_value.text = "Inclusive"
	else:
		#Calculate Exclusive GST
		calc_gst = snapped((slab/100*amount),0.001)
		gt_value.text = "Exclusive"

func setResult() -> void:
	pp_value.text = str(product_p)
	ga_value.text = str(calc_gst)
	ta_value.text = str(float(pp_value.text)+float(ga_value.text))
	
	var tax: float = snapped(float(ga_value.text)/float(pp_value.text)*100,0.1)
	chart.value = tax
	av.text = str(100.0-tax) + "%"
	iv.text = str(tax) + "%"
	gstL.text = iv.text
	
	if tax<100.0:
		enable(av)
		enable(iv)
	else:
		enable(gstL)
	
	
	enable(blur_window)
	enable(result_window)
	disable(main_menu_btn)
	fixAnimation()
	
	if fromHistory:
		animations.play("history_down")
		history_timer_2.start()
	else:
		animations.play("open_close_result_menu")

func getResult(amount_f: String,percentage_f: String,btn: bool) -> void:
	gst_slab = float(percentage_f)
	product_p = float(amount_f)
	disable(av)
	disable(iv)
	disable(gstL)
	calculateGST(product_p,gst_slab,btn)
	setResult()

func _on_calculate_btn_pressed() -> void:
	getResult(price.text, custom_slab.text,inclusive_btn.button_pressed)

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

func _on_slab_options_item_selected(index: int) -> void:
	if (index == 4):
		isCustomSlab = true
		custom_slab.text = ""
		enable(custom_slab)
		enable(custom_slider)
	else:
		isCustomSlab = false
		custom_slab.text = str(slab_options.get_item_id(index))
		disable(custom_slab)
		disable(custom_slider)


func _on_loading_timer_timeout() -> void:
	if !isLoaded:
		disable(loading_animations)
		disable(loading)
		isLoaded = true
	else:
		get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")


func _on_main_menu_btn_pressed() -> void:
	loadMainMenu()


func _on_price_editing_toggled(toggled_on: bool) -> void:
	if float(price.text)<1.0:
		price.text = "1.0"


func _on_price_text_changed(new_text: String) -> void:
	price_slider.value = float(new_text)


func _on_price_slider_drag_started() -> void:
	isDraggingPrice = true


func _on_price_slider_drag_ended(value_changed: bool) -> void:
	isDraggingPrice = false


func _on_custom_slab_editing_toggled(toggled_on: bool) -> void:
	if float(custom_slab.text)<0.25:
		custom_slab.text = ""


func _on_custom_slab_text_changed(new_text: String) -> void:
	custom_slider.value = float(new_text)


func _on_custom_slider_drag_started() -> void:
	isDraggingCS = true


func _on_custom_slider_drag_ended(value_changed: bool) -> void:
	isDraggingCS = false

func _on_history_view_btn_pressed(amount,percentage,years,roipp,btnChecked):
	#print(amount," ",percentage," ",btnChecked)
	fromHistory = true
	getResult(amount,percentage,btnChecked)


func _on_history_btn_pressed() -> void:
	fixAnimation()


func _on_history_timer_2_timeout() -> void:
	disable(history_window)
