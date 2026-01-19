class_name LevelConfig
extends RefCounted

## Configuração de um level específico.
## Define posições fixas para obstáculos, estrelas e objetivo.

# Posições X dos buracos pretos (ordem de spawn)
var black_hole_positions: Array = []

# Posições X das estrelas (ordem de spawn)
var star_positions: Array = []

# Posição X do objetivo (buraco amarelo)
var goal_position_x: float = 360.0

# Velocidade dos obstáculos neste level
var obstacle_speed: float = 120.0

# Intervalo entre spawns (segundos)
var spawn_interval: float = 1.2


static func create_level_1() -> LevelConfig:
	var config = LevelConfig.new()
	# Level 1: Introdutório - tudo centralizado
	# 3 estrelas empilhadas, 1 buraco preto no centro, objetivo no centro
	config.star_positions = [360.0, 360.0, 360.0]  # 3 estrelas no centro
	config.black_hole_positions = [360.0]  # 1 buraco preto no centro
	config.goal_position_x = 360.0  # Objetivo no centro
	config.obstacle_speed = 100.0  # Velocidade lenta
	config.spawn_interval = 1.0  # Intervalo confortável
	return config


static func create_level_2() -> LevelConfig:
	var config = LevelConfig.new()
	# Level 2: Introduz variação lateral
	config.star_positions = [250.0, 360.0, 470.0]  # Estrelas em diagonal
	config.black_hole_positions = [360.0, 360.0]  # 2 buracos no centro
	config.goal_position_x = 360.0
	config.obstacle_speed = 110.0
	config.spawn_interval = 1.0
	return config


static func create_level_3() -> LevelConfig:
	var config = LevelConfig.new()
	# Level 3: Mais obstáculos
	config.star_positions = [200.0, 360.0, 520.0]
	config.black_hole_positions = [280.0, 440.0, 360.0]  # 3 buracos alternados
	config.goal_position_x = 360.0
	config.obstacle_speed = 120.0
	config.spawn_interval = 0.9
	return config


static func get_config_for_level(level: int) -> LevelConfig:
	match level:
		1:
			return create_level_1()
		2:
			return create_level_2()
		3:
			return create_level_3()
		_:
			# Para levels não definidos, usar configuração genérica
			return _create_generic_level(level)


static func _create_generic_level(level: int) -> LevelConfig:
	var config = LevelConfig.new()
	var center_x: float = 360.0
	
	# Aumenta quantidade e dificuldade progressivamente
	var num_stars: int = mini(3 + level, 8)
	var num_holes: int = mini(1 + level, 6)
	
	# Distribui estrelas
	config.star_positions = []
	for i in range(num_stars):
		var offset: float = (i - num_stars / 2.0) * 80.0
		config.star_positions.append(clampf(center_x + offset, 150.0, 570.0))
	
	# Distribui buracos pretos
	config.black_hole_positions = []
	for i in range(num_holes):
		var offset: float = (i - num_holes / 2.0) * 100.0
		config.black_hole_positions.append(clampf(center_x + offset, 150.0, 570.0))
	
	config.goal_position_x = center_x
	config.obstacle_speed = 100.0 + level * 15.0
	config.spawn_interval = maxf(1.2 - level * 0.05, 0.5)
	
	return config
