require('arrayfire.lib')
require('arrayfire.defines')
local ffi  = require( "ffi" )
require 'string'

local Dim4 = {}
Dim4.__index = Dim4

setmetatable(
   Dim4,
   {
      __call = function(cls, ...)
         return cls.__init(...)
      end
   }
)

Dim4.__init = function(d1, d2, d3, d4)
   local self = setmetatable({d1 or 1, d2 or 1, d3 or 1, d4 or 1}, Dim4)
   return self
end

Dim4.__tostring = function(self)
   return string.format('[%d, %d, %d, %d]', self[1], self[2], self[3], self[4])
end

Dim4.ndims = function(self)
   for i = 4,1,-1 do
      if self[i] ~= 1 then
         return self[i] == 0 and 0 or i
      end
   end
   return self[1] == 0 and 0 or 1
end

af.Dim4 =Dim4
