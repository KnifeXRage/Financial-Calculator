extends Control

@onready var loading_animations: Control = $CanvasLayer/Loading_Animations
@onready var mm_loading: Panel = $CanvasLayer/Loading_Animations/MM_Loading
@onready var animations: AnimationPlayer = $Animations
@onready var loading_timer: Timer = $Loading_Timer
@onready var loading: ColorRect = $CanvasLayer/Loading_Animations/Loading

var isLoaded: bool = false

func _ready() -> void:
	enable(loading_animations)
	enable(loading)
	loading_timer.start()
	animations.play("Loading")

func enable(element: Variant) -> void:
	element.visible = true
	
func disable(element: Variant) -> void:
	element.visible = false

func _on_main_menu_btn_pressed() -> void:
	enable(loading_animations)
	enable(loading)
	animations.play_backwards("Loading")
	loading_timer.start()


func _on_loading_timer_timeout() -> void:
	if !isLoaded:
		disable(loading_animations)
		disable(loading)
		isLoaded = true
	else:
		get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
