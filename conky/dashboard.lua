print("Conky rice by Tanawat J.")

-- get the absolute home path, because conky is stupid.
local homePath = (function ()
	local f = io.popen("whoami")
	local usr = f:read("*a"):sub(1, -2)
	f:close()
	return "/home/" .. usr
end)()
-- -- Shorthand cus I'm lazy
local libPath = homePath .. "/.conky/lib/"
local assetsPath = homePath .. "/.conky/assets/"
-- define path for the lua libaray (.lua or .lc modules)
package.path = package.path .. ";"
	.. libPath .. "?.lua;"
	.. libPath .. "?.lc"
-- define path for the shared object libaray (c/c++ modules)
package.cpath = package.cpath .. ";"
	.. libPath .. "?.so"

local data = require 'data'
conky_dashboard = require 'canvas'

canvas.init = function ()
	io.write("Caching..." .. "\n")
	Image.png:cache(assetsPath .. "caffeine.png")
	-- unload the package table, since the local value is stored.
	for k, v in pairs(package.loaded) do
		io.write("unload module: " .. k .. "\n")
		package.loaded[k] = nil
	end
	collectgarbage("collect")
	io.write("garbadge collected!" .. "\n")
end

canvas.draw = function ()
	local img = Image:get(assetsPath .. "caffeine.png")
	Image:draw(img, canvas.width / 2 - img.w / 2, 25)
	font("Hack")
	-- Network speed
		-- upload speed
		colorHex(0xffff00, 0.69)
		text_center_center("▲ " .. conky_parse("${upspeed wlp3s0}"), img.x + img.w / 2 + 61, img.y + 67)
		-- download speed
		colorHex(0xfafafa, 0.20)
		line(img.x + img.w - 56, img.y + 120, img.x + img.w - 16, img.y + 112)
		colorHex(0xaaff00, 0.69)
		part_line(img.x + img.w - 56, img.y + 120, img.x + img.w - 16, img.y + 112, 0.75) -- the custom bar graph
		text_center_center("▼ " .. conky_parse("${downspeed wlp3s0}"), img.x + img.w / 2 + 68, img.y + 85)
	
	-- CPU
	data.cpu:update()
	colorHex(0xffffff, 0.69)
	text("CPU (".. data.cpu:get(2) .."%)", img.x-28, img.y + 47)
	text(conky_parse("$freq_g GHz"), img.x - 8, img.y + 60)
	-- RAM
	text("RAM " .. conky_parse("($memperc%)"), img.x + 70, img.y + img.h - 14)
	text(conky_parse("$mem"), img.x + 65, img.y + img.h - 2)
	-- Sensors
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
	local power_draw = data.sensors:get({"BAT1-acpi-0", "curr1", "curr1_input"}) * data.sensors:get({"BAT1-acpi-0", "in0", "in0_input"})
	text("Draw: " .. string.format("%g",string.format("%.1f", power_draw)) .. " W", img.x + img.w - 70, img.y + img.h - 10)
	colorHex(0xffaa00, 0.69)
	text(data.sensors:get({"BAT1-acpi-0", "curr1", "curr1_input"}) .. " A", img.x + img.w - 6, img.y + img.h - 10)
end
