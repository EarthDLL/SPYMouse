extends Resource
class_name Achievement

enum TYPE {
	SCORE = 1,
	PATHS = 2,
	TIME = 3,
	FOUNDED = 4,
	LITTLECHEESE = 5,
	CATCRASH = 6,
}
#全部奶酪碎屑，收集够为0，不够为1

@export var type : TYPE = TYPE.SCORE
@export var value : float = 0.0

func get_description() -> String:
	match type:
		TYPE.SCORE:
			return str("得分" , value)
		TYPE.PATHS:
			return str("仅" , value , "条路径")
		TYPE.TIME:
			return str(floori(value/60) , ":" , int(value)%60 , "内")
		TYPE.FOUNDED:
			return "不要被发现了"
		TYPE.LITTLECHEESE:
			return "全部奶酪碎屑"
		TYPE.CATCRASH:
			return str(value , "只猫撞墙")
	return "未知成就"

func commit(data : Data) -> bool:
	match type:
		TYPE.SCORE:
			return data.score >= value
		TYPE.PATHS:
			return data.total_paths <= value
		TYPE.TIME:
			return data.get_used_time() <= value
		TYPE.FOUNDED:
			return data.found_time < 1
		TYPE.LITTLECHEESE:
			if Game.current_level.collected_little_cheese == Game.current_level.little_cheese_count:
				return true
		TYPE.CATCRASH:
			return data.stupid_cat_crash_count >= value
	return false
