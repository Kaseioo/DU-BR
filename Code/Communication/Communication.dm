mob/var/tmp
	last_chatlog_write=0
	unwritten_chatlogs=""
	last_drone_msg

mob/proc
	ChatLog(info,the_key)
		if(!client) return
		if(!last_chatlog_write) last_chatlog_write=world.time //prevent writing unecessarily when someone has just logged in
		var/log_entry="<br><font color=white>([time2text(world.realtime,"DD/MM/YY hh:mm:ss")]) [info] ([the_key])"
		if(world.time-last_chatlog_write<100) // 10 seconds
			unwritten_chatlogs+=log_entry
		else Write_chatlogs()

	Write_chatlogs(allow_splits=1)
		if(!key) return
		last_chatlog_write=world.time
		var/f=file("Logs/ChatLogs/[ckey]Current.html")
		f<<unwritten_chatlogs
		if(allow_splits) Split_File(ckey)
		unwritten_chatlogs=""

proc/Split_File(the_key)
	set waitfor=0
	var/f=file("Logs/ChatLogs/[the_key]Current.html")
	if(fexists(f))
		if(length(f)>=100*1024) //100 MB
			var/Y=length(flist("Logs/ChatLogs/"))
			fcopy(f,"Logs/ChatLogs/[the_key][Y].html")
			fdel(f)


proc/TimeStamp(var/Z)
	if(Z==1)
		return time2text(world.timeofday,"MM-DD-YY")
	else
		return time2text(world.timeofday,"MM/DD/YY(hh:mm s)")

proc/Replace_Text(Text,Old_Word,New_Word)
	var/list/L=Text_2_List(Text,Old_Word);return List_2_Text(L,New_Word)

proc/Text_2_List(text,sep)
	var/textlen=lentext(text);var/seplen=lentext(sep);var/list/L=new;var/searchpos=1;var/findpos=1;var/buggytext
	while(1)
		findpos=findtext(text,sep,searchpos,0);buggytext=copytext(text,searchpos,findpos);L+="[buggytext]"
		searchpos=findpos+seplen
		if(findpos==0) return L
		else if(searchpos>textlen)
			L+=""
			return L

proc/List_2_Text(list/L,sep)
	var/total=L.len
	if(total==0) return
	var/newtext="[L[1]]";var/count
	for(count=2,count<=total,count++)
		if(sep) newtext+=sep;newtext+="[L[count]]"
	return newtext
// compilou sem erro
// agora se isKoStuff não for passado ele vai ser sempre FALSE
// só que em teoria é a mesma coisa que nada porque null é false pro if
// só que seria um false pra "defined" ao inves de "value"
// o isKoStuff = FALSE não ia modificar porra nenhuma além de deixar explicitamente que o valor da variável é false (ou seja, diminuir o escopo de num pra bool)
mob/verb/Countdown(Seconds as num, message as text|null, final_message as text|null, isKoStuff as num|null)
	set category = "Other"
	set desc = "Countdown from a number of seconds. You can also specify a message to display at the start and end of the countdown."
	// funciona
	// ok abriu
	if(!isKoStuff)
		isKoStuff = FALSE

	if(!Seconds) 
		Seconds = input("How many seconds should the countdown last?") as num

	if(Seconds > 600) Seconds = 600

	var/t="[src] is waiting [Seconds] seconds."	

	Seconds *= 10
	// que odio!
	if(message)
		t = " [message]"
	if(!isKoStuff)
		player_view(22, src) << t

	if(client) 
		ChatLog(t,key)

	var/elapsed = 0

	while(elapsed < Seconds)
		if(Seconds > 300)
			if(elapsed + 300 > Seconds)
				elapsed += (Seconds - elapsed) + 1	
				sleep(Seconds - elapsed)
			else
				elapsed += 300
				sleep(300)
		else 
			sleep(Seconds)
			break;
		if(!isKoStuff)
			var/elapsed_message = "[src] has waited [elapsed/10] seconds out of [Seconds/10] seconds."
			player_view(22, src) << "[elapsed_message]"

			if(client) 
				ChatLog(elapsed_message, key)
	if(!isKoStuff)
		var/t2 = "[src] has finished waiting [Seconds/10] seconds."
		
		if(final_message)
			t2 = "[final_message]"

		player_view(22, src) << t2

		if(client) ChatLog(t2,key)

//var/image/saySpark = image(icon = 'Say Spark.dmi', pixel_y = 6)
var/image/saySpark = image(icon = 'KhunTyping.dmi', pixel_y = 8, pixel_x = 8)

mob/proc/Say_Spark()
	set waitfor=0
	overlays -= saySpark
	overlays += saySpark
	sleep(50)

