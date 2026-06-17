addon.name = 'golddigger'
addon.author = 'Lydya'
addon.version = '0.4.0'
addon.desc = 'Chocobo digging addon based on Hgather.'
addon.commands = { '/golddigger', '/gd' }

require('common')
local chat = require('chat')
local imgui = require('imgui')
local settings = require('settings')
local struct = require('struct')
local data = dofile(addon.path .. 'constants.lua')
local create_ui = dofile(addon.path .. 'ui.lua')
local create_core = dofile(addon.path .. 'core.lua')
local sound_player = dofile(addon.path .. 'sound.lua')

local default_settings = T{
    visible = true,
    auto_show_on_dig = true,
    auto_clear_on_jp_reset = false,
    show_moon = true,
    show_last_item = true,
    show_ore = true,
    show_rewards = true,
    show_zone_items = true,
    font_scale = 1.20,
    window_alpha = 0.95,
    dig_skill = 0,
    rankup_sound_volume = 50,
    reset_on_load = false,
    dig_rewards = T{},
    dig_items = 0,
    dig_tries = 0,
}

local state = T{
    settings = settings.load(default_settings),
    visible = { true },
    config_visible = { false },
    last_attempt = 0,
    last_item = '',
    attempt_type = '',
    area_delay = {
        active = false,
        end_ms = 0,
        ready = false,
        pending_start = false,
        mounted_since_ms = 0,
        was_mounted = false,
    },
    dig_delay = {
        active = false,
        end_ms = 0,
        ready = false,
    },
    digging = T{
        dig_timing = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
        dig_index = 1,
        dig_per_minute = 0,
        dig_skillup = 0.0,
        zone_empty = { false },
    },
    greens_cache = {
        count = 0,
        next_update_ms = 0,
    },
    environment_cache = {
        weather = 'Unknown',
        moon = { phase = 'Unknown', percent = 0 },
        next_update_ms = 0,
    },
    jp_reset = {
        last_day_key = nil,
    },
}

local core
local ui
local function apply_settings(s)
    if s ~= nil then
        state.settings = s
    end

    state.settings.visible = state.settings.visible == true
    state.settings.auto_show_on_dig = state.settings.auto_show_on_dig ~= false
    state.settings.auto_clear_on_jp_reset = state.settings.auto_clear_on_jp_reset == true
    state.settings.show_moon = state.settings.show_moon ~= false
    state.settings.show_last_item = state.settings.show_last_item ~= false
    state.settings.show_ore = state.settings.show_ore ~= false
    state.settings.show_rewards = state.settings.show_rewards ~= false
    state.settings.show_zone_items = state.settings.show_zone_items ~= false
    state.settings.font_scale = math.max(0.8, math.min(1.6, tonumber(state.settings.font_scale) or default_settings.font_scale))
    state.settings.window_alpha = math.max(0.3, math.min(1.0, tonumber(state.settings.window_alpha) or default_settings.window_alpha))
    state.settings.dig_skill = math.max(0, tonumber(state.settings.dig_skill) or default_settings.dig_skill)
    state.settings.rankup_sound_volume = math.max(0, math.min(100, tonumber(state.settings.rankup_sound_volume) or default_settings.rankup_sound_volume))
    state.settings.reset_on_load = state.settings.reset_on_load == true
    state.settings.dig_items = math.max(0, tonumber(state.settings.dig_items) or 0)
    state.settings.dig_tries = math.max(0, tonumber(state.settings.dig_tries) or 0)
    state.settings.dig_rewards = state.settings.dig_rewards or T{}

    state.visible[1] = state.settings.visible == true
    state.config_visible[1] = false
end

settings.register('settings', 'golddigger_settings', apply_settings)
apply_settings(state.settings)

local function print_message(message)
    print(chat.header(addon.name):append(chat.message(message)))
end

local function print_error(message)
    print(chat.header(addon.name):append(chat.error(message)))
end

core = create_core({
    data = data,
    settings = settings,
    state = state,
    struct = struct,
    print_message = print_message,
    sound_player = sound_player,
    rankup_sound_path = addon.path .. 'assets\\ffxiv-levelup.wav',
    ore_sound_path = addon.path .. 'assets\\money.wav',
})

ui = create_ui({
    imgui = imgui,
    data = data,
    state = state,
    settings = settings,
    default_settings = default_settings,
    print_message = print_message,
    clear_session = core.clear_session,
    compute_metrics = core.compute_metrics,
    get_area_delay_display = core.get_area_delay_display,
    get_dig_delay_display = core.get_dig_delay_display,
    get_jp_reset_display = core.get_jp_reset_display,
    get_day_change_display = core.get_day_change_display,
    get_current_zone_name = core.get_current_zone_name,
})

local function print_help(is_error)
    if is_error then
        print_error('Invalid command syntax.')
    end

    print_message('Commands:')
    print_message('/golddigger or /gd - Toggle the main window.')
    print_message('/golddigger config - Open configuration.')
    print_message('/golddigger clear - Clear the digging session.')
end

ashita.events.register('load', 'golddigger_load', function()
    apply_settings(state.settings)
    if state.settings.reset_on_load then
        core.clear_session(false)
    end
end)

ashita.events.register('unload', 'golddigger_unload', function()
    settings.save()
end)

ashita.events.register('command', 'golddigger_command', function(e)
    local args = e.command:args()
    if #args == 0 then
        return
    end

    local root = args[1] and args[1]:lower() or ''
    if root ~= '/golddigger' and root ~= '/gd' then
        return
    end

    e.blocked = true

    if #args == 1 then
        state.visible[1] = not state.visible[1]
        state.settings.visible = state.visible[1]
        settings.save()
        return
    end

    local cmd = args[2] and args[2]:lower() or ''
    if cmd == 'config' then
        state.config_visible[1] = true
        return
    end
    if cmd == 'clear' then
        core.clear_session(true)
        print_message('Cleared digging session.')
        return
    end

    print_help(true)
end)

ashita.events.register('packet_in', 'golddigger_packet_in', function(e)
    core.on_packet_in(e)
end)

ashita.events.register('packet_out', 'golddigger_packet_out', function(e)
    core.on_packet_out(e)
end)

ashita.events.register('text_in', 'golddigger_text_in', function(e)
    core.on_text_in(e)
end)

ashita.events.register('d3d_present', 'golddigger_present', function()
    sound_player.Tick()
    core.update_area_delay_timer_state()
    core.update_jp_reset_state()
    ui.render_config_window()
    ui.render_main_window()
end)