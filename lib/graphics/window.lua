--- Windows and their methods.

-- Standard library imports --
local getmetatable = getmetatable
local rawequal = rawequal
local type = type

-- Modules --
local af = require("arrayfire_lib")
local array = require("impl.array")

-- Imports --
local Call = array.Call
local IsArray = array.IsArray
local GetLib = array.GetLib

-- Exports --
local M = {}

-- See also: https://github.com/arrayfire/arrayfire/blob/devel/src/api/cpp/graphics.cpp

--
local TempCell = {}

--
local function Temp (window, title, how)
	TempCell.row, TempCell.col = window._r, window._c
	TempCell.title = title
	TempCell.cmap = how == "use_cmap" and window._cmap or af.AF_COLORMAP_DEFAULT

	return TempCell
end

-- --
local Window = {}

local MetaValue = {}

--
Window.__index = Window
Window.__metatable = MetaValue

--- DOCME
function Window:__call (r, c)
	self._r, self._c = r, c

	return self
end

-- __gc =     AF_THROW(af_destroy_window(wnd));

--
local function Get (window)
-- TODO: Use a proxy to gc the window...
	return window.wnd
end

--- DOCME
function Window:close ()
    return Call("af_is_window_closed", Get(self))
end

--- DOCME
function Window:destroy ()
	if not self:close() then
		Call("af_destroy_window", Get(self))
	end
end

--- DOCME
function Window:grid (rows, cols)
    Call("af_grid", Get(self), rows, cols)
end

--- DOCME
function Window:hist (X, minval, maxval, title)
    Call("af_draw_hist", Get(self), X:get(), minval, maxval, Temp(self, title))
end

--- DOCME
function Window:image (in_arr, title)
    Call("af_draw_image", Get(self), in_arr:get(), Temp(self, title, "use_cmap"))
end

--- DOCME
function Window:plot (X, Y, title)
    Call("af_draw_plot", Get(self), X:get(), Y:get(), Temp(self, title))
end

function Window:plot3 (P, title)
    P:eval()

    Call("af_draw_plot3", Get(self), P:get(), Temp(self, title))
end

--[[
3.3
void Window::scatter(const array& X, const array& Y, af::markerType marker, const char* const title)
{
    af_cell temp{_r, _c, title, AF_COLORMAP_DEFAULT};
    AF_THROW(af_draw_scatter(get(), X.get(), Y.get(), marker, &temp));
}

void Window::scatter3(const array& P, af::markerType marker, const char* const title)
{
    af_cell temp{_r, _c, title, AF_COLORMAP_DEFAULT};
    AF_THROW(af_draw_scatter3(get(), P.get(), marker, &temp));
}
]]

--- DOCME
function Window:setPos (x, y)
    Call("af_set_position", Get(self), x, y)
end

--- DOCME
function Window:setTitle (title)
    Call("af_set_title", Get(self), title)
end

--- DOCME
function Window:setSize (w, h)
    Call("af_set_size", Get(self), w, h)
end

--- DOCME
function Window:setColorMap (cmap)
    self._cmap = af[cmap]
end

--- DOCME
function Window:show ()
    Call("af_show", Get(self))

    self._r, self._c = -1, -1
end

function Window:surface (a, b, c, d)
	local xVals, yVals, title

	if IsArray(b) then -- a: xVals, b: yVals, c: S, d: title
		xVals, yVals, title = a, b, d
	else -- a: S, b: title
		local lib = GetLib()

		xVals = lib.array(lib.seq(0, c:dims(0) - 1))
		yVals = lib.array(lib.seq(0, c:dims(0) - 1))
		title = b
	end

    Call("af_draw_surface", Get(self), xVals:get(), yVals:get(), S:get(), Temp(self, title))
end

--
local function Set (window, handle)
	window.wnd = handle -- TODO: note about proxy...
end

--
local function InitWindow (window, w, h, title)
    Set(window, Call("af_create_window", w, h, title or "ArrayFire"))
end

--
function M.Add (into)
	for k, v in pairs{
		--
		IsWindow = function(item)
			return rawequal(getmetatable(item), MetaValue)
		end,

		--
		Window = function(a, b, c)
			local window = { cnd = 0, _r = -1, _c = -1, _cmap = af.AF_COLORMAP_DEFAULT }

			if a == nil or type(a) == "string" then -- a: title
				InitWindow(window, 1280, 720, a)
			elseif b then -- a: width, b: height, c: title
				InitWindow(window, a, b, c)
			else -- a: window
				Set(window, a)
			end

			return setmetatable(window, Window)
		end
	} do
		into[k] = v
	end
end

-- Export the module.
return M