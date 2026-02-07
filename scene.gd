extends Node3D

@onready var camera: Camera3D = $Camera3D
@onready var label: Label = $MarginContainer/VBoxContainer/Label

var meshes: Array[MeshInstance3D] = []

func _ready() -> void:
	find_mesh_instances()

func find_mesh_instances() -> void:
	var stack: Array[Node] = get_children(true)
	
	while stack.size() > 0:
		var item: Node = stack.pop_front()
		if item is MeshInstance3D:
			meshes.append(item as MeshInstance3D)

		stack.append_array(item.get_children())

func _physics_process(_delta: float) -> void:
	var screen_position: Vector2 = get_viewport().get_mouse_position()
	
	var origin: Vector3 = camera.project_ray_origin(screen_position)
	var normal: Vector3 = camera.project_ray_normal(screen_position)

	var success: bool = false
	var intersection: Dictionary
	var intersected_mesh: MeshInstance3D
	
	for mesh: MeshInstance3D in meshes:
		intersection = mesh.intersect_ray(origin, normal, true)
		if not intersection.is_empty() and intersection["success"]:
			intersected_mesh = mesh
			success = true
			break
	
	var mat: Material = null

	if success:
		var from: Vector3 = intersection["position"]
		var to: Vector3 = intersection["position"] + intersection["normal"]
		mat = intersected_mesh.get_surface_override_material(intersection["surface_index"])
		
		if not mat and intersection.has("material"):
			mat = intersection["material"]
		
		DebugDraw3D.draw_line(from, to, Color(1.0, 0.0, 0.0, 1.0))

	label.text = ( \
		"Mouse Position 2D: %v\n" +
		"Ray Origin: %v\n" +
		"Ray Normal: %v\n" +
		"Intersection: %s\n" +
		"Point: %v\n" +
		"Normal: %v\n" +
		"Surface: %s\n" +
		"Face: %s\n" +
		"Material: %s\n" +
		"UV: %v\n" +
		"UV2: %v\n" \
		) % [
			screen_position,
			origin,
			normal,
			"Yes" if success else "No",
			intersection["position"] if success else Vector3.ZERO,
			intersection["normal"] if success else Vector3.ZERO,
			intersection["surface_index"] if intersection.has("surface_index") else "None",
			intersection["face_index"] if intersection.has("face_index") else "None",
			mat.resource_path if mat else "None",
			intersection["uv"] if intersection.has("uv") else Vector2.ZERO,
			intersection["uv2"] if intersection.has("uv2") else Vector2.ZERO
		]
