@abstract
class_name Enemy
extends CharacterBody3D

var health: float
@export var maxHealth: float

@export var moveSpeed: float
@export var jumpHeight: float

## Whether or not this enemy can be damaged
@export var vulnerable: bool = true

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var gravityVelocity: Vector3
var jumpVelocity: Vector3
var jumping: bool

## Accessed to modify an enemie's health. [br]
## negative values will heal the enemy
func hurt(dmg: float) -> void:
	if vulnerable:
		health -= dmg
		health = clamp(health, 0, maxHealth)
	if health == 0:
		die()

## Handles the force of gravity on the enemy's velocity[br]
func _gravity(delta: float) -> Vector3:
	gravityVelocity = Vector3.ZERO if is_on_floor() else gravityVelocity.move_toward(Vector3(0, velocity.y - gravity, 0), gravity * delta)
	return gravityVelocity

## Handles a jump force's effect of the enemy's velocity[br]
func _jump(delta: float) -> Vector3:
	if jumping:
		if is_on_floor(): jumpVelocity = Vector3(0, sqrt(4 * jumpHeight * gravity), 0)
		jumping = false
		return jumpVelocity
	jumpVelocity = Vector3.ZERO if is_on_floor() or is_on_ceiling_only() else jumpVelocity.move_toward(Vector3.ZERO, gravity * delta)
	return jumpVelocity

## Handles calculating the enemy's vinal velocity for the frame[br]
func _handleFinalVelocity(delta: float) -> void:
	velocity = pathfind() + _gravity(delta) + _jump(delta)

## Enemies' logic for how to pathfind and position themselves around the player character.
@abstract
func pathfind() -> Variant

## Enemies' logic for how to attack the player character.
@abstract
func attack() -> Variant

## Enemies' death logic
@abstract
func die() -> void
