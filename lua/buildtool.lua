local os = require('os')
local io = require('io')
local string = require('string')
local table = require('table')


local function runBuild()
    print(vim.fn.getcwd())
end

local function setup()
    vim.api.nvim_create_user_command('RunBuild', runBuild, {})
end


return { setup=setup }
