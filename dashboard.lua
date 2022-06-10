print("Conky rice by Tanawat J.")

-- Conky + Lua documentation
-- http://conky.sourceforge.net/lua.html

-- get the absolute home path, because conky is stupid.
-- (I know, this looks cursed, but we have to define some path or else it will not work.)
local homePath = (function ()
	local f = io.popen("whoami")
	local usr = f:read()
	f:close()
	return "/home/" .. usr
end)()
-- Shorthand cus I'm lazy
local libPath = homePath .. "/.conky/lib/"
local assetsPath = homePath .. "/.conky/assets/"
-- define path for the lua library (.lua or .lc modules)
package.path = package.path .. ";"
	.. libPath .. "?.lua;"
	.. libPath .. "?.lc"
-- define path for the shared object library (c/c++ modules)
package.cpath = package.cpath .. ";"
	.. libPath .. "?.so"

-- require your modules here.
	require 'string_extended'
	-- local modules
	local data = require 'data'
	-- global modules
	conky_dashboard = require 'canvas' -- my own mini cairo wrapper library!

-- initialize the canvas
canvas.init = function ()
	io.write("Caching..." .. "\n")
	data.cpu:init()
	data.network:init()
	Image.png:cache(assetsPath .. "caffeine.png")
	-- unload the package table, since the local value is stored.
	io.write("Emptying module cache memory..." .. "\n")
	for k, v in pairs(package.loaded) do
		io.write("unload module: " .. k .. "\n")
		package.loaded[k] = nil
	end
	collectgarbage("collect")
	io.write("garbadge collected!" .. "\n")
end

-- variables define here.
local dt = 0
local img
local power_draw
local speed_up
local speed_down

canvas.draw = function ()
	img = Image:get(assetsPath .. "caffeine.png")
	Image:draw(img, canvas.width / 2 - img.w / 2, 25)
	font("Hack")
	-- Network speed --
	if dt % 5 == 1 then data.network:init() end -- tries to reconnect to a network if no network was detected.
	data.network:update()
	speed_up = data.network:get("percentSpeed").up
	speed_down = data.network:get("percentSpeed").down
		colorHex(0x68b0c0, 1)
		stroke_width(2)
		text_center_center(data.network.cache.interface, img.x + img.w / 2 + 70, img.y + 92)
		-- upload speed
		bar_graph(img.x + img.w - 52, img.y + 42, img.x + img.w - 16, img.y + 58, speed_up, 0xa0a0a0, 0xffff00, 0.76)
		colorHex(0xffff00, speed_up == 0 and 0.42 or 0.76)
		text_center_center("▲ " .. data.network:get("speed").up .. "KiB", img.x + img.w / 2 + 61, img.y + 67)
		-- download speed
		bar_graph(img.x + img.w - 56, img.y + 120, img.x + img.w - 16, img.y + 112, speed_down, 0xa0a0a0, 0xaaff00, 0.76)
		colorHex(0xaaff00, speed_down == 0 and 0.42 or 0.76)
		text_center_center("▼ " .. data.network:get("speed").down .. "KiB", img.x + img.w / 2 + 68, img.y + 80)
	-- CPU --
	data.cpu:update()
	colorHex(0xafcfff, 0.69)
	stroke_width(2.24)
	text_center_center("CPU (".. string.format("%.2f", data.cpu:get(0).usage) .."%)", img.x+4, img.y + 47)
	text_center_center(data.cpu:get(0).fq .. " Hz", img.x + 4, img.y + 58)
	bar_graph(img.x + 40.5, img.y + 127, img.x + 70.5, img.y + 75, data.cpu:get(0).usage/100, 0xacabbb, 0xafafff, 0.76)

	data.cpu:each(function (core, indx)
		--for indx = 1, 12, 1 do
		if indx > 32 then return end -- prevent overflow
		--fill(255, 255, 255, 1)
		--text(string.format("%.2f", core.usage), img.x-18 + (indx % 5) * 25, img.y + 70 + math.floor(indx / 5) * 10, 4, 4)
		fill(math.sin(core.usage / 100) * 255, math.cos(core.usage/100) * 255, 120, 0.69)
		if #data.cpu.cache >= 12 then
			rect(img.x + (indx - 2) % 5.1 * 11 - indx * 0.7, img.y + 70 + math.floor((indx - 2) / 5.1) * 8, 4, 4)
		elseif #data.cpu.cache >= 4 then
			rect(img.x + (indx - 1) % 4.1 * 11 - indx * 0.7, img.y + 70 + math.floor((indx - 1) / 4.1) * 8, 4, 4)
		end
		--end
	end)
	
	-- RAM --
	data.ram:update()
	colorHex(0xffaaaa, 0.69)
	text("RAM (" .. data.ram:get().usage .. "%)", img.x + 70, img.y + img.h - 14)
	colorHex(0xffeeee, 0.69)
	text(data.ram:get().usageStr, img.x + 65, img.y + img.h - 2)
	bar_graph(img.x + 69, img.y + 176.5, img.x + 128, img.y + 176.5, data.ram:get().usage/100, 0xddaaaa, 0xffaaaa, 0.76)
	-- Sensors --
	data.sensors:update()
	colorHex(0xddddff, 0.69)
	text("Sensors", img.x + img.w - 42, img.y + img.h - 74)
	colorHex(0xaaffff, 0.69)
	text("FAN: " .. data.sensors:get({"asus-isa-0000", "cpu_fan", "fan1_input"}) .. " RPM", img.x + img.w - 65, img.y + img.h - 60)
	colorHex(0xaaccff, 0.69)
	text("NVME: " .. data.sensors:get({"nvme-pci-0400", "Composite", "temp1_input"}) .. " °C", img.x + img.w - 70, img.y + img.h - 50)
	colorHex(0xaaffcc, 0.69)
	text("APCI: " .. data.sensors:get({"acpitz-acpi-0", "temp1", "temp1_input"}) .. " °C", img.x + img.w - 75, img.y + img.h - 40)
	colorHex(0xaaff00, 0.69)
	text("PCIe: " .. data.sensors:get({"k10temp-pci-00c3", "Tctl", "temp1_input"}) .. " °C", img.x + img.w - 80, img.y + img.h - 30)
	colorHex(0xffff00, 0.69)
	text("Battery: " .. data.sensors:get({"BAT1-acpi-0", "in0", "in0_input"}) .. " V", img.x + img.w - 75, img.y + img.h - 20)
	colorHex(0x00aaff, 0.69)
	power_draw = data.sensors:get({"BAT1-acpi-0", "curr1", "curr1_input"}) * data.sensors:get({"BAT1-acpi-0", "in0", "in0_input"})
	text("Draw: " .. string.format("%g",string.format("%.1f", power_draw)) .. " W", img.x + img.w - 70, img.y + img.h - 10)
	colorHex(0xffaa00, 0.69)
	text(string.format("%.2f", data.sensors:get({"BAT1-acpi-0", "curr1", "curr1_input"})) .. " A", img.x + img.w - 2, img.y + img.h - 10)
	-- increment delta time
	dt = dt + 1
	if dt == 1000 then dt = 0 end
end
