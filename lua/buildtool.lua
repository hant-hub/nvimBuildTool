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
local win = nil

local function openwin()
    local valid = nil
    for _, handle in ipairs(vim.api.nvim_list_wins()) do
        if handle == win then
            valid = 1
            break
        end
    end

    if not valid then
        win = vim.api.nvim_open_win(buf, false, {
            split = "right",
            win = 0
        })
    end
end

local function buildoutput(obj)
    local lines = {}

    local formatbreak = false

    if obj.stdout then
        formatbreak = true
        for s in obj.stdout:gmatch("[^\r\n]+") do
            table.insert(lines, s)
        end
    end

    if obj.stderr then
        formatbreak = true
        for s in obj.stderr:gmatch("[^\r\n]+") do
            table.insert(lines, s)
        end
    end

    if formatbreak then
        table.insert(lines, "")
    end

    table.insert(lines, string.format("Signal: %d", obj.signal))
    table.insert(lines, string.format("Code: %d", obj.code))
    return lines
end

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
    
    local obj = vim.system({filetorun}, { text = true }, on_exit):wait(1000)
    openwin()

    local lines = buildoutput(obj)

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
    
    local obj = vim.system({filetorun}, { text = true }, on_exit):wait(1000)
    openwin()
    local lines = buildoutput(obj)

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

local function Clear()
    for _, handle in ipairs(vim.api.nvim_list_wins()) do
        if win == handle then
            vim.api.nvim_win_close(win, true)
            break
        end
    end
end


return { setup=setup, build=Build, run=Run, clear=Clear }
