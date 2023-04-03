mob
	proc
		ViewEmoteWindow(mob/admin, mob/player, unwritten, type = "Emote", path = "emotelogs")
			var/View={"
				<html>
					<head>
						<title>[player] [type] Log</title>
						 <meta charset="UTF-8">
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
				var/last_line = ""

				for(var/File in flist("Logs/[path]/[player.ckey]"))
					File_List+=File
				if(admin)
					var/File = input(admin, "Which [type] log do you want to view?") in File_List
					if(!File || File=="Cancel") return

					var/emotefile = file2text(file("Logs/[path]/[File]"))
					View += emotefile
					if(player)
						View += unwritten

					admin << "Viewing [File]"
					admin << browse(View,"window=Log;size=800x600")
					admin_blame(admin, "Opens [player]'s [type] log")
			else
				admin << "No logs found for [player.ckey]"
	verb
		ViewSelfRPWindow()
			var/mob/M = src
			set category="Other"
			set name="View own RP Window"
			ViewEmoteWindow(src, M, M.unwritten_emotelogs, "Emote", "emotelogs")
			
		ViewSelfDevelopmentRPWindow()
			var/mob/M = src
			set category="Other"
			set name="View own Development RP Window"

			ViewEmoteWindow(src, M, M.unwritten_emotelogs, "Development Emote", "emotelogs_dev")
			
		ViewSelfSayWindow()
			var/mob/M = src
			set category="Other"
			set name="View own Chatlog"

			ViewEmoteWindow(src, M, M.unwritten_chatlogs, "Chatlog", "ChatLogs")
mob/Admin1
	verb
		ViewRPWindow(mob/M in players)
			set category="Admin"
			set name="View Player RP Window"
			ViewEmoteWindow(src, M, M.unwritten_emotelogs, "Emote", "emotelogs")
			
		ViewDevelopmentRPWindow(mob/M in players)
			set category="Admin"
			set name="View Player Development RP Window"

			ViewEmoteWindow(src, M, M.unwritten_emotelogs, "Development Emote", "emotelogs_dev")
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
		var/log_entry="<br><font color=white><span style='font-size: 10pt'>([the_key]) - ([time2text(world.realtime,"DD/MM/YY hh:mm:ss")])</span>[info]"

		if(world.time-last_emotelog_write < 100) // 10 seconds
			unwritten_emotelogs += log_entry
		else Write_emotelogs(type=type)

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
