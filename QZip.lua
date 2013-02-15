--[[ QZip ]]--
local version = "1.0.0"
local author = "Raezlyn"
local programName = "QZip"

local yielding = 100 -- Common Yielding Speed, if your CPU is slow you may want to lower this number. If it is fast, raise it.
-- Do not go above 150.
-- This is for loops that aren't meant to yield, if it loops <yielding> number of times, it'll yield(0). This way you don't get a yielding error.

local coloringYield = 350 -- How fast pixels can be displayed on the screen. N pixels per 0.05 seconds.
-- The reason this has a different yield is because this isn't very CPU intensive. Now yielding the variable above is for things like file operations.

-- Common Clearing
term.clear()
term.setCursorPos(1,1)

qzip = {}

function qzip.backgroundColor ( nColor ) -- Function for clearing the screen and flooding it with a certain color of your choice
	ScreenWidth, ScreenHeight = term.getSize()
	nYIELD = 1 -- Determining how many times it's looped.
	term.setCursorPos(1,1)
	term.clear()
	if type(nColor) ~= "number" then return false end
	term.setBackgroundColor(nColor)
	for i=1, ScreenHeight do
		nYIELD=nYIELD+1
		if nYIELD > coloringYield then
			nYIELD=1
			os.sleep(0)
		end
		print(string.rep(" ",ScreenWidth))
	end
	return true
end

function qzip.b1 ()
	qzip.backgroundColor(colors.white)
	term.setCursorPos(1,1)
	term.setBackgroundColor(colors.blue)
	term.setTextColor(colors.white)
	ScreenWidth, ScreenHeight = term.getSize()
	write(programName.." V."..version.." - "..author..string.rep(" ",ScreenWidth-(programName:len()+3+version:len()+3+author:len())-1))
	term.setBackgroundColor(colors.red)
	write("X")
	term.setCursorPos(2,3)
	term.setBackgroundColor(colors.red)
	term.setTextColor(colors.white)
	noption = "Directory/File:"
	write(noption)
	term.setCursorPos(2,4)
	term.setBackgroundColor(colors.gray)
	write(string.rep(" ",noption:len()+5))
	return true
end

function qzip.cread ()
	while true do
		if nString == nil then
			nString = ""
		end
		if nString:len() > noption:len()+4 then
			nBufferString = nString:sub(nString:len()-(noption:len()+5),nString:len())
		else
			nBufferString = nString..string.rep(" ",(noption:len()+5)-nString:len())
		end
		term.setCursorPos(2,4)
		write(nBufferString)
		action, char = os.pullEvent()
		if action == "char" then
			nString = nString..char
		end
		if action == "key" then
			if char == keys.backspace then
				if nString:len() > 0 then
					nString = nString:sub(1,nString:len()-1)
				end
			end
			if char == keys.space then
				nString = nString.." "
			end
			if char == keys.delete then
				nString = ""
			end
			if char == keys.enter then
				break
			end
		end
	end
	return nString
end

function qzip.eat ( nFile )
	handler=fs.open(nFile, "r")
	nFileD = {}
	nFileD.name = nFile
	nFileD.data = handler:readAll()
	handler:close()
	return nFileD
end

function split(pString, pPattern)
   local Table = {}  -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pPattern
   local last_end = 1
   local s, e, cap = pString:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
     table.insert(Table,cap)
      end
      last_end = e+1
      s, e, cap = pString:find(fpat, last_end)
   end
   if last_end <= #pString then
      cap = pString:sub(last_end)
      table.insert(Table, cap)
   end
   return Table
end

function qzip.revive ( nFile , nData )
	ak=io.open(nFile,"w")
	ak:write(nData)
	ak:close()
end

function qzip.zip ( nDir )
	if fs.isDir(nDir) then
		nDW = ""
		nJ = { dir=nDir }
		nDW = textutils.serialize(nJ).."\n"
		cDir = nDir
		for n,m in pairs(fs.list(nDir)) do
			if fs.isDir(nDir.."/"..m) == false then
				nDW = nDW..textutils.serialize(qzip.eat(nDir.."/"..m))
			end
		end
		return nDW
	else
		typeO = "nep"
		ax=fs.open(nDir,"r")
		nLines = split(ax,"\n")
		ax:close()
		for n,m in pairs(nLines) do
			nLines[n] = textutils.unserialize(m)
		end
		for k,v in pairs(nLines) do
			if v.dir ~= nil then
				fs.makeDir(v.dir)
			else
				qzip.revive(v.name, v.data)
			end
		end
		return "nice"
	end
end	

function qzip.main ()
	typeO = "depr"
	qzip.b1()
	dir = qzip.cread()
	term.setCursorPos(2,6)
	term.setTextColor(colors.blue)
	term.setBackgroundColor(colors.white)
	if fs.isDir(dir) then
		write("Zipping...")
	else
		write("Unzipping...")
	end
	nZipped = qzip.zip(dir)
	if typeO == "depr" then
	handler = io.open("NewZip.zip","w")
	handler:write(nZipped)
	handler:close()
	term.setCursorPos(2,6)
	term.setTextColor(colors.green)
	write("Zipping Complete!")
	term.setCursorPos(2,7)
	write("Saved to NewZip.zip!")
	os.sleep(2)
	qzip.backgroundColor(colors.black)
	else
	term.setCursorPos(2,6)
	term.setTextColor(colors.green)
	write("Unzipping Complete!")
	term.setCursorPos(2,7)
	write("All files revived.")
	os.sleep(2)
	qzip.backgroundColor(colors.black)
	end
end

function qzip.ethread ()
	while true do
		action, button, posix, posiy = os.pullEvent()
		if action == "mouse_click" then
			if button == 1 then
				scrw, scrh = term.getSize()
				if posix == scrw and posiy == scrh then
					return true
				end
			end
		end
	end
end

parallel.waitForAny ( qzip.main, qzip.ethread )