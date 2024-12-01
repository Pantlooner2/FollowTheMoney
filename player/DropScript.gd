extends Panel

func _can_drop_data(at_position, data):
	if data["item"] != null:
		if !data["item"].is_tool:
			return true
	return false

func _drop_data(at_position, data):
	data["inv"].drop(data["slot_index"])
