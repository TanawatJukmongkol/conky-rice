-- Some codes here are adapted from StackOverflow.

string.seperator = function (str, sep, fn)
	if sep == nil then sep = "%s" end
	for s in str:gmatch("([^".. sep .. "]+)") do
		fn(s)
	end
end
string.split = function (str, sep)
	local t = {}
	string.seperator(str, sep, function ()
		table.insert(t, str)
	end)
	return t
end
string.trim = function (str)
	return str:match("^%s*(.-)%s*$")
end
string.split_trim = function (str, sep)
	local t = {}
	string.seperator(str, sep, function (s)
		if s ~= "" then table.insert(t, string.trim(s)) end
	end)
	return t
end