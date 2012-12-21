--- Use and manipulate raw buffers
--
--### Example
--    local Buffer = require('buffer').Buffer
--    local buf1 = Buffer:new("Hello")
--    local buf2 = Buffer:new("World")
-- 
--    p(buf1:toString()) -- Hello
--    p(buf1.." "..buf2) -- "Hello World"
-- 
--    buf1[1] = 0x68
--    buf2[1] = 0x77
--    p(buf1.." "..buf2) -- "hello world"
-- 
--    p(buf1:readInt8(1)) -- 104
--    p(buf1:readInt16BE(1)) -- 26725
--
--### References
--
--* <http://en.wikipedia.org/wiki/Endianness>
--* <http://en.wikipedia.org/wiki/Signedness>
--
--### Note
-- The Buffer Module does not work with Windows.
--
-- @usage local Buffer = require('buffer').Buffer

--[[

Copyright 2012 The Luvit Authors. All Rights Reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS-IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

--]]

local table = require('table')
local Object = require('core').Object
local bit = require('bit')
local ffi = require('ffi')
ffi.cdef([[
  void *malloc (size_t __size);
  void free (void *__ptr);
]])

local buffer = {}

local Buffer = Object:extend()
buffer.Buffer = Buffer

--- Creation of the Buffer object
--
-- @param length int or string
-- @usage local buf1 = Buffer:new("Hello")
-- @usage local buf2 = Buffer:new(5) 
-- @see buffer-basics.lua
function Buffer:initialize(length)
  if type(length) == "number" then
    self.length = length
    self.ctype = ffi.gc(ffi.cast("unsigned char*", ffi.C.malloc(length)), ffi.C.free)
  elseif type(length) == "string" then
    local string = length
    self.length = #string
    self.ctype = ffi.cast("unsigned char*", string)
  else
    error("Input must be a string or number")
  end
end

--- Meta function to iterate through the Buffer table
-- @usage local buf1 = Buffer:new("Hello")
--for index, value in ipairs(buf1) do
--   p(index, value)
--end
-- -- Output:
-- -- 1	72
-- -- 2	101
-- -- 3	108
-- -- 4	108
-- -- 5	111
function Buffer.meta:__ipairs()
  local index = 0
  return function (...)
    if index < self.length then
      index = index + 1
      return index, self[index]
    end
  end
end

--- Return the signature for the Buffer contents
-- @usage local buf1 = Buffer:new("Hello")
-- p(buf1)
-- -- Output 
-- -- { ctype = cdata<unsigned char *>: 0x40678890, length = 5 }
function Buffer.meta:__tostring()
  return ffi.string(self.ctype)
end

--- Meta function to concatenate two buffers
-- @param other Another Buffer object
-- @return stringified representation of concatenated buffers
-- @usage local Buffer = require('buffer').Buffer
--local buf1 = Buffer:new("Hello")
--local buf2 = Buffer:new("World")
--p(buf1.." "..buf2) -- "Hello World"
function Buffer.meta:__concat(other)
  return tostring(self) .. tostring(other)
end

--- Meta function to get value at specified index of Buffer
-- @param index of value to retrieve
-- @return value at index
-- @usage local Buffer = require('buffer').Buffer
--local buf1 = Buffer:new("Hello")
-- p(buf1[1]) -- 72
function Buffer.meta:__index(key)
  if type(key) == "number" then
    if key < 1 or key > self.length then error("Index out of bounds") end
    return self.ctype[key - 1]
  end
  return Buffer[key]
end

--- Meta function to replace value at index with another
-- @param index of value to replace
-- @param value to replace
-- @usage local Buffer = require('buffer').Buffer
--local buf1 = Buffer:new("Hello")
--p(buf1[1]) -- 72
--buf1[1] = 0x68
-- p(buf1[1]) -- 104
function Buffer.meta:__newindex(key, value)
  if type(key) == "number" then
    if key < 1 or key > self.length then error("Index out of bounds") end
    self.ctype[key - 1] = value
    return
  end
  rawset(self, key, value)
