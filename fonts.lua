require('common')

local imgui = require('imgui')

local M = {}

M.options = T{
    { label = 'Tahoma Bold (Default)', file = 'tahomabd.ttf' },
    { label = 'Agave', file = nil },
    { label = 'Tahoma', file = 'tahoma.ttf' },
    { label = 'Segoe UI', file = 'segoeui.ttf' },
    { label = 'Consolas', file = 'consola.ttf' },
    { label = 'Verdana', file = 'verdana.ttf' },
}

local base_size = 13
local cache = T{}
local pushed = false

local function font_directory()
    local root = os.getenv('SystemRoot') or os.getenv('windir') or 'C:\\Windows'
    return root:gsub('[/\\]+$', '') .. '\\Fonts\\'
end

local function readable(path)
    local file = io.open(path, 'rb')
    if file == nil then
        return false
    end
    file:close()
    return true
end

local function find_option(label)
    for _, option in ipairs(M.options) do
        if option.label == label then
            return option
        end
    end
    return M.options[1]
end

local function load_font(option)
    if option.file == nil then
        return nil
    end
    if cache[option.label] ~= nil then
        return cache[option.label] or nil
    end

    local path = font_directory() .. option.file
    if not readable(path) then
        cache[option.label] = false
        return nil
    end

    local ok, font = pcall(imgui.AddFontFromFileTTF, path, base_size)
    cache[option.label] = ok and font or false
    return cache[option.label] or nil
end

function M.prewarm()
    for _, option in ipairs(M.options) do
        load_font(option)
    end
end

function M.push(settings)
    if pushed then
        return
    end

    local option = find_option((settings and settings.font_family) or nil)
    local font = load_font(option)
    if font ~= nil and pcall(imgui.PushFont, font, base_size) then
        pushed = true
    elseif font ~= nil and pcall(imgui.PushFont, font) then
        pushed = true
    end
end

function M.pop()
    if pushed then
        imgui.PopFont()
        pushed = false
    end
end

function M.render_combo(settings)
    local current = find_option(settings.font_family).label
    if imgui.BeginCombo('Font', current) then
        for _, option in ipairs(M.options) do
            local selected = option.label == current
            if imgui.Selectable(option.label, selected) then
                settings.font_family = option.label
            end
            if selected then
                imgui.SetItemDefaultFocus()
            end
        end
        imgui.EndCombo()
    end
end

return M