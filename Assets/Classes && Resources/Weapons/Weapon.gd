@abstract 
@tool 
class_name Weapon 
extends Node3D

@export var player: Player

enum projectileType {
	## When fired a hitscan will hit whatever the player's crosshair is on in one frame with no bullet drop
	HITSCAN, 
	## A standard projectile with a speed and bullet drop
	BULLET, 
	## Creates a burst of bullets
	PELLET_BURST
}

## What kind of projectile the weapon creates when fired.
@export var projectile_type: projectileType:
	set(value):
		if projectile_type != value:
			projectile_type = value
			notify_property_list_changed()

## If this weapon can deal damage to the player.
@export var friendlyFire: bool

## How long the weapon takes to cooldown before firing again.
@export var cooldownTime: float

## How long the weapon takes to charge, in seconds.
@export var chargeTime: float

## How long the weapon takes to cooldown before firing again if using the alt-fire
@export var altCooldownTime: float

## How long the weapon takes to charge, in seconds if using the alt-fire
@export var altChargeTime: float

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

@export_group("Damage")
## Damage dealt on hitting an enemy
@export var damage: float
## Damage dealt on hitting an enemy's limb
@export var limbshotDamage: float
## Damage dealt on hitting an enemy's head
@export var headshotDamage: float
## How much the damage is multiplied by by doing an alt-fire shot
@export var altfireMult: float

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

@export_group("Pellet Burst properties")
## Damage dealt if pellets fired by this weapon hits an enemy.
@export var pelletDamage: float
## Radius, in meters, of the circle that pellets will spread out to, one meter away from the weapon.[br]
## A spread of 1 means that 1 meter in front of the point where the weapon was fired, the pellets will roughly fill out a circle with a diameter of 1 meter.
@export var pelletSpread: float
@export var numPellets: int

## Handles showing and hiding attributes for each projectile type depending on which type is chosen
func _validate_property(property: Dictionary) -> void:
	if property.name in ["Pellet Burst properties", "pelletDamage", "pelletSpread", "numPellets"]:
		if projectile_type != projectileType.PELLET_BURST:
			property.usage &= ~PROPERTY_USAGE_EDITOR
	# 3. Bullet Group & variables

## Handles logic for when the player fires the weapon
@abstract
func fire() -> void

## Handles logic for when the player uses the alt fire of a weaopn
@abstract
func altFire() -> void

func handleHitscan() -> void:
	var forward = player.cam_forward
	var physicsState = player.get_world_3d().direct_space_state
	var ray = PhysicsRayQueryParameters3D.create(player.camera.position, forward * 1000)
	var intersection = physicsState.intersect_ray(ray)
	if intersection:
		var hitscan = Hitscan.new()

func handlePelletBurst() -> void:
	pass

func handleBullet() -> void:
	pass
