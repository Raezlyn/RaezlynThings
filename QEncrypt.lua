--[[ QEncrypt ]]--
local version = "1.0.0"
local author = "Raezlyn"
local apiName = "QEncrypt"

function encrypt ( nString, nKey )
	nSeed = 0
	for i=1, nKey:len() do
		nSeed = nSeed+string.byte(nKey:sub(i,i))
	end
	nNew = ""
	math.randomseed = nSeed
	for i=1, nString:len() do
		nNew = nNew..string.char(math.random(string.byte(nString:sub(i,i))))
	end
	math.randomseed = "randomSeed"
	nSeed = nil
	return nNew
end