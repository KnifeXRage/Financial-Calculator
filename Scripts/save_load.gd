extends Node

signal getCalculation(amount: String,percentage: String,years: String,roipp: int, btnChecked: bool)

var historyEnabled: bool
var starting: bool = true
var exit: bool = false

var SAVE_LOCS: Dictionary = {
	"EMI" = "user://emi_history.dat",
	"FD" = "user://fd_history.dat",
	"SIP" = "user://sip_history.dat",
	"GST" = "user://gst_history.dat",
	"Settings" = "user://settings.dat"
}

func save_data(data: Dictionary,type: String) -> void:
	var file = FileAccess.open(SAVE_LOCS[type],FileAccess.WRITE)
	file.store_var(data.duplicate())
	file.close()
	print("\nSaved: ",SAVE_LOCS[type])
	print(data)

func load_data(type: String) -> Dictionary:
	if FileAccess.file_exists(SAVE_LOCS[type]):
		var file = FileAccess.open(SAVE_LOCS[type],FileAccess.READ)
		var loaded_data: Dictionary = file.get_var()
		file.close()
		print("\nLoaded: ",SAVE_LOCS[type])
		print(loaded_data)
		return loaded_data
	return {}
	
func delete_data(type: String) -> void:
	if FileAccess.file_exists(SAVE_LOCS[type]):
		DirAccess.remove_absolute(SAVE_LOCS[type])
		print("\nCleared: ",SAVE_LOCS[type])
