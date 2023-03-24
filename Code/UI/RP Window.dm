mob/Admin1
	verb
		ViewRPWindow()
			set category="Admin"
			winset(src,"rpwindow","is-visible=true")
		ViewDevelopmentRPWindow()
			set category="Admin"
			winset(src,"rp_devwindow","is-visible=true")
mob
	proc
		PostEmoteRPWindow(text as text)
			for(var/mob/M in world)
				if(M.client)
					M << output(text,"rpoutput")
		PostDevelopmentRPWindow(text as text)
			for(var/mob/M in world)
				if(M.client)
					M << output(text,"rp_devoutput")
					M << output(text,"rpoutput")