extends RigidBody3D

## 火箭角色控制器 - 处理推进、旋转、碰撞和关卡完成逻辑

#region 导出变量
@export_range(750.0, 1500.0, 50.0) var thrust_power: float = 1000.0  ## 火箭推力
@export_range(50.0, 300.0, 10.0) var torque_power: float = 100.0     ## 旋转扭矩
#endregion

#region 内部状态
var is_transitioning: bool = false  ## 是否正在过渡（防止重复触发）
var thrust_input: float = 0.0       ## 推力输入值 (0-1)
var rotation_input: float = 0.0     ## 旋转输入值 (-1 to 1)
#endregion

#region 预加载资源
const EXPLOSION_SOUND: AudioStream = preload("res://音频/15.1 15_PB_G3D - Audio Files/15_PB_G3D - Audio Files/SFX - Death Explosion.ogg")
const VICTORY_SOUND: AudioStream = preload("res://音频/15.1 15_PB_G3D - Audio Files/15_PB_G3D - Audio Files/SFX - Success.ogg")
const ENGINE_SOUND: AudioStream = preload("res://音频/16_PB_G3D - Audio File/SFX - Main engine thrust.ogg")
#endregion

#region 节点引用
@onready var explosion_sound_player: AudioStreamPlayer = $爆炸声
@onready var victory_sound_player: AudioStreamPlayer = $胜利
@onready var engine_sound_player: AudioStreamPlayer3D = $火箭引擎声
@onready var thrust_particles: GPUParticles3D = $发射粒子簇
@onready var right_particles: GPUParticles3D = $发射粒子簇右
@onready var left_particles: GPUParticles3D = $发射粒子簇左
@onready var explosion_particles: GPUParticles3D = $爆炸粒子簇
@onready var victory_particles: GPUParticles3D = $胜利粒子簇
#endregion

func _ready() -> void:
	## 预加载音频资源
	explosion_sound_player.stream = EXPLOSION_SOUND
	victory_sound_player.stream = VICTORY_SOUND
	engine_sound_player.stream = ENGINE_SOUND

func _process(_delta: float) -> void:
	## 只在_process中处理输入检测（非物理操作）
	thrust_input = Input.get_action_strength("发射")
	rotation_input = Input.get_action_strength("左旋转") - Input.get_action_strength("右旋转")
	
	## 更新视觉效果（粒子、音频）
	_update_visual_effects()

func _physics_process(delta: float) -> void:
	## 物理操作必须在_physics_process中执行
	if is_transitioning:
		return
	
	## 应用推力
	if thrust_input > 0.0:
		apply_central_force(basis.y * thrust_input * delta * thrust_power)
	
	## 应用旋转
	if rotation_input != 0.0:
		apply_torque(Vector3(0.0, 0.0, rotation_input * torque_power * delta))

func _update_visual_effects() -> void:
	## 更新推进粒子效果
	if is_transitioning:
		thrust_particles.emitting = false
		right_particles.emitting = false
		left_particles.emitting = false
		engine_sound_player.stop()
		return
	
	## 主推进器
	var should_emit_thrust: bool = thrust_input > 0.0 and not is_transitioning
	thrust_particles.emitting = should_emit_thrust
	
	## 旋转推进器
	right_particles.emitting = rotation_input > 0.0 and not is_transitioning
	left_particles.emitting = rotation_input < 0.0 and not is_transitioning
	
	## 引擎音效
	if should_emit_thrust and not engine_sound_player.playing:
		engine_sound_player.play()
	elif not should_emit_thrust and engine_sound_player.playing:
		engine_sound_player.stop()

func _on_body_entered(body: Node) -> void:
	if is_transitioning:
		return
	
	print("碰撞对象: ", body.name)
	
	## 检查碰撞对象的组别
	if body.is_in_group("危险"):
		_destroy()
	elif body.is_in_group("目标"):
		var next_level: String = body.get("file_path")
		if next_level:
			_complete_level(next_level)

func _destroy() -> void:
	print("火箭摧毁!")
	is_transitioning = true
	
	## 播放爆炸效果
	explosion_sound_player.play()
	explosion_particles.emitting = true
	
	## 停止处理输入
	set_process(false)
	set_physics_process(false)
	
	## 2秒后重载关卡
	var tween: Tween = create_tween()
	tween.tween_interval(2.0)
	tween.tween_callback(get_tree().reload_current_scene)

func _complete_level(next_level: String) -> void:
	print("关卡完成!")
	is_transitioning = true
	
	## 播放胜利效果
	if not victory_sound_player.playing:
		victory_sound_player.play()
	if not victory_particles.emitting:
		victory_particles.emitting = true
	
	## 1秒后切换关卡
	var tween: Tween = create_tween()
	tween.tween_interval(1.0)
	tween.tween_callback(get_tree().call_deferred.bind("change_scene_to_file", next_level))
