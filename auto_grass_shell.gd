@tool
extends MeshInstance3D

@export
var height: float = 0.2
@export
var shell_count: int = 16


# Called when the node enters the scene tree for the first time.
func _ready():
	self.set_meta("_edit_group_", true)
	
	for obj in get_children():
		remove_child(obj)
		obj.queue_free()
	
	for i in range(shell_count):
		var height_ratio := float(i) / shell_count
		
		var new_mesh := MeshInstance3D.new()
		new_mesh.mesh = self.mesh

		new_mesh.transform.origin.y += height_ratio * height
		new_mesh.set_instance_shader_parameter("height", height_ratio)
		
		add_child(new_mesh)
		new_mesh.set_owner(get_tree().edited_scene_root)
