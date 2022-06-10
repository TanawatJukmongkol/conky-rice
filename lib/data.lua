-- I didn't write my own JSON implimentation. I use this guy's
-- https://github.com/rxi/json.lua
-- Thx, rxi!

local json = require 'json'
local data = {}

-- CPU --
data.cpu = { cache = {} }
function data.cpu:raw ()
	local f = io.popen("grep 'cpu' /proc/stat")
	local raw_data = {}
	local i = 1
	for v in f:lines() do
		-- { cpuN:str, user:num, nice:num, system:num, idle:num, iowait:num, irq:num, softirq:num, 0x00 }
		raw_data[i] = string.split_trim(v, " ")
		-- convert string values to number
		for indx, str in pairs(raw_data[i]) do
			if indx > 1 then
				raw_data[i][indx] = tonumber(str)
			end
		end
		i = i + 1
	end
	f:close()
	return raw_data
end
function data.cpu:init ()
	data.cpu.raw_data = data.cpu:raw()
	for i = 0, #data.cpu.raw_data, 1 do
		data.cpu.cache[i] = { usage = 0, fq = 0 }
	end
end
function data.cpu:get (indx)
	return data.cpu.cache[indx + 1]
end
function data.cpu:each (fn)
	for indx = 1, #data.cpu.cache, 1 do fn(data.cpu.cache[indx], indx) end
end
function data.cpu:update ()
	-- CPU usage
	local next_data = data.cpu:raw()
	for i = 1, #next_data, 1 do
		local cpu_delta = 0
		local idle_delta = next_data[i][5] - data.cpu.raw_data[i][5]
		for indx, val in pairs(data.cpu.raw_data[i]) do
			if indx > 1 then cpu_delta = cpu_delta + next_data[i][indx] - val end
		end
		local cpu_used = cpu_delta - idle_delta
		data.cpu.cache[i].usage = 100 * (cpu_used / cpu_delta)
	end
	data.cpu.cache[1].usage = data.cpu.cache[1].usage
	data.cpu.raw_data = next_data
	-- CPU frequency
	local f = io.popen("grep '[c]pu MHz' /proc/cpuinfo | awk '{print $4}'")
	local ln = 1
	data.cpu.cache[1].fq = 0
	for line in f:lines(), 1 do
		data.cpu.cache[ln].fq = tonumber(string.format("%.2f", line))
		data.cpu.cache[1].fq = data.cpu.cache[1].fq + data.cpu.cache[ln].fq
		ln = ln + 1
	end
	data.cpu.cache[1].fq = tonumber(string.format("%.2f", data.cpu.cache[1].fq / (ln - 1)))
	f:close()
end
-- RAM --
data.ram = { cache = {} }
function data.ram:get (indx)
	return data.ram.cache
end
function data.ram:update ()
	data.ram.cache.usage = tonumber(conky_parse("$memperc"))
	data.ram.cache.usageStr = conky_parse("$mem")
end
-- Sensors --
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

-- Network --
data.network = { cache = {
	speed = { up = 0, down = 0 },
	max = { up = 0, down = 0 },
	percentSpeed = { up = 0, down = 0 }
} }
function data.network:init ()
	-- get the first network interface, then format it. (ie. auto detect network)
	local f = io.popen("ip link list | grep 'state UP' | awk '{print $2}'")
	local fstr = f:read()
	f:close()
	if fstr == nil then data.network.cache.interface = "No network" return end
	data.network.cache.interface = fstr:sub(1, -2)
end
function data.network:get (key)
	return data.network.cache[key]
end
function data.network:update ()
	local uspeedf = tonumber(conky_parse("${upspeedf ".. data.network.cache.interface .."}"))
	local dspeedf = tonumber(conky_parse("${downspeedf ".. data.network.cache.interface .."}"))
	data.network.cache.speed = { up = uspeedf, down = dspeedf }
	if data.network.cache.max.up < uspeedf then data.network.cache.max.up = uspeedf end
	if data.network.cache.max.down < dspeedf then data.network.cache.max.down = dspeedf end
	local percentup = data.network.cache.speed.up / data.network.cache.max.up
	if percentup == percentup then data.network.cache.percentSpeed.up = percentup end
	local percentdown = data.network.cache.speed.down / data.network.cache.max.down
	if percentdown == percentdown then data.network.cache.percentSpeed.down = percentdown end
end

return data;