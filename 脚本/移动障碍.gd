extends AnimatableBody3D

## 移动障碍 - 在起点和目的地之间来回移动

#region 导出变量
@export var destination: Vector3 = Vector3.ZERO  ## 相对当前位置的移动目标
@export var duration: float = 1.0                ## 单次移动持续时间（秒）
@export var wait_time: float = 0.0               ## 到达后等待时间（秒）
@export var ease_type: Tween.EaseType = Tween.EASE_IN_OUT  ## 缓动类型
@export var trans_type: Tween.TransitionType = Tween.TRANS_LINEAR  ## 过渡类型
#endregion

var _initial_position: Vector3
var _tween: Tween

func _ready() -> void:
	_initial_position = global_position
	_start_movement()

func _start_movement() -> void:
	## 停止现有的 tween
	if _tween and _tween.is_valid():
		_tween.kill()
	
	_tween = create_tween()
	_tween.set_loops()
	_tween.set_ease(ease_type)
	_tween.set_trans(trans_type)
	
	## 移动到目的地
	if wait_time > 0.0:
		_tween.tween_interval(wait_time)
	_tween.tween_property(self, "global_position", _initial_position + destination, duration)
	
	## 返回起点
	if wait_time > 0.0:
		_tween.tween_interval(wait_time)
	_tween.tween_property(self, "global_position", _initial_position, duration)

func _exit_tree() -> void:
	## 清理 tween
	if _tween and _tween.is_valid():
		_tween.kill()
