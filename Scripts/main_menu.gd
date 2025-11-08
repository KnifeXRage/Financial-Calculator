extends Control

@onready var loading_animations: Control = $CanvasLayer/Loading_Animations
@onready var loading: ColorRect = $CanvasLayer/Loading_Animations/Loading
@onready var loading_timer: Timer = $CanvasLayer/Loading_Timer

@onready var opening_animations: ColorRect = $CanvasLayer/Opening_Animations
@onready var emi_oa: Panel = $CanvasLayer/Opening_Animations/Handle/EMI_OA
@onready var fd_oa: Panel = $CanvasLayer/Opening_Animations/Handle/FD_OA
@onready var sip_oa: Panel = $CanvasLayer/Opening_Animations/Handle/SIP_OA
@onready var gst_oa: Panel = $CanvasLayer/Opening_Animations/Handle/GST_OA

@onready var animations: AnimationPlayer = $CanvasLayer/Animations
@onready var animation_timer: Timer = $CanvasLayer/Animation_Timer
@onready var settings_menu: Panel = $CanvasLayer/Settings_Menu

var openCalcVar: int

func _ready() -> void:
	openCalcVar = 0
	opening_animations.visible = false
	emi_oa.visible = false
	fd_oa.visible = false
	sip_oa.visible = false
	gst_oa.visible = false
	settings_menu.visible = false
	
	if SaveLoad.starting == true:
		var screenY = get_viewport_rect().size.y - 315
		loading.size.y = screenY
		loading.position.y = 315
		SaveLoad.starting = false
	else:
		loading.size.y = get_viewport_rect().get_center().y*2
		loading.position.y = 0
	
	loading_animations.visible = true
	loading.visible = true
	animations.play("Loading")
	

func changeLoc(anim: String) -> void:
	var lenX = (get_viewport_rect().get_center().x)
	var lenY = (get_viewport_rect().get_center().y)
	
	animations.get_animation(anim).track_set_key_value(0,1,[lenX*2,-0.25, 0.0, 0.25, 0.0])
	animations.get_animation(anim).track_set_key_value(1,1,[lenY*2,-0.25, 0.0, 0.25, 0.0])
	animations.get_animation(anim).track_set_key_value(2,1,[-(lenX-20),-0.25, 0.0, 0.25, 0.0])
	animations.get_animation(anim).track_set_key_value(3,1,[-(lenY-20),-0.25, 0.0, 0.25, 0.0])

func openCalc(calc_val: int, oa_val: bool,anim: String,ele: Panel) -> void:
	openCalcVar = calc_val
	opening_animations.visible = oa_val
	ele.visible = oa_val
	ele.get_parent().visible = oa_val
	animations.play(anim)
	animation_timer.start()

func _on_emi_calc_btn_pressed() -> void:
	changeLoc("EMI_OA")
	openCalc(1,true,"EMI_OA",emi_oa)


func _on_fd_calc_btn_pressed() -> void:
	changeLoc("FD_OA")
	openCalc(2,true,"FD_OA",fd_oa)

func _on_sip_calc_btn_pressed() -> void:
	changeLoc("SIP_OA")
	openCalc(3,true,"SIP_OA",sip_oa)


func _on_gst_calc_btn_pressed() -> void:
	changeLoc("GST_OA")
	openCalc(4,true,"GST_OA",gst_oa)


func _on_animation_timer_timeout() -> void:
	if(openCalcVar == 1):
		get_tree().change_scene_to_file("res://Scenes/emi_calculator.tscn")
	elif(openCalcVar == 2):
		get_tree().change_scene_to_file("res://Scenes/fd_calculator.tscn")
	elif(openCalcVar == 3):
		get_tree().change_scene_to_file("res://Scenes/sip_calculator.tscn")
	elif(openCalcVar == 4):
		get_tree().change_scene_to_file("res://Scenes/gst_calculator.tscn")


func _on_exit_btn_pressed() -> void:
	var screenY = get_viewport_rect().size.y - 315
	loading.size.y = screenY
	loading.position.y = 315
	loading_animations.visible = true
	loading.visible = true
	animations.play_backwards("Loading")
	SaveLoad.exit = true
	loading_timer.start()

func _on_loading_timer_timeout() -> void:
	loading_animations.visible = false
	loading.visible = false
	
	if SaveLoad.exit:
		get_tree().change_scene_to_file("res://Scenes/splash_screen.tscn")
