extends CanvasLayer

## 启动画面 - 游戏启动时显示，预加载资源并进入主菜单

signal loading_completed  ## 加载完成信号

#region 导出变量
@export_file("*.tscn") var next_scene_path: String = "uid://b26l5qhxyqmvt"  ## 主菜单场景路径（使用 UID）
@export var preload_resources: Array[String] = []  ## 需要预加载的资源路径列表
@export var minimum_display_time: float = 1.5      ## 最少显示时间（秒）
#endregion

#region 内部状态
var _progress: float = 0.0
var _is_loading: bool = false
var _loading_start_time: float = 0.0
var _progress_array: Array = []
#endregion

#region 节点引用
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var loading_label: Label = %LoadingLabel
@onready var spinner: ColorRect = %LoadingSpinner
@onready var vbox_container: VBoxContainer = %VBoxContainer
#endregion

func _ready() -> void:
	## 播放 UI 入场动画
	_play_entrance_animation()
	
	## 延迟开始加载，确保 UI 已准备好
	if next_scene_path != "":
		call_deferred("_start_loading", next_scene_path)
	else:
		_update_status("错误: 未设置目标场景", true)

func _play_entrance_animation() -> void:
	if not vbox_container:
		return
	
	vbox_container.modulate.a = 0.0
	vbox_container.position.y += 50.0
	
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(vbox_container, "modulate:a", 1.0, 0.8)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(vbox_container, "position:y", vbox_container.position.y - 50.0, 0.8)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_BACK)

func _start_loading(path: String) -> void:
	print("准备加载场景: ", path)
	_loading_start_time = Time.get_ticks_msec() / 1000.0
	
	## 验证路径
	if not ResourceLoader.exists(path):
		_update_status("文件不存在:\n" + path, true)
		return
	
	## 预加载额外资源
	for resource_path in preload_resources:
		if ResourceLoader.exists(resource_path):
			ResourceLoader.load_threaded_request(resource_path)
			print("预加载资源: ", resource_path)
	
	## 开始加载主场景
	var err: Error = ResourceLoader.load_threaded_request(path)
	if err == OK:
		_is_loading = true
		print("加载请求已发送")
	else:
		_update_status("加载启动失败: " + str(err), true)

func _process(delta: float) -> void:
	if not _is_loading:
		return
	
	## 旋转加载圈
	if spinner:
		spinner.rotation_degrees += 180.0 * delta
	
	## 检查加载状态
	_process_loading_status(delta)

func _process_loading_status(delta: float) -> void:
	_progress_array.clear()
	var status: ResourceLoader.ThreadLoadStatus = ResourceLoader.load_threaded_get_status(
		next_scene_path, 
		_progress_array
	)
	
	match status:
		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_IN_PROGRESS:
			## 更新进度条
			var real_progress: float = _progress_array[0] * 100.0 if _progress_array.size() > 0 else 0.0
			progress_bar.value = move_toward(progress_bar.value, real_progress, delta * 50.0)
			_update_status("正在加载资源...")
			
		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
			## 加载完成
			progress_bar.value = 100.0
			_update_status("加载完成!")
			_is_loading = false
			
			## 确保满足最少显示时间
			var elapsed: float = (Time.get_ticks_msec() / 1000.0) - _loading_start_time
			var remaining: float = max(0.0, minimum_display_time - elapsed)
			
			await get_tree().create_timer(remaining + 0.2).timeout
			emit_signal("loading_completed")
			_change_scene()
			
		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_FAILED:
			_update_status("加载失败!", true)
			_is_loading = false
			
		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_INVALID_RESOURCE:
			_update_status("资源无效 (路径错误)", true)
			_is_loading = false

func _change_scene() -> void:
	var packed_scene: Resource = ResourceLoader.load_threaded_get(next_scene_path)
	if packed_scene and packed_scene is PackedScene:
		var result: Error = get_tree().change_scene_to_packed(packed_scene)
		if result != OK:
			_update_status("场景切换失败: " + str(result), true)
	else:
		_update_status("实例化场景失败", true)

func _update_status(message: String, is_error: bool = false) -> void:
	if loading_label:
		loading_label.text = message
		if is_error:
			loading_label.modulate = Color(1.0, 0.3, 0.3, 1.0)
	print("加载状态: ", message)
