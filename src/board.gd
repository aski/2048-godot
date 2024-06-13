@tool
extends Node2D

enum Direction { UP, DOWN, LEFT, RIGHT }

const PLACEHOLDER_SCENE = preload("res://src/placeholder.tscn")
const TILE_SCENE = preload("res://src/tile.tscn")

const NEW_TILE_ANIMATION_TIME: float = 0.25
const MOVE_ANIMATION_TIME: float = 0.25

const GRID_SIZE = 4
const TILE_SPACING = 140
const TILE_OFFSET = 64

signal score_reset
signal score_increased
signal game_finished

var active: bool = true
var game_over: bool = false

var tile_positions: Array[Vector2]
var tiles: Array[Tile]

func _ready() -> void:
	tile_positions = generate_tile_positions()
	spawn_placeholders(tile_positions)
	tiles = []
	tiles.resize(GRID_SIZE * GRID_SIZE)
	reset_game()

func _input(event: InputEvent) -> void:
	if not active or game_over:
		return
	elif event.is_action_pressed("up"):
		step_game(Direction.UP)
	elif event.is_action_pressed("down"):
		step_game(Direction.DOWN)
	elif event.is_action_pressed("left"):
		step_game(Direction.LEFT)
	elif event.is_action_pressed("right"):
		step_game(Direction.RIGHT)

func generate_tile_positions() -> Array[Vector2]:
	var positions: Array[Vector2] = []
	positions.resize(GRID_SIZE * GRID_SIZE)
	for y in GRID_SIZE:
		for x in GRID_SIZE:
			var grid_position = Vector2(TILE_OFFSET, TILE_OFFSET) + Vector2(x * TILE_SPACING, y * TILE_SPACING)
			positions[y * GRID_SIZE + x] = grid_position
	return positions

func reset_game():
	for tile in tiles:
		if tile != null:
			tile.queue_free()
	spawn_new_tile()
	spawn_new_tile()
	emit_signal("score_reset")
	game_over = false
	active = true

func get_empty_tile_position_indices() -> Array:
	var empty_indices = []
	for index in range(tiles.size()):
		if tiles[index] == null:
			empty_indices.append(index)
	return empty_indices

func spawn_placeholders(spawn_positions: Array[Vector2]) -> void:
	for position in spawn_positions:
		var placeholder = PLACEHOLDER_SCENE.instantiate()
		placeholder.position = position
		add_child(placeholder)

func spawn_new_tile() -> void:
	var index = get_empty_tile_position_indices().pick_random()
	if index == null:
		return
	var tile = TILE_SCENE.instantiate()
	tiles[index] = tile
	tile.position = $TileSpawnPoint.position
	add_child(tile)
	tile.value = 4 if randf() > 0.9 else 2
	var tween = create_tween()
	tween.tween_property(tile, "position", tile_positions[index], NEW_TILE_ANIMATION_TIME)

func step_game(direction: Direction) -> void:
	slide_tiles(direction)
	var changed = sync_tile_positions()
	if changed: 
		spawn_new_tile()
	check_game_over()

func slide_tiles(direction: Direction) -> void:
	for slice_index in range(GRID_SIZE):
		var indices = slice(slice_index, direction)
		var selected_tiles = tiles_at(indices)
		for index in range(selected_tiles.size()):
			if selected_tiles.size() > index + 1 and selected_tiles[index].value == selected_tiles[index + 1].value:
				selected_tiles[index + 1].value *= 2
				emit_signal("score_increased", selected_tiles[index + 1].value)
				selected_tiles[index].destroy()
				selected_tiles.remove_at(index)
		for n in range(indices.size()):
			var index = indices[n]
			tiles[index] = selected_tiles[n] if selected_tiles.size() > n else null

func slice(index: int, direction: Direction) -> Array:
	if index < 0 or index >= GRID_SIZE:
		return []
	elif direction == Direction.UP:
		return range(index, GRID_SIZE * GRID_SIZE + index, GRID_SIZE)
	elif direction == Direction.DOWN:
		return range(GRID_SIZE * GRID_SIZE - index - 1, -1, -GRID_SIZE)
	elif direction == Direction.LEFT:
		return range(index * GRID_SIZE, index * GRID_SIZE + GRID_SIZE)
	elif direction == Direction.RIGHT:
		return range(index * GRID_SIZE + GRID_SIZE - 1, index * GRID_SIZE - 1, -1)
	else:
		return []

func tiles_at(indices: Array) -> Array:
	var result = []
	for index in indices:
		var tile = tiles[index]
		if tile != null:
			result.append(tile)
	return result
	
func sync_tile_positions() -> bool:
	var changed: bool = false
	for index in range(tiles.size()):
		var tile = tiles[index]
		if tile == null:
			continue
		var new_position = tile_positions[index]
		if tile.position != new_position:
			var tween = create_tween()
			tween.tween_property(tile, "position", new_position, MOVE_ANIMATION_TIME)
			changed = true
	return changed
	
func check_game_over() -> void:
	if get_empty_tile_position_indices().size() > 0:
		return
	for column_index in range(GRID_SIZE):
		var column = tiles_at(slice(column_index, Direction.DOWN))
		for index in range(0, column.size() - 1):
			if column[index].value == column[index + 1].value:
				return
	for row_index in range(GRID_SIZE):
		var row = tiles_at(slice(row_index, Direction.RIGHT))
		for index in range(row.size() - 1):
			if row[index].value == row[index + 1].value:
				return
	game_over = true
	emit_signal("game_finished")
