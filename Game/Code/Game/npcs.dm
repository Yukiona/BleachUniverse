
// File:    demo\npcs.dm
// Library: Forum_account.ActionRpgFramework
// Author:  Forum_account
//
// Contents:
//   This file defines the NPCs. NPCs are invulnerable
//   mobs with simple AI (sometimes none) that the player
//   can interact with.

mob
	npc
		invulnerable = 1
		effectivespeed = 1
		icon = 'npcs.dmi'
		icon_state = "shinigaminpc1-standing"

		npc1
			interact(mob/m)

				// we call the ai_pause/play procs to make the mob
				// stop moving while you're interacting with him.
				ai_pause()

				// we omit the second argument, which makes this mob
				// the starting and ending point for the quest.
				m.quest_dialog(/Quest/KillThreeBlueOozes)
				ai_play()

			ai()
				// even though it's not an ability, we use cooldowns
				// to limit how often wander is called.
				if(!on_cooldown("wander"))
					wander(2)

			// when the NPC reaches the random tile they're walking
			// to, trigger their wander cooldown.
			moved_to()
				cooldown("wander", 40)

		npc2
			// this NPC is stationary so we override their ai() proc
			// to make them do nothing.
			ai()

			interact(mob/m)
				// this mob is only the starting point of the quest
				m.quest_dialog(/Quest/FindMyBrother, QUEST_START)

		npc3
			ai()

			interact(mob/m)
				// this mob is only the ending point of the quest
				m.quest_dialog(/Quest/FindMyBrother, QUEST_END)

		banker
			ai()

			interact(mob/m)
				m.banking()

		guard
			wander_distance = 0
			effectivespeed = 3

			health = 60
			max_health = 60

			effectiveattack = 8
			effectivespeed = 10
			effectivedefense = 5

			abilities = list(new /Ability/EnemyAttack())

			ai()
				// run the default behavior which makes the guard
				// look for a target, move towards enemies, and
				// attack them.
				..()

				// if the target is dead, clear the target
				if(target && target.dead)
					target = null

				// if the guard doesn't have a target, make them
				// return to their starting point.
				if(!target && !path)
					move_to(locate(initial(x), initial(y), z))

		shopkeeper
			name = "That Shop Dude"
			base_state = "helpingman"
			icon_state = "helpingman-standing"
			New()
				..()

				// initialize the shopkeeper's inventory
				new /item/classyshirts(src)
				new /item/bluetrousers(src)

			// this NPC is stationary so we override their ai() proc
			// to make them do nothing.
			ai()

			interact(mob/m)

				var/choice = m.prompt("Hello, welcome to my shop. Would you like to browse?", "Yes", "No")

				if(choice == "Yes")
					m.shopkeeper(src)

		helpingshinigami
			name = "Strange Shinigami"
			base_state = "shini1"
			icon_state = "shini1-standing"
			wander_distance = 0

			health = 60
			max_health = 60

			effectiveattack = 225
			effectivespeed = 8
			effectivedefense = 150
			abilities = list(new /Ability/EnemyAttack())

			ai()
				..()
				if(target && target.dead)
					target = null

				// if the guard doesn't have a target, make them
				// return to their starting point.
				if(!target && !path)
					move_to(locate(initial(x), initial(y), z))
			interact(mob/m)
				ai_play()

		starterman
			name = "Mike Miquesigemyateran"
			base_state = "helpingman"
			icon_state = "helpingman-standing"
			wander_distance = 0

			health = 60
			max_health = 60

			effectiveattack = 225
			effectivespeed = 8
			effectivedefense = 150
			abilities = list(new /Ability/EnemyAttack())

			ai()
			interact(mob/m)
				ai_pause()
				if (m.class == "Soul" & m.level >= 25)
					var/choice = m.prompt("Do you wish to become a shinigami?", "Yes", "No")
					if(choice == "Yes")
						PlayerChangeRace("Shinigami")
						m.get_item (new /item/shihakusho())
				else
					m << "<b><i>You cant talk to me yet!</i></b>"
				ai_play()

Quest
	KillThreeBlueOozes
		name = "Blue Oozes"
		description = "The oozes have been getting closer and closer to town. Can you kill three blue oozes for me? That'll show 'em!"
		status = ""

		already_completed_message = "Thanks again for killing those blue oozes!"
		completion_message = "Wow, great job!"
		in_progress_message = "Keep at it, I know you can do it!"

		var
			// we keep a count of how many blue oozes you've killed
			count = 0

		// update the counter
		killed(mob/enemy/blue_ooze/b)
			if(istype(b))
				count += 1
				update()

		// update the quest's status
		update()
			..()

			if(count >= 3)
				complete = 1
				status("complete")
			else
				status("[count] / 3")

		// the quest is complete when you've killed at least 5 blue oozes
		is_complete()
			return count >= 3

	FindMyBrother
		name = "Find my Brother"
		description = "Can you find my brother and tell him that dinner is ready? I have no idea where he went."
		status = "complete"

		already_completed_message = "Thanks, his dinner was getting cold."
		completion_message = "Dinner's ready? Thanks for telling me!"
		in_progress_message = "Did you find him yet?"

		complete = 1
