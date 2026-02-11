extends AnimatableBody3D

@export var  目的地: Vector3
@export var  间隔: float=1.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var 绑定=create_tween()
	绑定.set_loops()
	绑定.tween_property(self,"global_position",global_position+目的地,间隔)
	绑定.tween_property(self,"global_position",global_position,间隔)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
