extends CSGBox3D

## 降落处 - 火箭着陆目标区域
## 当火箭着陆时，将触发关卡完成并加载下一关

#region 导出变量
@export_file("*.tscn") var next_level_path: String = ""  ## 下一关场景路径
@export var landing_tolerance: float = 5.0               ## 着陆速度容差
#endregion

func _ready() -> void:
	## 确保节点在"目标"组中
	if not is_in_group("目标"):
		add_to_group("目标")
	
	## 暴露 file_path 属性以保持向后兼容
	## 其他脚本通过 body.file_path 访问
	set_meta("file_path", next_level_path)

## 获取下一关路径（供其他脚本调用）
func get_file_path() -> String:
	return next_level_path

## 设置下一关路径
func set_file_path(path: String) -> void:
	next_level_path = path
	set_meta("file_path", path)
