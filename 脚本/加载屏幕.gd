extends CanvasLayer

## 加载屏幕控制器 - 显示加载进度和状态

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var loading_label: Label = $LoadingLabel
@onready var loading_spinner: TextureRect = $LoadingSpinner

var _rotation_speed: float = 180.0  ## 加载圈旋转速度（度/秒）

func _ready() -> void:
	## 初始化进度条
	progress_bar.value = 0.0
	progress_bar.min_value = 0.0
	progress_bar.max_value = 100.0
	
	## 设置加载文字
	loading_label.text = "正在加载..."
	loading_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func _process(delta: float) -> void:
	## 旋转加载圈
	if loading_spinner:
		loading_spinner.rotation_degrees += _rotation_speed * delta

## 更新加载进度
## [param value] 进度值 (0-100)
## [param status] 可选的状态文字
func update_progress(value: float, status: String = "") -> void:
	progress_bar.value = clampf(value, 0.0, 100.0)
	if not status.is_empty():
		loading_label.text = status

## 设置加载完成
func set_complete() -> void:
	progress_bar.value = 100.0
	loading_label.text = "加载完成!"

## 显示错误信息
## [param error_msg] 错误描述
func show_error(error_msg: String) -> void:
	loading_label.text = "加载失败: " + error_msg
	loading_label.modulate = Color(1.0, 0.3, 0.3, 1.0)
