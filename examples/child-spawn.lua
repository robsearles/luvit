--- Example of the `spawn` child process command
--
-- This example simply outputs the last two lines of this file and
-- informs the use when thie child process has exited.
-- It uses the `tail` command found on *nix platforms
-- Note: not tested on windows
local spawn = require('childprocess').spawn

local child = spawn('tail', {'-n 2'; './child-spawn.lua'}, {})
child.stdout:on('data', function(chunk)
    print(chunk)
end)
child:on("exit", function()
    print("exited")
end)
