--- Open up a new child process

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
local Process = require('uv').Process
local table = require('table')

local childProcess = {}


--- Spawn a new Child Process, returning the Event Emitter stream for
--- manipulation.
-- *Note: is this correct?*
-- @param command to run
-- @param arguments to pass to the command
-- @param any environmental options to pass to the child process
-- @return the new process Emitter
-- @usage local child = spawn('tail', {'-n 2'; './child-spawn.lua'}, {})
--child.stdout:on('data', function(chunk)
--    print(chunk)
--end)
-- @see child-spawn.lua
function childProcess.spawn(command, args, options)
  local env
  local envPairs = {}
  options = options or {}
  args = args or {}
  if options and options.env then
    env = options.env
  else
    env = process.env
  end

  for k, v in pairs(env) do
    table.insert(envPairs, k .. '=' .. v)
  end

  options.envPairs = envPairs

  return Process:new(command, args, options)
end

--- Execute a child command, stdout and stderr from the child process, along with the any errors encountered, are returned as parameters in the callback.
-- *Note: is the above correct?*
--
-- @param command to run
-- @param arguments to pass to the command
-- @param any environmental options to pass to the child process
-- @param callback {error, stdout, stdout}
-- @usage local exec = execFile('tail', {'./child-execfile.lua'}, {},
--   function(err, stdout, stderr)
--      p("stdout:", stdout)
--   end
--)
-- @see child-execfile.lua
function childProcess.execFile(command, args, options, callback)
  local child = childProcess.spawn(command, args, options)
  local stdout = {}
  local stderr = {}
  child.stdout:on('data', function (chunk)
    table.insert(stdout, chunk)
  end)
  child.stderr:on('data', function (chunk)
    table.insert(stderr, chunk)
  end)
  child:on('error', callback)
  child:on('exit', function (code, signal)
    callback(nil, table.concat(stdout, ""), table.concat(stderr, ""));
  end)
end

return childProcess