mob/proc/Remove_Say_Spark()
	overlays -= saySpark

var/OOC=1

mob/proc/End_Say()
	can_say = 1
	spawn(25) Remove_Say_Spark()


mob/var
	OOCon=1
	TextColor="blue"
	TextSize=2
	seetelepathy=1

mob/var/tmp
	Spam=0
	list/recent_ooc=new

mob/proc/Spam_Check(var/Message)
	if(key in Mutes)
		src<<"You are muted"
		return 1
	Spam++
	spawn(40) if(src) Spam--
	if((Spam>=5&&!(key in Mutes))||findtext(Message,"\n\n\n\n"))
		Mutes[key]=world.realtime+(0.5*60*60*10)
		world<<"[key] has been auto-muted for spamming."
		return 1
	if(Message in recent_ooc)
		if(!(lowertext(Message) in list("idk","afk","ah","hi","lol","yea","yeah","ya","no","nope","what",\
		"what?","yes","ok","k"))) return 1
	recent_ooc.Insert(1,Message)
	if(recent_ooc.len>10) recent_ooc.len=10

proc/Spammer(P) if(P in Mutes) return 1

var/Crazy

mob/Admin4/verb/Crazy()
	set category="Admin"
	Crazy=!Crazy

mob/proc/Say_Recipients()
	var/list/L=new
	var/old_sight=sight
	var/old_invis=see_invisible
	sight=0
	see_invisible=101
	var/D=20
	for(var/mob/M in player_view(D,src))
		L|=M
	for(var/obj/Ships/S in view(D,src))
		if(S.Comms) L|=S.Pilot
	if(src.Ship && Ship.Comms)
		for(var/mob/M in player_view(D,src.Ship))
			L|=M
		for(var/obj/Ships/S in view(D,src.Ship))
			L|=S.Pilot
	else if(src.Ship && !Ship.Comms) L|= src
	if(istype(src.loc,/mob))
		L|=src
		L|=src.loc
	sight=old_sight
	see_invisible=old_invis
	return L

mob/var/tmp/list/stop_messages=new

mob/verb
	Ignore_GlobalSay()
		set category="Other"
		if(OOCon)
			OOCon=0
			usr<<"GlobalSay is now hidden."
		else
			OOCon=1
			usr<<"GlobalSay is now visible."

	GlobalSay(msg as text)
		//set category="Other"
		//set instant=1
		if(!OOC)
			src<<"OOC is disabled by admins"
			return
		if(client)
			if(!msg||msg=="") msg=input("Type a message that everyone can see") as text|null
			if(!msg||msg=="") return
		if(key)
			if(Spammer(key)) return
			if(!Admins[key]) msg=copytext(msg,1,400)
			if(Spam_Check(msg)) return

		var/ooc_name="[name]([displaykey])"
		if(!show_names_in_ooc) ooc_name = displaykey
		if(name == displaykey) ooc_name = name

		for(var/mob/M in players) if(M.OOCon)
			M<<"<font size=[M.TextSize]><font color=[TextColor]>[ooc_name]: <font color=white>[html_encode(msg)]"

	OOC(msg as text)
		//set category = "Other"
		//set hidden = 1
		GlobalSay(msg)

	Whisper(msg as text)
		//set category="Other"
		if(!usr.can_say) return
		if(!msg||msg=="") msg=input("Type a message that people in sight can see") as text
		usr.can_say=0
		spawn(1) if(usr) usr.can_say=1
		for(var/mob/M in Say_Recipients())
			M<<"<font size=[M.TextSize]>-[name] whispers something..."
			if(getdist(src,M)<=2)
				var/t="<font size=[M.TextSize]><font color=[TextColor]>*[name] whispers: [html_encode(msg)]"
				M<<t
				M.ChatLog(t,key)
		usr.Say_Spark()

	Say(msg as text|null)
		set category = "Other"
		if(!usr.can_say) return
		usr.can_say = 0
		Say_Spark()
		if(!msg) msg = input("Type a message for people in sight to see", "Local Chat") as null|text
		if(msg)
			for(var/obj/items/Clothes/Neko_Collar/neko in item_list)
				if(neko.suffix == "Equipped")
					msg = "[msg]～"
			var/t = "<span style='font-size:10pt;color:[TextColor];font-family:Walk The Moon'>[name]: [msg]</span>"
			for(var/mob/m in Say_Recipients())
				if(m.last_drone_msg != msg || !drone_module)
					if(lowertext(msg) == "stop" && m != src && client && m && m.client)
						if(m.stop_messages.len > 5) m.stop_messages.len = 5
						m.stop_messages.Insert(1, key)
						m.stop_messages[key] = world.time
					m << t
					m.ChatLog(t,key)
					if(drone_module) m.last_drone_msg = msg
			if(client) troll_respond(msg)
		usr.End_Say()

	SayCooldown()
		set waitfor = 0
		can_say = 0
		sleep(1)
		can_say = 1

	Emote(msg as null|message)
		set category="Other"
		if(!usr.can_say) return
		usr.can_say = 0
		usr.Say_Spark()
		if(!msg||msg=="") msg=input("Type a message that people in sight can see") as null|message
		if(msg)
			usr.can_say=0
			spawn(1) if(usr) usr.can_say=1
			var/t="<span style='font-size:10pt;color:yellow;font-family:Walk The Moon'>[msg]</span>"
			t = "<span style='font-size:12pt;color:yellow;font-family:Walk The Moon'> ======[name]====== </span><br>[t]"

			var/type = input("What type of emote is this?") as null|anything in list("Normal", "Character Development")
			var/message = "<br><br><span style='font-size:10pt;color:yellow;font-family:Walk The Moon'>======| [name] às [time2text(world.timeofday,"YYYY-MM-DD hh:mm:ss")] |======<br><br><span style='color: white;'>[html_encode(msg)]</span></span>"
			if(type == "Character Development")
				PostDevelopmentRPWindow(message)
			else 
				PostEmoteRPWindow(message)

			for(var/mob/M in Say_Recipients())
				M << t
				M.ChatLog(t,key)
			
		usr.End_Say()

