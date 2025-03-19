local os = require('os')
local io = require('io')
local string = require('string')
local table = require('table')

local build_files = {
    "./build.sh",
    "./compile.sh",
}

local run_files = {
    "./run.sh",
    "./test.sh"
}

local buf = nil

local function Build()
    local dir = vim.fn.getcwd()
    local filetorun = nil

    for _, build_file in ipairs(build_files) do
        local script = vim.fn.filereadable(build_file)
        if script == 1 then filetorun = build_file end
    end

    if not filetorun then 
        print("Missing Script")
        return 
    end
    
    local obj = vim.system({filetorun}, { text = true }, on_exit):wait()
    vim.api.nvim_open_win(buf, false, {
        split = "right",
        win = 0
    })

    local lines = {}
    for s in obj.stdout:gmatch("[^\r\n]+") do
        table.insert(lines, s)
    end
    vim.api.nvim_buf_set_lines(buf, 0, -1, true, lines)
end

local function Run()
    local dir = vim.fn.getcwd()
    local filetorun = nil

    for _, run_file in ipairs(run_files) do
        local script = vim.fn.filereadable(run_file)
        if script == 1 then filetorun = run_file end
    end

    if not filetorun then 
        print("Missing Script")
        return 
    end
    
    local obj = vim.system({filetorun}, { text = true }, on_exit):wait()
    vim.api.nvim_open_win(buf, false, {
        split = "right",
        win = 0
    })

    local lines = {}
    for s in obj.stdout:gmatch("[^\r\n]+") do
        table.insert(lines, s)
    end
    vim.api.nvim_buf_set_lines(buf, 0, -1, true, lines)
end

local function setup()
    if not buf then
        buf = vim.api.nvim_create_buf(true, true)
    end
    vim.api.nvim_buf_set_name(buf, "BTOutput")

    vim.api.nvim_create_user_command('BTBuild', Build, {})
    vim.api.nvim_create_user_command('BTRun', Run, {})
end


return { setup=setup, build=Build, run=Run }
