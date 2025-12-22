# TileProps — Flexible custom data for TileSets in Godot 4.5

A plugin for Godot designed to increase the flexibility of custom data layers.

TileSet custom data layers in Godot only support a few types, and do not support *enums.* TileProps solves this using a global 'TileProps' class assigned to any created tile. This allows for scriptable properties and methods for tiles, and increases readability for mutually exclusive states via enums.

<img src="https://github.com/user-attachments/assets/3850e82b-f459-4b2e-9de2-6e6b5bfbcb6d" width="75%" height="75%"/>

## **Installation**

1. Extract the .zip from the Releases tab into your project’s addons directory (e.g `res://addons/tileprops_plugin`). 
2. Enable in [Project Settings/Plugins]

## **Usage**

Adapt the TileProps class as necessary with any properties and methods you require. It can be edited via the `tileprops.gd` script. The included examples properties are:

Walkable : Boolean

Type : TileType Enum (0: None, 1: Floor, 2: Wall)

For each new or existing tilemap, create a Custom Data Layer named *Props**, and set its type to *Object* (Important).

<img width="430" height="135" alt="image" src="https://github.com/user-attachments/assets/286f6d83-6bf8-47e3-b407-7c93130b77ab" />

The plugin will then automatically populate any existing tiles’ *Props* field with a new TileProps resource. Your custom fields can now be edited here!

<img width="321" height="157" alt="Example TileProps Field" src="https://github.com/user-attachments/assets/70c259a0-3b10-4cb7-9445-c33b83126cdd" />

To access these properties in code, access the custom data layer as normal using the *as* keyword to adopt the TileProps type.

**Example** (GDScript):

```gdscript
var tile_props = example_tilemap_layer.get_cell_tile_data(coords).get_custom_data("Props") as TileProps
#Accessing properties
var is_walkable : bool = tile_props.Walkable
```

**Example** (C#):

```csharp
var tileProps = exampleTileMapLayer.GetCellTileData(coords).GetCustomData("Props").As<TileProps>();
//Accessing properties
bool isWalkable = tileProps.Walkable;
```

*The layer name can be edited via the `PROPS_FIELD_NAME` constant in the `tileprops_plugin.gd` script.

## **Additional Information**

Currently tested for tilesets up to 64*64 in size.

Contributions are welcome. Godot’s available EditorInterface methods and signals are somewhat lacking, meaning there are some hacks and workarounds in here that likely have more elegant solutions.
