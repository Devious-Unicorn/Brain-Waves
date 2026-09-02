@tool
@abstract
class_name Revolver
extends Weapon

var firing: bool = false
var altFiring: bool = false

func fire() -> void:
	if not firing:
		firing = true
		handleHitscan()
		await get_tree().create_timer(cooldownTime).timeout
		firing = false

@abstract
func altFire() -> void
