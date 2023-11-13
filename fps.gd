extends Label


func _process(delta):
	var fps := Engine.get_frames_per_second()
	
	self.text = "FPS: %.1f; Time: %.2fms" % [
		fps,
		(1 / fps) * 1000
	]
