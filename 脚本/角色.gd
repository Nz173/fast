extends RigidBody3D

##火箭的推力
@export_range(750,1500,50) var 推力:=1000.0
@export_range(50,300,10) var 扭矩:=100.0

var 正在过渡:bool=false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

@onready var 爆炸声: AudioStreamPlayer = $爆炸声
@onready var 胜利: AudioStreamPlayer = $胜利
@onready var 火箭引擎声: AudioStreamPlayer3D = $火箭引擎声
@onready var 发射粒子簇: GPUParticles3D = $发射粒子簇
@onready var 发射粒子簇右: GPUParticles3D = $发射粒子簇右
@onready var 发射粒子簇左: GPUParticles3D = $发射粒子簇左
@onready var 爆炸粒子簇: GPUParticles3D = $爆炸粒子簇
@onready var 胜利粒子簇: GPUParticles3D = $胜利粒子簇

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("发射"):
		#position.y+=delta
		#apply_central_force(Vector3.UP*delta*1000.0)
		apply_central_force(basis.y*delta*推力)
		if not 发射粒子簇.emitting:
			发射粒子簇.emitting=true
		if not 火箭引擎声.playing:
			火箭引擎声.play()
	if Input.is_action_just_released("发射"):
		#火箭引擎声.stream_paused=true
		火箭引擎声.stop()
		发射粒子簇.emitting=false
	if Input.is_action_pressed("左旋转"):
		apply_torque(Vector3(0.0,0.0,扭矩*delta))
		if not 发射粒子簇右.emitting:
			发射粒子簇右.emitting=true
	else:
		发射粒子簇右.emitting=false
		#rotate_z(delta)
		
		
		
	if Input.is_action_pressed("右旋转"):
		apply_torque(Vector3(0.0,0.0,-扭矩*delta))
		#apply_torque(Vector3(100.0*delta,0.0,0.0))
		if not 发射粒子簇左.emitting:
			发射粒子簇左.emitting=true
	else:
		发射粒子簇左.emitting=false
	


func _on_body_entered(body: Node) -> void:
	if 正在过渡==false:
	#if body.name=="降落处":
		print(body)
		
		if "危险" in body.get_groups():
			摧毁()
		if "目标" in body.get_groups():
			完成关卡(body.file_path)
func 摧毁()->void:
	print("摧毁！")
	爆炸声.play()
	if not 爆炸粒子簇.emitting:
		爆炸粒子簇.emitting=true
	set_process(false)
	正在过渡=true
	var 绑定=create_tween()
	绑定.tween_interval(2.0)
	绑定.tween_callback(get_tree().reload_current_scene)
	
	
	
func 完成关卡(下一关:String)->void:
	print("完成关卡")
	if not 胜利.playing:
		胜利.play()
	if not 胜利粒子簇.emitting:
		胜利粒子簇.emitting=true
	#get_tree().quit()
	var 绑定=create_tween()
	绑定.tween_interval(1.0)
	#get_tree().call_deferred("change_scene_to_file",下一关)
	#绑定.tween_callback(get_tree().change_scene_to_file.bind(下一关))
	绑定.tween_callback(get_tree().call_deferred.bind("change_scene_to_file", 下一关))
