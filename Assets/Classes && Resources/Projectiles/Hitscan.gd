class_name Hitscan
extends Projectile

@export var point_a: Vector3 = Vector3(0, 0, 0):
	set(val):
		point_a = val
		update_plane()

@export var point_b: Vector3 = Vector3(0, 0, 5):
	set(val):
		point_b = val
		update_plane()

func _ready() -> void:
	update_plane()

func update_plane() -> void:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	# Direction vector from A to B
	var dir = (point_b - point_a)
	var length = dir.length()
	if length == 0:
		return
	dir = dir.normalized()
	
	# Find a perpendicular vector for the width (using up vector as a reference)
	var up = Vector3.UP
	if abs(dir.dot(up)) > 0.99:
		up = Vector3.FORWARD
	var right = dir.cross(up).normalized() * (0.1 / 2.0)
	
	# 4 corners of the plane
	var v0 = point_a - right
	var v1 = point_a + right
	var v2 = point_b + right
	var v3 = point_b - right
	
	# Triangle 1 (V0 -> V1 -> V2)
	st.set_uv(Vector2(0, 0))
	st.add_vertex(v0)
	st.set_uv(Vector2(1, 0))
	st.add_vertex(v1)
	st.set_uv(Vector2(1, 1))
	st.add_vertex(v2)
	
	# Triangle 2 (V0 -> V2 -> V3)
	st.set_uv(Vector2(0, 0))
	st.add_vertex(v0)
	st.set_uv(Vector2(1, 1))
	st.add_vertex(v2)
	st.set_uv(Vector2(0, 1))
	st.add_vertex(v3)
	
	var hitscan = MeshInstance3D.new()
	hitscan.mesh = st.commit()
	var mat = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color(0x00d9ffff)
	hitscan.material_override = mat
	add_child(hitscan)
	await get_tree().create_timer(0.1).timeout
	hitscan.queue_free()