mob/var/tmp
	can_telepathy=1
	can_say=1

obj/Telepathy
	teachable=1
	Skill=1
	hotbar_type="Ability"
	can_hotbar=1
	Cost_To_Learn=2
	Teach_Timer=0.3
	student_point_cost = 10
	verb/Hotbar_use()
		set hidden=1
		Telepathy()
	verb/Telepathy(mob/M in players)
		set src=usr.contents
		set category="Skills"
		if(!usr.can_telepathy) return
		if(M&&M.seetelepathy)
			var/message=input("Say what in telepathy?") as text|null
			if(!usr.can_telepathy||!message||message=="") return
			usr.can_telepathy=0
			spawn(1) if(usr) usr.can_telepathy=1
			if(M)
				var/msg="(Telepathy)<font color=[usr.TextColor]>[usr]: [html_encode(message)]"
				msg=copytext(msg,1,1000)
				M<<"<font size=[M.TextSize]>[msg]"
				usr<<"<font size=[usr.TextSize]>[msg]"
				M.ChatLog(msg,usr.key)
				usr.ChatLog(msg,usr.key)
		else usr<<"They have their telepathy turned off."

mob/verb/Who()
	set category="Other"
	var/Who={"<body bgcolor="#000000"><font color="#CCCCCC">"}
	var/Amount=0
	Who+="<br>Key ( Name )"
	var/list/a=new
	for(var/mob/m in players) a+=m
	for(var/mob/Troll/t) a.Insert(rand(1, a.len), t)
	//NO LONGER NEED TO ADD THEM SEPARATELY BECAUSE THEY ARE IN THE 'players' LIST AS OF WRITING THIS. UNLESS IT CAUSES PROBLEMS
	//for(var/mob/new_troll/t) a.Insert(rand(1, a.len), t)
	for(var/mob/A in a)
		Amount+=1
		if(IsAdmin()) 
			Who+="<br>[A.displaykey] ([A.name]) - [A.Race]"
		else
			if(SHOW_CHAR_NAME_ON_WHO)
				Who+="<br>[A.displaykey] ( [A.name] )"
			else
				Who+="<br>[A.displaykey]"
	Who+="<br>Amount: [Amount]"
	src<<browse(Who,"window=Who;size=600x600")
	
mob/verb/Play_Music()
	set category="Other"
	switch(input(src,"You can play some built in music for whatever reason.") in \
	list("Cancel","Gohan","Gohan 2","Goku SSj","Goku SSj3","Super Namek","Ai Wo Torimodose",\
	"Ai Wo Torimodose 2","Pikkon","Vegeta","Ssj Vegeta","Ussj Trunks","Ginyu","Cell the Boogieman",\
	"Majin Buu","Cell powers up","Prince of Saiyans","Super Buu"))
		if("Cancel") src<<sound(0)
		if("Gohan")
			var/sound_repeat
			switch(alert(src,"Loop music?","Options","No","Yes"))
				if("Yes") sound_repeat=1
			spawn player_view(10,src)<<sound('Gohanangers.ogg',repeat=sound_repeat,volume=100)
		if("Gohan 2")
			var/sound_repeat
			switch(alert(src,"Loop music?","Options","No","Yes"))
				if("Yes") sound_repeat=1
			spawn player_view(10,src)<<sound('GohanHitsTree.ogg',repeat=sound_repeat,volume=40)
		if("Goku SSj")
			var/sound_repeat
			switch(alert(src,"Loop music?","Options","No","Yes"))
				if("Yes") sound_repeat=1
			spawn player_view(10,src)<<sound('DBZ Goku Super Saiyan Theme.ogg',repeat=sound_repeat,volume=100)
		if("Goku SSj3")
			var/sound_repeat
			switch(alert(src,"Loop music?","Options","No","Yes"))
				if("Yes") sound_repeat=1
			spawn player_view(10,src)<<sound('SSJ3Powerup.ogg',repeat=sound_repeat,volume=100)
		if("Super Namek")
			var/sound_repeat
			switch(alert(src,"Loop music?","Options","No","Yes"))
				if("Yes") sound_repeat=1
			spawn player_view(10,src)<<sound('Super Namek.ogg',repeat=sound_repeat,volume=60)
		if("Ai Wo Torimodose")
			var/sound_repeat
			switch(alert(src,"Loop music?","Options","No","Yes"))
				if("Yes") sound_repeat=1
			spawn player_view(10,src)<<sound('Ai Wo Torimodose 2.ogg',repeat=sound_repeat,volume=60)
		if("Ai Wo Torimodose 2")
			var/sound_repeat
			switch(alert(src,"Loop music?","Options","No","Yes"))
				if("Yes") sound_repeat=1
			spawn player_view(10,src)<<sound('Ai Wo Torimodose.ogg',repeat=sound_repeat,volume=80)
		if("Pikkon")
			var/sound_repeat
			switch(alert(src,"Loop music?","Options","No","Yes"))
				if("Yes") sound_repeat=1
			spawn player_view(10,src)<<sound('PikkonsTheme.ogg',repeat=sound_repeat,volume=60)
		if("Vegeta")
			var/sound_repeat
			switch(alert(src,"Loop music?","Options","No","Yes"))
				if("Yes") sound_repeat=1
			spawn player_view(10,src)<<sound('Vegeta.ogg',repeat=sound_repeat,volume=60)
		if("Ssj Vegeta")
			var/sound_repeat
			switch(alert(src,"Loop music?","Options","No","Yes"))
				if("Yes") sound_repeat=1
			spawn player_view(10,src)<<sound('Ssj Vegeta.ogg',repeat=sound_repeat,volume=100)
		if("Ussj Trunks")
			var/sound_repeat
			switch(alert(src,"Loop music?","Options","No","Yes"))
				if("Yes") sound_repeat=1
			spawn player_view(10,src)<<sound('Ussj Trunks.ogg',repeat=sound_repeat,volume=60)
		if("Ginyu")
			var/sound_repeat
			switch(alert(src,"Loop music?","Options","No","Yes"))
				if("Yes") sound_repeat=1
			spawn player_view(10,src)<<sound('Ginyu.ogg',repeat=sound_repeat,volume=50)
		if("Cell the Boogieman")
			var/sound_repeat
			switch(alert(src,"Loop music?","Options","No","Yes"))
				if("Yes") sound_repeat=1
			spawn player_view(10,src)<<sound('Boogieman.ogg',repeat=sound_repeat,volume=70)
		if("Majin Buu")
			var/sound_repeat
			switch(alert(src,"Loop music?","Options","No","Yes"))
				if("Yes") sound_repeat=1
			spawn player_view(10,src)<<sound('BuuIsFighting.ogg',repeat=sound_repeat,volume=80)
		if("Cell powers up")
			var/sound_repeat
			switch(alert(src,"Loop music?","Options","No","Yes"))
				if("Yes") sound_repeat=1
			spawn player_view(10,src)<<sound('CellPowersUp.ogg',repeat=sound_repeat,volume=80)
		if("Prince of Saiyans")
			var/sound_repeat
			switch(alert(src,"Loop music?","Options","No","Yes"))
				if("Yes") sound_repeat=1
			spawn player_view(10,src)<<sound('PrinceofSaiyans.ogg',repeat=sound_repeat,volume=100)
		if("Super Buu")
			var/sound_repeat
			switch(alert(src,"Loop music?","Options","No","Yes"))
				if("Yes") sound_repeat=1
			spawn player_view(10,src)<<sound('SuperBuu.ogg',repeat=sound_repeat,volume=80)
	player_view(10,src)<<sound(0)	