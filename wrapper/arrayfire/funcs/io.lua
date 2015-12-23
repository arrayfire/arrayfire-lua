--- IO functions.

-- Modules --
local af = require("arrayfire_lib")
local array = require("impl.array")

-- Imports --
local Call = array.Call
local CallWrap = array.CallWrap

-- Exports --
local M = {}

-- See also: https://github.com/arrayfire/arrayfire/blob/devel/src/api/cpp/imageio.cpp

local function LoadImage (filename, is_color)
	return CallWrap("af_load_image", filename, is_color)
end

--
local function SaveImage (filename, in_arr)
    Call("af_save_image", filename, in_arr:get())
end

--
function M.Add (into)
	for k, v in pairs{
		deleteImageMem = function(ptr)
			Call("af_delete_image_memory", ptr)
		end,

		--
		loadImage = LoadImage, loadimage = LoadImage,

		--
		loadImageMem = function(ptr)
			return CallWrap("af_load_image_memory", ptr)
		end,

		loadImageNative = function(filename)
			return CallWrap("af_load_image_native", filename)
		end,

		--
		saveImage = SaveImage, saveimage = SaveImage,

		--
		saveImageMem = function(in_arr, format)
			return Call("af_save_image_memory", in_arr:get(), af[format or "AF_FIF_PNG"])
		end,

		--
		saveImageNative = function(filename, in_arr)
			Call("af_save_image_native", filename, in_arr:get())
		end
	} do
		into[k] = v
	end
end

-- Export the module.
return M