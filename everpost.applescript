set singletaglist to {}
set multitaglist to {}
set alltaglist to {}
set allbulletlist to {}

--get the notes from Evernote
tell application "Evernote"
	set query_string to "notebook:\"linklog\" created:day-7" --get notes since last week
	set notities to find notes query_string --gives you list of relevant notes
	set notenum to count of notities
	repeat with notitie in notities
		--for every note fetch title, tags and source
		set titel to title of notitie
		set bron to source URL of notitie
		set taglist to tags of notitie
		set numtags to number of items in taglist
		--the taglist needs to be processed
		repeat with counter from 1 to numtags
			set tagtest to name of item counter of taglist
			--if tag already encountered it goes to multitaglist
			if (number of items in alltaglist is 0) then
				copy tagtest to end of alltaglist
			else
				if (alltaglist contains tagtest) then
					copy tagtest to end of multitaglist
					--if not encountered it goes to all tags
				else
					copy tagtest to end of alltaglist
				end if
			end if
		end repeat
		--fetch content and cut down to first line
		set inhoud to ENML content of notitie --gets you en xml, we want text between <en-note> and <hr>
		set AppleScript's text item delimiters to "<hr" --text to the left of first hr
		set sinhoud to text item 1 of inhoud
		set AppleScript's text item delimiters to "note>" --text to the right of <en-note>
		set tinhoud to text item 2 of sinhoud
		set AppleScript's text item delimiters to ""
		set inhoud to ""
		set sinhoud to ""
		set thisbullet to {titel, bron, tinhoud} --list of this particual ever note
		set end of allbulletlist to thisbullet
	end repeat
end tell
-- we got what we need from Evernote
-- we now have a list of all items, but need to look at tags to create the title of post
-- I want a title like Suggested reading: tag1, tag2, tag3 and more
-- where two tags are used more than once and one just once
-- alltaglist contains all tags used, multitaglist contains all tags occurring multiple times
-- now create a list of tags that are used once (basically alltags minus multitags)
set allnum to number of items in alltaglist
set doubles to number of items in multitaglist
repeat with counter from 1 to allnum
	if (multitaglist does not contain item counter of alltaglist) then copy item counter of alltaglist to end of singletaglist
end repeat
set singles to number of items in singletaglist
--I need 3 tags for the title, two used more than once, and one single. Unless there's not enough.
set posttitle to "Suggested Reading: "
if (allnum < 4) then
	-- too few tags, use them all
	repeat with counter from 1 to allnum - 1
		set posttitle to posttitle & item counter of alltaglist & ", "
	end repeat
	set posttitle to posttitle & item allnum of alltaglist & " and more"
else -- at least four tags available
	set takedouble to 2 --default value
	if (doubles < 2) then --take from doubles what possible
		set takedouble to doubles --0 or 1
	end if
	if (singles = 0) then -- take all from doubles
		set takedouble to 3
	end if --in all other cases default value works
	-- with value of takedouble now build posttitle
	if (takedouble = 3) then
		-- take first & last, and in the middle from doubles
		set middlelist to round doubles / 2 rounding up
		set posttitle to posttitle & item 1 of multitaglist & ", " & item middlelist of multitaglist & ", " & item doubles of multitaglist & " and more"
	end if
	if (takedouble = 2) then
		-- take first & last  from doubles, first from singles
		set posttitle to posttitle & item 1 of multitaglist & ", " & item 1 of singletaglist & ", " & item doubles of multitaglist & " and more"
	end if
	if (takedouble = 1) then
		-- take first from doubles, first and last from singles
		set posttitle to posttitle & item 1 of multitaglist & ", " & item 1 of singletaglist & ", " & item singles of singletaglist & " and more"
	end if
	if (takedouble = 0) then
		-- take first middle & last,from singles
		set middlelist to round singles / 2 rounding up
		set posttitle to posttitle & item 1 of singletaglist & ", " & item middlelist of singletaglist & ", " & item singles of singletaglist & " and more"
	end if
end if
-- we now can start building the blog posting
-- title is available posttitle
-- now let's build the html for the posting
--first opening line and start of UL
set blogpostext to "<p>Some links I thought worth reading the past few days</p><p><ul>"
--for each bullet in bulletlist a new LI
--with the blurb, and the title as href to the link 
repeat with listitem in allbulletlist
	set thislisitem to "<li>" & item 3 of listitem & ": <a href=\"" & item 2 of listitem & "\">" & item 1 of listitem & "</a></li>"
	set blogpostext to blogpostext & thislisitem
end repeat
--end the ul started at the top
set blogpostext to blogpostext & "</ul></p>" --we got it all now
--mail it to wordpress cat linklog, tags all tags, title and body.
--the content of the mail is determined by the Postie plugin settings 
--the plugin used in my Wordpress
-- cat and title in subject, rest in body: delay to post must come first, then body, then tags after one empty line
set mailsubject to "standard//[Linklog] " & posttitle
set tagtext to ""
repeat with counter from 1 to allnum - 1
	set tagtext to tagtext & item counter of alltaglist & ", "
end repeat
set tagtext to tagtext & item allnum of alltaglist
set mailbody to "delay: 1d 
"
set mailbody to mailbody & ":start " & blogpostext & "

tags: " & tagtext --don't use :end delimiter

--now send it as email
tell application "Mail"
	set myMessage to make new outgoing message with properties {sender:"your@mail.com", subject:mailsubject, content:mailbody}
	tell myMessage
		make new to recipient with properties {address:"yoursecret@blogmail.com"}
	end tell
	send myMessage
	delay 5 --wait for the mail to be processed
	quit --quit Mail as I don't use it for anything else
end tell