mob/Admin1
	proc
		ViewEmoteWindow(mob/player, unwritten, type = "Emote", path = "emotelogs")
			var/View={"
				<html>
					<head>
						<title>[player] [type] Log</title>
					</head>
					
					<body bgcolor="#000000">
						<font size=6><font color="#0099FF">
							<b>
					</body>
				<html>
			"}
			var/XXX=file("Logs/[path]/[player.ckey]Current.html")
			if(fexists(XXX))
				var/list/File_List = list("Cancel")

				for(var/File in flist("Logs/[path]/[player.ckey]"))
					File_List+=File
				if(src)
					var/File = input(src,"Which [type] log do you want to view?") in File_List
					if(!File || File=="Cancel") return

					var/emotefile = file2text(file("Logs/[path]/[File]"))
					View += emotefile
					if(player)
						View += unwritten

					usr << "Viewing [File]"
					usr << browse(View,"window=Log;size=800x600")
					admin_blame(usr, "Opens [player]'s [type] log")
			else
				usr << "No logs found for [player.ckey]"
	verb
		ViewRPWindow(mob/M in players)
			set category="Admin"
			set name="View Player RP Window"
			ViewEmoteWindow(M, M.unwritten_emotelogs, "Emote", "emotelogs")
			
		ViewDevelopmentRPWindow(mob/M in players)
			set category="Admin"
			set name="View Player Development RP Window"

			ViewEmoteWindow(M, M.unwritten_emotelogs, "Development Emote", "emotelogs_dev")
mob
	proc
		PostEmoteRPWindow(text as text, key)
			for(var/mob/M in world)
				if(M.client)
					EmoteLog(text, key, "emotelogs")

		PostDevelopmentRPWindow(text as text, key)
			for(var/mob/M in world)
				if(M.client)
					EmoteLog(text, key, "emotelogs_dev")

mob/verb/ViewDescription(mob/A)
	set name="View Description"
	set category="Other"
	
	if(!A)
		return
	if(!A.player_desc)
		return

	var/html = "[A.player_desc]"

	usr << browse(html, "window=[A];size=800x600;name=[A]")

mob/var/tmp
	last_emotelog_write=0
	unwritten_emotelogs=""

mob/proc
	EmoteLog(info, the_key, type="emotelogs")
		if(!client) return
		if(!last_emotelog_write)
			last_emotelog_write=world.time //prevent writing unecessarily when someone has just logged in
		var/log_entry="<br><font color=white>([time2text(world.realtime,"DD/MM/YY hh:mm:ss")]) [info] ([the_key])"

		if(world.time-last_emotelog_write < 100) // 10 seconds
			unwritten_emotelogs += log_entry
		else Write_emotelogs()

	Write_emotelogs(allow_splits=1, type)
		if(!key) return
		last_emotelog_write=world.time
		var/f=file("Logs/[type]/[ckey]Current.html")
		f<<unwritten_emotelogs
		if(allow_splits) Split_EmoteFile(ckey, type)
		unwritten_emotelogs=""

proc/Split_EmoteFile(the_key, type)
	set waitfor=0
	var/f=file("Logs/[type]/[the_key]Current.html")
	if(fexists(f))
		if(length(f)>=100*1024) //100 MB
			var/Y=length(flist("Logs/[type]/"))
			fcopy(f,"Logs/[type]/[the_key][Y].html")
			fdel(f)
