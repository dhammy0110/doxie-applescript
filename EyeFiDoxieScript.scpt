-- Doxie Process Script
--
-- This AppleScript is used to automatically process images 
-- coming from to a Doxie scanner without user intervention.
--
-- The Doxie program does not correctly date stamp images, 
-- so this does the next best thing. Best used with the 
-- Eye-Fi card and a folder action, it will open the Doxie.app 
-- and save as a PDF with OCR to a specific folder 
-- (e.g. Dropbox, Google Drive).
-- 
-- 2014 Damon Hamm
-- Last update 2014.1.18


-- initialize the main variables and run
set destinationFolder to "/Users/<username>/<yourpath>/"
set myApp to "Doxie"
set fName to "/Users/<username>/<yourpath>/" -- this was easier than dynamically pulling the folder name the script is attached to


-- when triggered by a folder action, 
-- test for all transfers to be complete, then run main program
if folderReady(fName) then
	try
		runMyApp(myApp, destinationFolder)
	end try
end if


-- wait until all files are finished transferring
on folderReady(fName)
	set startSize to size of (info for fName) --get current folder size
	delay 5
	set newSize to size of (info for fName)
	repeat until startSize is equal to newSize --loop until equal
		set startSize to newSize --reset current size
		delay 5
		set newSize to size of (info for fName)
	end repeat
	return true
end folderReady



-- runs the App Process
on runMyApp(myApp, destinationFolder)
	activate application myApp
	-- pause to let program start up
	delay 5
	try
		set exitloop to 0
		tell application "System Events" to tell process myApp
			set exitloop to 0
			log "import timer exitloop = " & (exitloop)
			
			set frontmost to true
			
			-- pause to let importing finish
			repeat while exists sheet "Doxie Import" of window myApp
				delay 0.2
				set exitloop to exitloop + 1
				log "import timer exitloop = " & (exitloop)
				if exitloop ≥ 1500 then
					log "import stuck timeout"
					return
				end if
			end repeat
		end tell
		
		tell application "System Events" to tell process myApp
			set frontmost to true
			repeat until frontmost is true
				delay 0.1
			end repeat
			-- Select All (Press ⌘A)
			keystroke "a" using {command down}
		end tell
		
		delay 0.5
		
		tell application "System Events" to tell process myApp
			set frontmost to true
			repeat until frontmost is true
				delay 0.1
			end repeat
			-- Select save as PDF b&w with OCR (Press ⌥⌘S)
			keystroke "s" using {option down, command down}
			
			-- pause until save dialog appears
			set exitloop to 0
			repeat until exists sheet 1 of window myApp
				delay 0.1
				set exitloop to exitloop + 1
				log "save not available exitloop = " & (exitloop)
				if exitloop ≥ 50 then
					log "save function not available timeout"
					return
				end if
			end repeat
		end tell
		tell application "System Events" to tell process myApp
			set frontmost to true
			repeat until frontmost is true
				delay 0.1
			end repeat
			-- Press ⌘⇧g to open open the finder folder selector
			tell window myApp
				keystroke "g" using {command down, shift down}
				
				-- wait for the finder folder sheet to open
				set exitloop to 0
				repeat until exists sheet 1
					delay 0.2
					set exitloop to exitloop + 1
					log "open finder folder exitloop = " & (exitloop)
					if exitloop ≥ 50 then
						log "open finder folder timeout"
						return
					end if
				end repeat
				
				
				-- set the file path and press 'go'
				tell sheet 1
					set value of text field of sheet 1 to destinationFolder
					click button "Go" of sheet 1
					
					-- wait for the sheet to close
					set exitcount to 0
					repeat while exists sheet 1
						delay 0.2
						set exitloop to exitloop + 1
						if exitloop ≥ 50 then
							log "close finder folder timeout"
							return
						end if
					end repeat
				end tell
				
				-- save the sheet using whichever button is present at the time (for some reason it varies)
				if exists (button "Choose" of sheet 1) then
					click button "Choose" of sheet 1
				else
					click button "Save" of sheet 1
				end if
				
				delay 0.2
				--get entire contents of front window
				-- get every UI element
				
				set exitcount to 0
				
				-- wait for saving to complete
				repeat while exists sheet "Saving Scans..."
					log "save function running, exitloop = " & exitloop
					delay 0.2
					set exitloop to exitloop + 1
					if exitloop ≥ 1500 then
						log "save function timeout"
						return
					end if
				end repeat
				
			end tell
		end tell
		tell application "System Events" to tell process myApp
			set frontmost to true
			repeat until frontmost is true
				delay 0.1
			end repeat
			
			-- close the app using keystrokes
			keystroke "q" using {command down}
			
			-- wait for quit dialog to appear, let system handle timeout
			repeat until exists button "Delete" of sheet 1 of window myApp
				log "waiting for quit & delete options dialog"
				delay 0.2
			end repeat
			set frontmost to true
			
			-- answer question to delete all saved files
			click button "Delete" of sheet 1 of window myApp
			
			
		end tell
	end try
end runMyApp