
// File:    demo\combat.dm
// Library: Forum_account.ActionRpgFramework
// Author:  Forum_account
//
// Contents:
//   This file shows how to extend the Combat object to
//   include stats defined by your game. It also shows how
//   to create a graphical effect showing the souls and
//   experience rewarded when a mob dies.

var
	ReiCombat/ReiCombat = new()
	PhysicalCombat/PhysicalCombat = new()

ReiCombat
	parent_type = /Combat

	attack(mob/attacker, mob/target, damage)

		// you can't dodge magic attacks but you can resist them
		if(prob(target.effectivecontrol * 2))
			target.damage_number("Blocked")
			return 0

		// magic attacks use the "focus" stat to determine critical hits
		if(attacker && prob(attacker.effectivefocus * 2))
			target.effect("critical-hit")
			damage *= 2
			target.noise('critical-hit.wav')

		// we use the target's resistance var to modify the
		// damage instead of effectivedefense
		damage -= rand(0, target.effectivecontrol)

		..()

PhysicalCombat
	parent_type = /Combat

	// The attack proc takes the target's defensive stats
	// into account. The attacker's offensive stats are
	// taken into account in the ability that calls this
	// proc.
	attack(mob/attacker, mob/target, damage)

		// the target has a chance to dodge the attack
		if(prob(target.effectivedefense * 2))
			target.damage_number("dodge")
			return 0

		// the attack has a chance to be a critical hit
		if(attacker && prob(attacker.effectiveattack * 2))
			target.effect("critical-hit")
			damage *= 2
			target.noise('critical-hit.wav')

		// use the target's effectivedefense var to modify the damage value
		damage -= rand(0, target.effectivedefense)

		// run the default behavior, which actually inflicts the damage.
		..()

mob
	// every time a mob takes damage, show a damage number
	took_damage(damage, mob/attacker, Combat/combat)
		..()
		damage_number(damage)

	// every time a mob gains experience and souls, show the gain on the screen
	experience_and_souls_gain(experience, souls, mob/enemy)
		..()

		if(client)
			damage_number("<font color=[Constants.souls_COLOR]>+$[souls]\n<font color=[Constants.EXPERIENCE_COLOR]>+[experience] XP", layer = 30, duration = 60)
