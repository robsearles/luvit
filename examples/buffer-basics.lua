--- Buffer Testing
-- Some examples used to help write the Buffer Module documentation

-- Must include the `buffer` Luvit library
local Buffer = require('buffer').Buffer

-- Create our two example buffers
local buf1 = Buffer:new("Hello")
local buf2 = Buffer:new("World")

-- the Meta function __tostring()
p(buf1)

-- inspection method example 
p(buf1:inspect())

-- nice output with toString()
p(buf1:toString())

-- exmaple of using offsets
p(buf1:toString(2, 4))

-- concatenation
p(buf1.." "..buf2)

-- output the first byte(?) of the buffer. It does this using a decimal
-- representation
p(buf1[1])

-- modify the first byte(?) of the buffer. For this we must use a
-- hexadecimal representation, in this case, 0x68 = h
buf1[1] = 0x68

-- output to see the difference (again, decimal as above)
p(buf1[1])

-- just for fun
buf2[1] = 0x77
p(buf1.." "..buf2)

-- read 8, 16 and 32 bits of the buffer
p(buf1:readInt8(1))
p(buf1:readInt16BE(1))
p(buf1:readInt16LE(1))
p(buf1:readInt32BE(1))

-- iterate through the buffer
for index, value in ipairs(buf1) do
   p(index, value)
end




