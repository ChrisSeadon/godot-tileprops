@tool
extends EditorPlugin

const PROPS_FIELD_NAME = "Props"
const DEBOUNCE_INTERVAL = 0.2
var debounce_timers = {} #tilemap:timer
var registered_tilemaps = {} #tilemap:{known_tile_ids,known_source_ids}
var initial_scene_root = null

func _process(delta: float) -> void:
	#i hate this but i can't find a better way since scne_changed doesn't fire when the editor first loads
	if initial_scene_root != null:
		return
	initial_scene_root = EditorInterface.get_edited_scene_root()
	if initial_scene_root != null:
		_on_initial_scene_load()

func _enter_tree() -> void:
	scene_changed.connect(_on_scene_changed)
	registered_tilemaps.clear()
	debounce_timers.clear()

func _exit_tree() -> void:
	registered_tilemaps.clear()
	for timer in debounce_timers.values():
		timer.queue_free()
	debounce_timers.clear()

func _on_initial_scene_load():
	_on_scene_changed(initial_scene_root)

func _on_scene_changed(root):
	if root == null:
		return
	_connect_node_add_remove_signals(root)
	_register_tilemaps(root)
	
func _connect_node_add_remove_signals(root):
	if root == null or root.get_tree() == null:
		return
	if not root.get_tree().node_added.is_connected(_register_tilemaps):
		root.get_tree().node_added.connect(_register_tilemaps)
	if not root.get_tree().node_removed.is_connected(_deregister_tilemaps):
		root.get_tree().node_removed.connect(_deregister_tilemaps)
	
func _deregister_tilemaps(node):
	if registered_tilemaps.has(node):
		registered_tilemaps.erase(node)

func _register_tilemaps(node):
	if node is TileMapLayer:
		_register_tilemap(node)
	for child in node.get_children():
		_register_tilemaps(child)

func _register_tilemap(tilemap):
	if registered_tilemaps.has(tilemap):
		return
	if tilemap.tile_set != null:
		var register_callable = _register_tilemap.bind(tilemap)
		if tilemap.changed.is_connected(register_callable):
			tilemap.disconnect('changed',register_callable)
		var refresh_callable = _queue_refresh.bind(tilemap)
		if not (tilemap.tile_set.changed.is_connected(refresh_callable)):
			tilemap.tile_set.connect('changed',refresh_callable,CONNECT_DEFERRED)
			if tilemap.tile_set.get_source_count() > 0: #Immediately refresh non-empty tileset
				_queue_refresh(tilemap)
		registered_tilemaps[tilemap] = {"known_tile_ids":{},"known_source_tile_counts":{}}
	else:
		if not tilemap.changed.is_connected(_register_tilemap):
			var register_callable = _register_tilemap.bind(tilemap)
			tilemap.connect('changed',register_callable,CONNECT_DEFERRED)

func _queue_refresh(tilemap):
	if tilemap == null:
		return
	if debounce_timers.has(tilemap):
		debounce_timers[tilemap].stop()
	else:
		var timer = Timer.new()
		timer.one_shot = true
		timer.wait_time = DEBOUNCE_INTERVAL
		var refresh_callable = _refresh.bind(tilemap)
		timer.connect("timeout",refresh_callable)
		add_child(timer)
		debounce_timers[tilemap] = timer
	debounce_timers[tilemap].start()

func _refresh(tilemap):
	if tilemap == null or tilemap.tile_set == null or not tilemap.tile_set.has_custom_data_layer_by_name(PROPS_FIELD_NAME):
		return
	var current_source_tiles = {}
	var known_source_tile_counts = registered_tilemaps[tilemap]['known_source_tile_counts']
	var known_tile_ids = registered_tilemaps[tilemap]['known_tile_ids']
	for source_idx in tilemap.tile_set.get_source_count():
		var source_id = tilemap.tile_set.get_source_id(source_idx)
		var tile_source = tilemap.tile_set.get_source(source_id)
		var tile_count = tile_source.get_tiles_count()
		if known_source_tile_counts.has(source_id) and known_source_tile_counts[source_id] == tile_count:
			continue
		known_source_tile_counts[source_id] = tile_count
		for tile_idx in tile_count:
			var tile_id = tile_source.get_tile_id(tile_idx)
			current_source_tiles[tile_id] = true
			if known_tile_ids.has(tile_id):
				continue
			var tile_data = tile_source.get_tile_data(tile_id,0)
			if tile_data != null and tile_data.get_custom_data(PROPS_FIELD_NAME) == null:
				tile_data.set_custom_data(PROPS_FIELD_NAME,TileProps.new())
			known_tile_ids[tile_id] = true
	for tile_id in known_tile_ids.keys():
		if not current_source_tiles.has(tile_id):
			known_tile_ids.erase(tile_id)
