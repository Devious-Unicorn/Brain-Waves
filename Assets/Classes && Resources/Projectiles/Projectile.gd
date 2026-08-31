@abstract
class_name Projectile
extends Node3D

enum projectileType {
	## When fired a hitscan will hit whatever the player's crosshair is on in one frame with no bullet drop
	HITSCAN, 
	## A standard projectile with a speed and bullet drop
	BULLET, 
	## Creates a burst of bullets
	PELLET_BURST
}

## What kind of projectile the weapon creates when fired.
@export var projectile_type: projectileType

@export var damage: float

## If this weapon can deal damage to the player.
@export var friendlyFire: bool

## If the projectile created by this weapon ricochets.
@export_group("Ricochets") 
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "enableRicochets")
var enableRicochets: bool
## Possible targets to ricochet off of.
enum ricochetTargets {
	LEVEL = 1,
	ENEMIES = 2,
	PLAYER = 4
}
## The world objects that projectiles created by this weapon will ricochet off of.
@export_flags("Level:1", "Enemies:2", "Player:4") var ricochetTarget: int

@export_group("Explosive")
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "enableExplosive")
var enableExplosive: bool
## Damage dealt when explosives fired by this weapon detonates.
@export var explosiveDamage: float
## Radius, in meters, of the explosion created when the explosive fired by this weapon detonates.
@export var explosionSize: float
## Possible targets to explode on.
enum explosionTargets {
	LEVEL = 1,
	ENEMIES = 2,
	PLAYER = 4
}
## The world objects that projectiles created by this weapon will explode on if they collide with.
@export_flags("Level:1", "Enemies:2", "Player:4") var explosionTarget: int
## Whether or not the explosive fired by this weapon creates fire when detonating.
@export var ignitesFire: bool

func _init() -> void:
	pass
