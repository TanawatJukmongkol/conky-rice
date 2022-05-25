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

function Image.png:cache (path, w, h)
	if Image.cache[path] == nil then
		Image.cache[path] = {}
		Image.cache[path].path = path
	end
	Image.cache[path].img = cairo_image_surface_create_from_png(path)
	Image.cache[path].w = (w == nil and cairo_image_surface_get_width(Image.cache[path].img)) or w
	Image.cache[path].h = (h == nil and cairo_image_surface_get_height(Image.cache[path].img)) or h
	return Image.cache[path]
end
function Image:draw (img, x, y)
	-- crazy ternary O.o
	local path = (img.path ~= nil and img.path) or (Image.cache[img] ~= nil and Image.cache[img])
	Image.cache[path].x = x
	Image.cache[path].y = y
	cairo_set_source_surface(canvas.ctx, Image.cache[path].img, x, y)
	cairo_paint(canvas.ctx)
	return Image.cache[path]
end
function Image:get (path)
	if Image.cache[path] == nil then return end
	Image.self = Image.cache[path]
	return Image.cache[path]
end
function font (font, size)
	cairo_set_font_face(canvas.ctx, font)
end
function colorHex (color, alpha)
	cairo_set_source_rgba(canvas.ctx, ((color / 0x10000) % 0x100) / 255., ((color / 0x100) % 0x100) / 255., (color % 0x100) / 255., (alpha or 1.0))
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
function line (x1, y1, x2, y2)
	cairo_new_path(canvas.ctx)
	cairo_line_to(canvas.ctx, x1, y1)
	cairo_line_to(canvas.ctx, x2, y2)
	cairo_stroke(canvas.ctx)
end
function part_line (x1, y1, x2, y2, percent)
	--remember, the coordinates system is not the same as mathematical coordinates.
	local rx = (x2 - x1) * percent -- x interpolation
	local ry = (y2 - y1) * percent -- y interpolation
	line(x1, y1, x1 + rx, y1 + ry)
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