/obj/machinery/microorganism/incubator/
	name = "Pathogenic incubator"
	density = 1
	anchored = 1
	icon = 'virology.dmi'
	icon_state = "incubator"
	var/obj/item/weapon/virusdish/dish
	var/obj/item/weapon/reagent_containers/glass/beaker = null
	var/radiation = 0

	var/on = 0
	var/power = 0

	var/foodsupply = 0
	var/toxins = 0

	ex_act(severity)
		switch(severity)
			if(1.0)
				del(src)
				return
			if(2.0)
				if (prob(50))
					del(src)
					return

	attackby(var/obj/B as obj, var/mob/simulated/living/humanoid/user as mob)
		user = usr
		if(istype(B, /obj/item/weapon/reagent_containers/glass) || istype(B,/obj/item/weapon/reagent_containers/syringe))

			if(src.beaker)
				if(istype(beaker,/obj/item/weapon/reagent_containers/syringe))
					user << "A syringe is already loaded into the machine."
				else
					user << "A beaker is already loaded into the machine."
				return

			src.beaker =  B
			user.drop_item()
			B.loc = src
			if(istype(B,/obj/item/weapon/reagent_containers/syringe))
				user << "You add the syringe to the machine!"
				src.updateUsrDialog()
			else
				user << "You add the beaker to the machine!"
				src.updateUsrDialog()
		else
			if(istype(B,/obj/item/weapon/virusdish))
				if(src.dish)
					user << "A dish is already loaded into the machine."
					return

				src.dish =  B
				user.drop_item()
				B.loc = src
				if(istype(B,/obj/item/weapon/virusdish))
					user << "You add the dish to the machine!"
					src.updateUsrDialog()

	Topic(href, href_list)
		if(stat & BROKEN) return
		if (href_list["ejectchem"])
			if(beaker)
				beaker.loc = src.loc
				beaker = null
		if(!dish)
			return
		usr.machine = src
		if (href_list["power"])
			on = !on
			if(on)
				icon_state = "incubator_on"
			else
				icon_state = "incubator"
		if (href_list["ejectdish"])
			if(dish)
				dish.loc = src.loc
				dish = null
		if (href_list["rad"])
			radiation += 10
		if (href_list["flush"])
			radiation = 0
			toxins = 0
			foodsupply = 0

	attack_hand(mob/user as mob)
		if(stat & BROKEN)
			return
		user.machine = src
		var/dat = ""
		if(!dish)
			dat = "Please insert dish into the incubator.<BR>"
		var/string = "Off"
		if(on)
			string = "On"
		dat += "Power status : <A href='?src=\ref[src];power=1'>[string]</a>"
		dat += "<BR>"
		dat += "Food supply : [foodsupply]"
		dat += "<BR>"
		dat += "Radiation Levels : [radiation] RADS : <A href='?src=\ref[src];rad=1'>Radiate</a>"
		dat += "<BR>"
		dat += "Toxins : [toxins]"
		dat += "<BR><BR>"
		if(beaker)
			dat += "Eject chemicals : <A href='?src=\ref[src];ejectchem=1'> Eject</a>"
			dat += "<BR>"
		if(dish)
			dat += "Eject Virus dish : <A href='?src=\ref[src];ejectdish=1'> Eject</a>"
			dat += "<BR>"
		dat += "<BR><BR>"
		dat += "<A href='?src=\ref[src];flush=1'>Flush system</a><BR>"
		dat += "<A href='?src=\ref[src];close=1'>Close</A><BR>"
		user << browse("<TITLE>Pathogenic incubator</TITLE>incubator menu:<BR><BR>[dat]", "window=incubator;size=575x400")
		onclose(user, "incubator")
		return




	process()

		if(dish && on && dish.microorganism)
			if(foodsupply)
				foodsupply -= 1
				dish.growth += 3
			if(radiation)
				if(radiation > 50 & prob(5))
					dish.microorganism.majormutate()
					if(dish.info)
						dish.info = "OUTDATED : [dish.info]"
						dish.analysed = 0

				else if(prob(5))
					dish.microorganism.minormutate()
				 radiation -= 1
			if(toxins && prob(5))
				dish.microorganism.infectionchance -= 1
			if(toxins > 50)
				dish.microorganism = null
		else if(!dish)
			on = 0
			icon_state = "incubator"


		if(beaker)
			if(!beaker.reagents.remove_reagent("virusfood",5))
				foodsupply += 10
			if(!beaker.reagents.remove_reagent("toxins",1))
				toxins += 1