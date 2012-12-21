--- Example of the `spawn` child process command
--
-- This example simply outputs the last two lines of this file
-- It uses the `tail` command found on *nix platforms
-- Note: not tested on windows
local execFile = require('childprocess').execFile

local exec = execFile('tail', {'./child-execfile.lua'}, {},
   function(err, stdout, stderr)
      p("stdout:", stdout)
      p("stderr:", stderr)
   end
)
