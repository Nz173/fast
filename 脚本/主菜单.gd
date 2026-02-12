extends Control

## 主菜单 - 游戏入口界面

#region 导出变量
@export_file("*.tscn") var game_scene_path: String = "uid://4xu4uo8681cc"  ## 首关场景路径（使用 UID）
@export var fade_in_duration: float = 1.0  ## 淡入动画时长
#endregion

#region 节点引用
@onready var vbox_container: VBoxContainer = %VBoxContainer
@onready var start_button: Button = %StartButton
@onready var quit_button: Button = %QuitButton
#endregion

func _ready() -> void:
	## 初始化按钮焦点
	if start_button:
		start_button.grab_focus()
	
	## 播放入场动画
	_play_entrance_animation()

func _play_entrance_animation() -> void:
	if not vbox_container:
		return
	
	vbox_container.modulate.a = 0.0
	
	var tween: Tween = create_tween()
	tween.tween_property(vbox_container, "modulate:a", 1.0, fade_in_duration)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_CUBIC)

func _on_start_button_pressed() -> void:
	## 切换场景前禁用按钮防止重复点击
	if start_button:
		start_button.disabled = true
	
	print("开始游戏，加载场景: ", game_scene_path)
	
	var result: Error = get_tree().change_scene_to_file(game_scene_path)
	if result != OK:
		printerr("场景切换失败: ", result)
		if start_button:
			start_button.disabled = false

func _on_quit_button_pressed() -> void:
	## 淡出动画后退出
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(_do_quit)

func _do_quit() -> void:
	print("退出游戏")
	get_tree().quit()

func _input(event: InputEvent) -> void:
	## 支持手柄和键盘导航
	if event.is_action_pressed("ui_cancel"):
		_on_quit_button_pressed()