end

--- Generates full contents of Buffer for inspection
-- @usage local Buffer = require('buffer').Buffer
--local buf1 = Buffer:new("Hello")
--p(buf1:inspect()) -- "<Buffer 48 65 6c 6c 6f>"
function Buffer:inspect()
  local parts = {}
  for i = 1, tonumber(self.length) do
    parts[i] = bit.tohex(self[i], 2)
  end
  return "<Buffer " .. table.concat(parts, " ") .. ">"
end

local function compliment8(value)
  return value < 0x80 and value or -0x100 + value
end


--- Reads the unsigned 8 bit integer from the Buffer located at specified offset
-- @param offset int
-- @return unsigned 8 bit integer
function Buffer:readUInt8(offset)
  return self[offset]
end

--- Reads the signed 8 bit integer from the Buffer located at specified offset
-- @param offset int
-- @return unsigned 8 bit integer
function Buffer:readInt8(offset)
  return compliment8(self[offset])
end

local function compliment16(value)
  return value < 0x8000 and value or -0x10000 + value
end

--- Reads the unsigned 16 bit integer from the Buffer located at
--- specified offset using Little Endian notaion
-- @param offset int
-- @return unsigned 16 bit integer
function Buffer:readUInt16LE(offset)
  return bit.lshift(self[offset + 1], 8) +
                    self[offset]
end
--- Reads the unsigned 16 bit integer from the Buffer located at
--- specified offset using Big Endian notaion
-- @param offset int
-- @return unsigned 16 bit integer
function Buffer:readUInt16BE(offset)
  return bit.lshift(self[offset], 8) +
                    self[offset + 1]
end
--- Reads the signed 16 bit integer from the Buffer located at
--- specified offset using Little Endian notaion
-- @param offset int
-- @return signed 16 bit integer
function Buffer:readInt16LE(offset)
  return compliment16(self:readUInt16LE(offset))
end
--- Reads the signed 16 bit integer from the Buffer located at
--- specified offset using Big Endian notaion
-- @param offset int
-- @return signed 16 bit integer
function Buffer:readInt16BE(offset)
  return compliment16(self:readUInt16BE(offset))
end

--- Read the unsigned 32 bit integer from the Buffer located at
--- specified offset using Little Endian notaion
-- @param offset int
-- @return unsigned 32 bit integer
function Buffer:readUInt32LE(offset)
  return self[offset + 3] * 0x1000000 +
         bit.lshift(self[offset + 2], 16) +
         bit.lshift(self[offset + 1], 8) +
                    self[offset]
end

--- Read the unsigned 32 bit integer from the Buffer located at
--- specified offset using Big Endian notaion
-- @param offset int
-- @return unsigned 32 bit integer
function Buffer:readUInt32BE(offset)
  return self[offset] * 0x1000000 +
         bit.lshift(self[offset + 1], 16) +
         bit.lshift(self[offset + 2], 8) +
                    self[offset + 3]
end


--- Read the unsigned 32 bit integer from the Buffer located at
--- specified offset using Little Endian notaion
-- @param offset int
-- @return signed 32 bit integer
function Buffer:readInt32LE(offset)
  return bit.tobit(self:readUInt32LE(offset))
end

--- Read the unsigned 32 bit integer from the Buffer located at
--- specified offset using Big Endian notaion
-- @param offset int
-- @return signed 32 bit integer
function Buffer:readInt32BE(offset)
  return bit.tobit(self:readUInt32BE(offset))
end

--- Stringify the Buffer contents, if offsets are provided, return
--- only those values within the offset range
-- @param i start of offset range
-- @param j end of offset range
-- @return string representation of Buffer
-- @usage local Buffer = require('buffer').Buffer
--local buf1 = Buffer:new("Hello")
--p(buf1:toString()) -- "Hello"
--p(buf1:toString(2, 4)) -- "ell"
function Buffer:toString(i, j)
  local offset = i and i - 1 or 0
  return ffi.string(self.ctype + offset, (j or self.length) - offset)
end

return buffer
