@tool
class_name Pistol
extends Revolver

func _init(player: Player, damage: float, limbshotDamage: float, headshotDamage: float, altfireMult: float) -> void:
	self.player = player
	projectile_type = self.projectileType.HITSCAN
	friendlyFire = false
	cooldownTime = 0.5
	chargeTime = 0
	enableRicochets = false
	enableExplosive = false
	self.damage = damage
	self.limbshotDamage = limbshotDamage
	self.headshotDamage = headshotDamage
	self.altfireMult = altfireMult

func altFire() -> void:
	pass
