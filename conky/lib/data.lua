local json = require 'json'
local data = {}

data.cpu = {cache = {}}
function data.cpu:get (indx)
   return data.cpu.cache[indx]
end
function data.cpu:update ()
	local f = io.popen("grep 'cpu' /proc/stat | awk '{print ($2+$4)*100/($2+$4+$5)}'")
	data.cpu.cache = {}
	for line in f:lines() do
		data.cpu.cache[#data.cpu.cache + 1] = string.format("%g",string.format("%.1f", line))
	end
	f:close()
end

data.sensors = {cache = {}}
function data.sensors:get (arg)
	local t = data.sensors.cache
	for i, v in ipairs(arg or {}) do
        t = t[v]
    end
   	return t
end
function data.sensors:update ()
	local f = io.popen("sensors -jA")
	data.sensors.cache = json.decode(f:read("*a"))
	f:close()
end

return data;