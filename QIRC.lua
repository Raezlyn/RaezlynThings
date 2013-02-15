--[[ QIRC ]]--
local version = "1.0.0"
local author = "Raezlyn"
local programName = "QIRC"

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

Channel = "GLOBAL"
Nickname = "Anon"
ChatHistory = { [1]="Welcome! Use /join <channel> to get started!" }
ChatScrolled = 0

function cPrint ( nString )
	ox,oy = term.getCursorPos()
	scrWid, scrHei = term.getSize()
	term.setCursorPos(scrWid/2-nString:len()/2, oy)
	print(nString)
end

function MainDraw ()
	term.clear()
	term.setCursorPos(1,1)
	term.setBackgroundColor(colors.black)
	term.setTextColor(colors.white)
	cPrint(programName)
	term.setBackgroundColor(colors.blue)
	scrWid, scrHei = term.getSize()
	print(string.rep(" ",scrWid))
	term.setBackgroundColor(colors.black)
	scrWid, scrHei = term.getSize()
	term.setCursorPos(2,scrHei)
	write("> ")
end

function charRoll ()
	scrWid, scrHei = term.getSize()
	ChatBuffer = {}
	if #ChatHistory > scrHei-3 then
		for i=1, scrHei-3 do
			ChatBuffer[#ChatBuffer+1] = ChatHistory[#ChatHistory-(scrHei-4)+i]
		end
	else
		ChatBuffer = ChatHistory
	end
	for i=1, #ChatBuffer do
		term.setCursorPos(2,2+i)
		if ChatBuffer[i]:len() > scrWid-3 then
			ChatBuffer[i] = ChatBuffer[i]:sub(1,scrWid-4)..".."
		end
		print(ChatBuffer[i]..string.rep(" ",(scrWid-2)-ChatBuffer[i]:len()))
	end
end

commands = {}

function parseCommand ( nString )
	nAR = split(nString, " ")
	nAR[1] = nAR[1]:sub(2,nAR[1]:len())
	if commands[nAR[1]] ~= nil then
		commands[nAR[1]](unpack(nAR,2))
	else
		ChatHistory[#ChatHistory+1] = "No such command!"
	end
end

function chkT ( nString )
	if nString:sub(1,1) == "/" then return true else return false end
end

function broadcastN ( nString )
	rednet.broadcast(Nickname..": "..nString)
end

nicks = {}

function recN ()
	while true do
		act, sed, txt = os.pullEvent()
		if act == "rednet_message" then
			if txt == "/whois "..Nickname then
				broadcastN("* Was pinged!")
			end
			ChatHistory[#ChatHistory+1] = "("..tostring(sed)..") "..txt
			charRoll()
		end
	end
end

function setUp ()
	for n,m in ipairs(rs.getSides()) do
		rednet.close(m)
		rednet.open(m, Channel)
	end
end

function cread ()
	while true do
		if nStringd == nil then
			nStringd = ""
		end
		scrWid, scrHei = term.getSize()
		if nStringd:len() > scrWid-3 then
			nBufferString = nStringd:sub(nString:len()-(scrWid-3),nStringd:len())
		else
			nBufferString = nStringd..string.rep(" ",(scrWid-3)-nStringd:len())
		end
		term.setCursorPos(3,scrHei)
		write(nBufferString)
		action, char = os.pullEvent()
		if action == "char" then
			nString = nStringd..char
		end
		if action == "key" then
			if char == keys.backspace then
				if nString:len() > 0 then
					nStringd = nStringd:sub(1,nString:len()-1)
				end
			end
			if char == keys.space then
				nStringd = nStringd.." "
			end
			if char == keys.delete then
				nStringd = ""
			end
			if char == keys.enter then
				break
			end
		end
	end
	return nStringd
end

function cN ()
	while true do
		nmsg = cread()
		if nmsg == "/exit" then break end
		if nmsg == "" or nmsg == " " then
			ChatHistory[#ChatHistory+1]="Can't send empty message!"
			chatRoll()
		else
			if chkT(nmsg) == false then
				broadcastN(nmsg)
			else
				pasreCommand(nmsg)
			end
		end
		sleep(0)
	end
end

function commands.join ( nChan )
	os.sleep(0.5)
	Channel = nChan
	setUp()
	broadcastN("* Joined channel!")
end

function commands.whois ( nPers )
	rednet.broadcast("/whois "..nPers)
end

function commands.pm ( nID, nMSG )
	if tonumber(nID) == nil then
		ChatHistory[#ChatHistory+1] = "Invalid ID"
	else
		if nMSG ~= nil then
			rednet.send(nID, Nickname.."> "..nMSG)
		else
			ChatHistory[#ChatHistory+1] = "Can't send empty message!"
		end
	end
end

function commands.nick ( nNick )
	if nNick ~= nil then
		broadcastN("* Changed nickname to "..nNick)
		Nickname = nNick
	else
		chatHistory[#chatHistory+1] = "Must be valid nick!"
	end
end

MainDraw()

parallel.waitForAny(
	cN,
	recN
	)

term.clear()
term.setCursorPos(1,1)
scrWid, scrHei = term.getSize()
term.setBackgroundColor(colors.black)
term.setTextColor(colors.white)
for i=1, scrHei do
print(string.rep(" ",scrWid))
end
term.setCursorPos(1,1)
cPrint("Thanks for using this!")
cPrint("~Raezlyn")