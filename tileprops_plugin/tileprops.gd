@tool
extends Resource
class_name TileProps
#Example properties. Replace or expand with any custom data or methods you want every tile to include
enum tile_type {None, Floor, Wall}
@export var type : tile_type
@export var walkable : bool
