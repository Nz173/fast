extends Label

## FPS 显示器 - 使用 Timer 避免每帧计算

@export var update_interval: float = 0.5  ## 更新间隔（秒）

var _fps_timer: Timer
var _frame_count: int = 0
var _accumulated_time: float = 0.0

func _ready() -> void:
	## 创建并配置 Timer
	_fps_timer = Timer.new()
	_fps_timer.wait_time = update_interval
	_fps_timer.one_shot = false
	_fps_timer.timeout.connect(_on_fps_timer_timeout)
	add_child(_fps_timer)
	
	## 立即显示一次
	_update_fps_display()
	_fps_timer.start()

func _process(delta: float) -> void:
	## 累积帧数和时间用于计算平均 FPS
	_frame_count += 1
	_accumulated_time += delta

func _on_fps_timer_timeout() -> void:
	_update_fps_display()
	## 重置计数器
	_frame_count = 0
	_accumulated_time = 0.0

func _update_fps_display() -> void:
	## 使用 Engine.get_frames_per_second() 获取即时 FPS
	## 或使用平均 FPS: _frame_count / _accumulated_time
	var fps: int = Engine.get_frames_per_second()
	text = "FPS: %d" % fps
	
	## 根据 FPS 改变颜色
	if fps >= 60:
		modulate = Color(0.0, 1.0, 0.0, 1.0)  ## 绿色 - 良好
	elif fps >= 30:
		modulate = Color(1.0, 1.0, 0.0, 1.0)  ## 黄色 - 可接受
	else:
		modulate = Color(1.0, 0.0, 0.0, 1.0)  ## 红色 - 较差
