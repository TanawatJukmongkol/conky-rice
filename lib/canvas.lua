-- Cairo documentation, if you want to get into the weeds (not that weed, I mean uh.. haha.. idiomatic weed).
-- https://luapower.com/cairo

-- If you don't understand this libaray, you can use [Ctrl]+[F] to find the function you want to know (self explanitory, with comments).

require 'cairo'

local extents = cairo_text_extents_t:create()
tolua.takeownership(extents)

canvas = {
	surface = nil,
	ctx = nil
}
canvas.init = nil
canvas.draw = nil

Image = {
	cache = {},
	png = {},
	self = nil
}

-- Images --
function Image.png:cache (path, w, h) -- path = path to image (absolute, cus conky dum), w* = width[px], h* = height[px]
	if Image.cache[path] == nil then
		Image.cache[path] = {}
		Image.cache[path].path = path
	end
	Image.cache[path].img = cairo_image_surface_create_from_png(path)
	Image.cache[path].w = (w == nil and cairo_image_surface_get_width(Image.cache[path].img)) or w
	Image.cache[path].h = (h == nil and cairo_image_surface_get_height(Image.cache[path].img)) or h
	return Image.cache[path]
end
function Image:draw (img, x, y) -- img = Image:get("path to image") or Image:get(imgCache), x = position[px], y = position[px]
	-- crazy ternary O.o
	-- if path != nil then return path, else if cache[img] != nil then return cache[img]
	local path = (img.path ~= nil and img.path) or (Image.cache[img] ~= nil and Image.cache[img])
	Image.cache[path].x = x
	Image.cache[path].y = y
	cairo_set_source_surface(canvas.ctx, Image.cache[path].img, x, y)
	cairo_paint(canvas.ctx)
	return Image.cache[path]
end
function Image:get (path) -- path = path to image (absolute, cus conky dum)
	if Image.cache[path] == nil then return end
	Image.self = Image.cache[path]
	return Image.cache[path]
end

-- Color --
function fill (r, g, b, a)
	cairo_set_source_rgba(canvas.ctx, r/255, g/255, b/255, a or 1.0)
	cairo_fill(canvas.ctx, r/255, g/255, b/255, a or 1.0)
end
function color (r, g, b, a)
	cairo_set_source_rgba(canvas.ctx, r/255, g/255, b/255, a or 1.0)
end
function colorHex (color, alpha)
	cairo_set_source_rgba(canvas.ctx, ((color / 0x10000) % 0x100) / 255., ((color / 0x100) % 0x100) / 255., (color % 0x100) / 255., (alpha or 1.0))
end

-- Text --
function font (font, size, bold, italic) -- bold = is bold font [boolean true/false] -- italic = is font italic [boolean true/false]
	cairo_select_font_face(canvas.ctx, font, (italic and 1) or CAIRO_FONT_SLANT_NORMAL, (bold and 1) or CAIRO_FONT_SLANT_NORMAL)
	cairo_set_font_size(canvas.ctx, size or 10)
end
function text (msg, x, y)
  	cairo_move_to(canvas.ctx, x, y)
	cairo_show_text(canvas.ctx, msg)
end
function text_center_center (msg, x, y)
	cairo_text_extents(canvas.ctx, msg, extents)
	local TxtX = -(extents.width/2 + extents.x_bearing)
	local TxtY = -(extents.height/2 + extents.y_bearing)
	text(msg, x + TxtX, y + TxtY)
end

-- Lines / path --
function stroke_width (w)
	cairo_set_line_width(canvas.ctx, w)
end
function line (x1, y1, x2, y2)
	cairo_new_path(canvas.ctx)
	cairo_line_to(canvas.ctx, x1, y1)
	cairo_line_to(canvas.ctx, x2, y2)
	cairo_stroke(canvas.ctx)
end
function part_line (x1, y1, x2, y2, percent)
	local rx = (x2 - x1) * percent -- x interpolation
	local ry = (y2 - y1) * percent -- y interpolation
	line(x1, y1, x1 + rx, y1 + ry)
end

-- Shapes --
function rect (x, y, w, h)
	cairo_rectangle(canvas.ctx, x, y, w, h)
end

-- Graphs --
function bar_graph (x1, y1, x2, y2, percent, bk, fg, a) -- bk = background color [hex], fg = foreground color [hex], a = alpha (opacity) [0 to 1]
	local rx = x1 + (x2 - x1) * percent
	local ry = y1 + (y2 - y1) * percent
	colorHex(bk, a / 2) -- background
	line(rx, ry, x2, y2)
	colorHex(fg, a) -- foreground
	line(x1, y1, rx, ry)
end

return function ()
	if conky_window == nil then return end
	if  canvas.width ~= conky_window.width or
		canvas.height ~= conky_window.height
	then
		canvas.width = conky_window.width
		canvas.height = conky_window.height
		canvas.surface = cairo_xlib_surface_create (
			conky_window.display, conky_window.drawable, conky_window.visual,
			canvas.width, canvas.height
		)
		canvas.ctx = cairo_create(canvas.surface)
		canvas.init()
		cairo_surface_destroy(canvas.surface) -- To distroy previous surfaces.
	end
	canvas.draw()
end