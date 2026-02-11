extends Label

var update_interval := 0.5
var timer := 0.0

func _process(delta: float) -> void:
	timer += delta
	if timer >= update_interval:
		text = "FPS: %d" % Engine.get_frames_per_second()
		timer = 0.0
