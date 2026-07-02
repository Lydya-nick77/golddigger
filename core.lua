return function(deps)
    local data = deps.data
    local settings = deps.settings
    local state = deps.state
    local struct = deps.struct
    local print_message = deps.print_message
    local sound_player = deps.sound_player
    local rankup_sound_path = deps.rankup_sound_path
    local levelup_sound_path = deps.levelup_sound_path
    local skillup_sound_path = deps.skillup_sound_path
    local ore_sound_path = deps.ore_sound_path

    local memory_cache = {
        vana_time_sig = nil,
        weather_sig = nil,
        timer_display = {
            next_update_ms = 0,
            jp_reset_text = '--:--:--',
            jp_reset_color = nil,
            day_change_text = '--:--',
            day_change_color = nil,
            ore_window_timer_text = '--:--:--',
            ore_window_timer_color = nil,
            jst_day_key = nil,
        },
    }

    local dig_rank_data = {
        { name = 'Amateur',     area_delay = 60, dig_delay = 16, daily_limit = 100 },
        { name = 'Recruit',     area_delay = 55, dig_delay = 11, daily_limit = 110 },
        { name = 'Initiate',    area_delay = 50, dig_delay = 6,  daily_limit = 120 },
        { name = 'Novice',      area_delay = 45, dig_delay = 1,  daily_limit = 130 },
        { name = 'Apprentice',  area_delay = 40, dig_delay = 0,  daily_limit = 140 },
        { name = 'Journeyman',  area_delay = 35, dig_delay = 0,  daily_limit = 150 },
        { name = 'Craftsman',   area_delay = 30, dig_delay = 0,  daily_limit = 160 },
        { name = 'Artisan',     area_delay = 25, dig_delay = 0,  daily_limit = 170 },
        { name = 'Adept',       area_delay = 20, dig_delay = 0,  daily_limit = 180 },
        { name = 'Veteran',     area_delay = 15, dig_delay = 0,  daily_limit = 190 },
        { name = 'Expert',      area_delay = 10, dig_delay = 0,  daily_limit = 200 },
    }

    local function now_ms()
        return ashita.time.clock()['ms'] or 0
    end

    local function get_dig_rank_info(dig_skill)
        local rank_key = math.max(0, math.min(10, math.floor((tonumber(dig_skill) or 0) / 10)))
        local rank_info = dig_rank_data[rank_key + 1] or dig_rank_data[1]
        return rank_key, rank_info
    end

    local function play_rankup_sound()
        if sound_player == nil or type(sound_player.Play) ~= 'function' then
            return
        end

        local volume = tonumber(state.settings.rankup_sound_volume) or 50
        if volume <= 0 then
            return
        end

        pcall(sound_player.Play, rankup_sound_path, volume)
    end

    local function play_levelup_sound()
        if sound_player == nil or type(sound_player.Play) ~= 'function' then
            return
        end

        if levelup_sound_path == nil or levelup_sound_path == '' then
            return
        end

        local volume = tonumber(state.settings.rankup_sound_volume) or 50
        if volume <= 0 then
            return
        end

        pcall(sound_player.Play, levelup_sound_path, volume)
    end

    local function play_skillup_sound()
        if sound_player == nil or type(sound_player.Play) ~= 'function' then
            return
        end

        if skillup_sound_path == nil or skillup_sound_path == '' then
            return
        end

        local volume = tonumber(state.settings.rankup_sound_volume) or 50
        if volume <= 0 then
            return
        end

        pcall(sound_player.Play, skillup_sound_path, volume)
    end

    local function play_ore_sound()
        if ore_sound_path == nil or ore_sound_path == '' then
            return
        end

        if sound_player ~= nil and type(sound_player.Play) == 'function' then
            pcall(sound_player.Play, ore_sound_path, 100)
            return
        end

        pcall(ashita.misc.play_sound, ore_sound_path)
    end

    local elemental_ore_names = {
        ['chunk of fire ore'] = true,
        ['chunk of ice ore'] = true,
        ['chunk of wind ore'] = true,
        ['chunk of earth ore'] = true,
        ['chunk of lightning ore'] = true,
        ['chunk of water ore'] = true,
        ['chunk of light ore'] = true,
        ['chunk of dark ore'] = true,
    }

    local function is_elemental_ore(item_name)
        if type(item_name) ~= 'string' then
            return false
        end

        return elemental_ore_names[item_name] == true
    end

    local function strip_colors(text)
        if type(text) ~= 'string' then
            return ''
        end

        local strip = rawget(string, 'strip_colors')
        if type(strip) == 'function' then
            return strip(text)
        end

        return text
    end

    local function normalize_reward_name(text)
        if type(text) ~= 'string' then
            return nil
        end

        local cleaned = strip_colors(text)
        cleaned = cleaned:gsub('[%c\127]', '')
        cleaned = cleaned:gsub('%?', '')
        cleaned = cleaned:gsub('%.[0-9]+$', '')
        cleaned = cleaned:gsub('^%s+', ''):gsub('%s+$', '')
        cleaned = cleaned:gsub('^[%p%s]+', ''):gsub('[%p%s]+$', '')
        cleaned = cleaned:gsub('%s+', ' ')

        if cleaned == '' then
            return nil
        end

        return cleaned:lower()
    end

    local function get_vana_raw_time()
        if memory_cache.vana_time_sig == nil then
            memory_cache.vana_time_sig = ashita.memory.find('FFXiMain.dll', 0, 'B0015EC390518B4C24088D4424005068', 0, 0)
        end

        local sig = tonumber(memory_cache.vana_time_sig) or 0
        if sig <= 0 then
            return nil
        end

        local pointer = tonumber(ashita.memory.read_uint32(sig + 0x34)) or 0
        if pointer <= 0 then
            return nil
        end

        return (tonumber(ashita.memory.read_uint32(pointer + 0x0C)) or 0) + 92514960
    end

    local function get_timestamp()
        local raw_time = get_vana_raw_time()
        if raw_time == nil then
            return { day = 0, hour = 0, minute = 0 }
        end

        local timestamp = {}
        timestamp.day = math.floor(raw_time / 3456)
        timestamp.hour = math.floor(raw_time / 144) % 24
        timestamp.minute = math.floor((raw_time % 144) / 2.4)
        return timestamp
    end

    local function get_weather()
        if memory_cache.weather_sig == nil then
            memory_cache.weather_sig = ashita.memory.find('FFXiMain.dll', 0, '66A1????????663D????72', 0, 0)
        end

        local sig = tonumber(memory_cache.weather_sig) or 0
        if sig <= 0 then
            return 'Unknown'
        end

        local pointer = tonumber(ashita.memory.read_uint32(sig + 0x02)) or 0
        if pointer <= 0 then
            return 'Unknown'
        end

        return data.Weather[ashita.memory.read_uint8(pointer + 0)] or 'Unknown'
    end

    local function get_moon()
        local timestamp = get_timestamp()
        local moon_index = ((timestamp.day + 26) % 84) + 1
        return {
            phase = data.MoonPhase[moon_index] or 'Unknown',
            percent = data.MoonPhasePercent[moon_index] or 0,
        }
    end

    local function count_gysahl_greens()
        local inv = AshitaCore:GetMemoryManager():GetInventory()
        if inv == nil then
            return 0
        end

        local total = 0
        for slot_index = 0, 80 do
            local item = inv:GetContainerItem(0, slot_index)
            if item ~= nil and item.Id == 4545 then
                total = total + (tonumber(item.Count) or 0)
            end
        end

        return total
    end

    local function get_cached_gysahl_greens()
        local clock_ms = now_ms()
        if clock_ms < (tonumber(state.greens_cache.next_update_ms) or 0) then
            return tonumber(state.greens_cache.count) or 0
        end

        state.greens_cache.count = count_gysahl_greens()
        state.greens_cache.next_update_ms = clock_ms + 1000
        return state.greens_cache.count
    end

    local function get_cached_environment()
        local clock_ms = now_ms()
        if clock_ms < (tonumber(state.environment_cache.next_update_ms) or 0) then
            return state.environment_cache.moon, state.environment_cache.weather
        end

        state.environment_cache.moon = get_moon()
        state.environment_cache.weather = get_weather()
        state.environment_cache.next_update_ms = clock_ms + 1000

        return state.environment_cache.moon, state.environment_cache.weather
    end

    local function is_player_mounted()
        local player = AshitaCore:GetMemoryManager():GetPlayer()
        if player == nil then
            return false
        end

        if player.isZoning == true then
            return false
        end

        local status_mounted = false
        local get_player_entity = rawget(_G, 'GetPlayerEntity')
        if type(get_player_entity) == 'function' then
            local entity = get_player_entity()
            if entity ~= nil then
                status_mounted = tonumber(entity.StatusServer) == 4
            end
        end

        local buffs = player:GetBuffs()
        if buffs == nil then
            return false
        end

        local buff_mounted = false

        for _, buff_id in ipairs(buffs) do
            if tonumber(buff_id) == 252 then -- Mounted
                buff_mounted = true
                break
            end
        end

        return status_mounted or buff_mounted
    end

    local function queue_area_delay_timer_start()
        state.area_delay.pending_start = true
        state.area_delay.mounted_since_ms = 0
    end

    local function reset_area_delay_timer_state()
        state.area_delay.active = false
        state.area_delay.end_ms = 0
        state.area_delay.ready = false
        state.area_delay.pending_start = false
        state.area_delay.mounted_since_ms = 0
    end

    local function reset_dig_delay_timer_state()
        state.dig_delay.active = false
        state.dig_delay.end_ms = 0
        state.dig_delay.ready = false
    end

    local function start_area_delay_timer(seconds)
        local delay_seconds = math.max(0, tonumber(seconds) or 0)
        state.area_delay.ready = false
        if delay_seconds <= 0 then
            state.area_delay.active = false
            state.area_delay.end_ms = 0
            return
        end

        state.area_delay.active = true
        state.area_delay.end_ms = now_ms() + (delay_seconds * 1000)
    end

    local function start_dig_delay_timer(seconds)
        local delay_seconds = math.max(0, tonumber(seconds) or 0)
        state.dig_delay.ready = false
        if delay_seconds <= 0 then
            state.dig_delay.active = false
            state.dig_delay.end_ms = 0
            return
        end

        state.dig_delay.active = true
        state.dig_delay.end_ms = now_ms() + (delay_seconds * 1000)
    end

    local function update_area_delay_timer_state()
        local clock_ms = now_ms()
        local mounted = is_player_mounted()

        if mounted and state.area_delay.was_mounted ~= true then
            queue_area_delay_timer_start()
            state.area_delay.mounted_since_ms = clock_ms
        elseif (not mounted) and state.area_delay.was_mounted == true then
            reset_area_delay_timer_state()
            reset_dig_delay_timer_state()
        end

        state.area_delay.was_mounted = mounted

        if state.area_delay.pending_start ~= true or state.area_delay.active == true then
            return
        end

        if mounted then
            if (tonumber(state.area_delay.mounted_since_ms) or 0) == 0 then
                state.area_delay.mounted_since_ms = clock_ms
            end

            if clock_ms - (tonumber(state.area_delay.mounted_since_ms) or 0) >= 1500 then
                local _, rank_info = get_dig_rank_info(state.settings.dig_skill)
                start_area_delay_timer(rank_info.area_delay)
                state.area_delay.pending_start = false
                state.area_delay.mounted_since_ms = 0
                return
            end
        else
            state.area_delay.mounted_since_ms = 0
        end
    end

    local function get_area_delay_display(default_area_delay)
        if state.area_delay.active ~= true then
            if state.area_delay.ready == true then
                return 'READY', data.Colors.success
            end

            local fallback = math.max(0, tonumber(default_area_delay) or 0)
            return ('%ds'):format(fallback), data.Colors.danger
        end

        local remaining_ms = math.max(0, (tonumber(state.area_delay.end_ms) or 0) - now_ms())
        if remaining_ms <= 0 then
            state.area_delay.active = false
            state.area_delay.end_ms = 0
            state.area_delay.ready = true
            return 'READY', data.Colors.success
        end

        local remaining_seconds = math.ceil(remaining_ms / 1000.0)
        return ('%ds'):format(remaining_seconds), data.Colors.danger
    end

    local function get_dig_delay_display(default_dig_delay)
        if state.dig_delay.active ~= true then
            if state.dig_delay.ready == true then
                return 'READY', data.Colors.success
            end

            local fallback = math.max(0, tonumber(default_dig_delay) or 0)
            return ('%ds'):format(fallback), data.Colors.danger
        end

        local remaining_ms = math.max(0, (tonumber(state.dig_delay.end_ms) or 0) - now_ms())
        if remaining_ms <= 0 then
            state.dig_delay.active = false
            state.dig_delay.end_ms = 0
            state.dig_delay.ready = true
            return 'READY', data.Colors.success
        end

        local remaining_seconds = math.ceil(remaining_ms / 1000.0)
        return ('%ds'):format(remaining_seconds), data.Colors.danger
    end

    local function get_jst_clock()
        local now_utc = os.time()
        local now_jst = now_utc + (9 * 60 * 60)
        return os.date('!*t', now_jst)
    end

    local function get_jst_day_key(jst)
        if jst == nil then
            return nil
        end

        local year = tonumber(jst.year) or 0
        local yday = tonumber(jst.yday) or 0
        return (year * 1000) + yday
    end

    local format_duration_hhmmss
    local get_ore_window_timer_state

    local function update_timer_display_cache()
        local clock_ms = now_ms()
        if clock_ms < (tonumber(memory_cache.timer_display.next_update_ms) or 0) then
            return
        end

        memory_cache.timer_display.next_update_ms = clock_ms + 1000

        local jst = get_jst_clock()
        if jst ~= nil then
            local elapsed = ((tonumber(jst.hour) or 0) * 3600) + ((tonumber(jst.min) or 0) * 60) + (tonumber(jst.sec) or 0)
            local remaining = math.max(0, 86400 - elapsed)
            if remaining == 0 then
                remaining = 86400
            end

            local hours = math.floor(remaining / 3600)
            local minutes = math.floor((remaining % 3600) / 60)
            local seconds = remaining % 60
            memory_cache.timer_display.jp_reset_text = ('%02d:%02d:%02d'):format(hours, minutes, seconds)
            memory_cache.timer_display.jp_reset_color = data.Colors.info
            memory_cache.timer_display.jst_day_key = get_jst_day_key(jst)
        else
            memory_cache.timer_display.jp_reset_text = '--:--:--'
            memory_cache.timer_display.jp_reset_color = data.Colors.text_dim
            memory_cache.timer_display.jst_day_key = nil
        end

        local raw_time = get_vana_raw_time()
        if raw_time ~= nil then
            local elapsed = raw_time % 3456
            local remaining = math.max(0, 3456 - elapsed)
            if remaining == 0 then
                remaining = 3456
            end

            local minutes = math.floor(remaining / 60)
            local seconds = remaining % 60
            memory_cache.timer_display.day_change_text = ('%02d:%02d'):format(minutes, seconds)
            memory_cache.timer_display.day_change_color = data.Colors.info
        else
            memory_cache.timer_display.day_change_text = '--:--'
            memory_cache.timer_display.day_change_color = data.Colors.text_dim
        end

        local ore_window_now, ore_window_timer_seconds = get_ore_window_timer_state()
        if ore_window_timer_seconds ~= nil then
            local timer_value = format_duration_hhmmss(ore_window_timer_seconds)
            if ore_window_now then
                memory_cache.timer_display.ore_window_timer_text = ('Now until %s'):format(timer_value)
                memory_cache.timer_display.ore_window_timer_color = data.Colors.success
            else
                memory_cache.timer_display.ore_window_timer_text = timer_value
                memory_cache.timer_display.ore_window_timer_color = data.Colors.info
            end
        else
            memory_cache.timer_display.ore_window_timer_text = '--:--:--'
            memory_cache.timer_display.ore_window_timer_color = data.Colors.text_dim
        end
    end

    local function get_jp_reset_display()
        update_timer_display_cache()
        return memory_cache.timer_display.jp_reset_text, memory_cache.timer_display.jp_reset_color or data.Colors.text_dim
    end

    local function get_day_change_display()
        update_timer_display_cache()
        return memory_cache.timer_display.day_change_text, memory_cache.timer_display.day_change_color or data.Colors.text_dim
    end

    format_duration_hhmmss = function(total_seconds)
        local seconds = math.max(0, math.floor(tonumber(total_seconds) or 0))
        local hours = math.floor(seconds / 3600)
        local minutes = math.floor((seconds % 3600) / 60)
        local remainder = seconds % 60
        return ('%02d:%02d:%02d'):format(hours, minutes, remainder)
    end

    get_ore_window_timer_state = function()
        local raw_time = get_vana_raw_time()
        if raw_time == nil then
            return false, nil
        end

        local day = math.floor(raw_time / 3456)
        local elapsed = raw_time % 3456
        local moon_index = ((day + 26) % 84) + 1
        local in_window = moon_index >= 46 and moon_index <= 53

        if in_window then
            local seconds_until_end = ((54 - moon_index) * 3456) - elapsed
            return true, math.max(0, seconds_until_end)
        end

        local days_until_start = 0
        if moon_index < 46 then
            days_until_start = 46 - moon_index
        else
            days_until_start = (84 - moon_index) + 46
        end

        local seconds_until_start = (days_until_start * 3456) - elapsed
        return false, math.max(0, seconds_until_start)
    end

    local function calculate_dpm(dig_time_ms)
        state.digging.dig_timing[state.digging.dig_index] = dig_time_ms

        local total_count = 0
        local total_time = 0
        for i = 2, #state.digging.dig_timing do
            local current = tonumber(state.digging.dig_timing[i]) or 0
            local previous = tonumber(state.digging.dig_timing[i - 1]) or 0
            if current > previous and previous > 0 then
                total_count = total_count + 1
                total_time = total_time + (current - previous)
            end
        end

        if total_count > 0 and total_time > 0 then
            state.digging.dig_per_minute = 60 / ((total_time / total_count) / 1000.0)
        else
            state.digging.dig_per_minute = 0
        end

        if state.digging.dig_index >= #state.digging.dig_timing then
            state.digging.dig_index = 1
        else
            state.digging.dig_index = state.digging.dig_index + 1
        end
    end

    local function clear_session(save_after)
        state.settings.dig_rewards = T{}
        state.settings.dig_items = 0
        state.settings.dig_tries = 0
        state.last_item = ''
        state.last_attempt = 0
        state.attempt_type = ''
        state.digging.dig_timing = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
        state.digging.dig_index = 1
        state.digging.dig_per_minute = 0
        state.digging.dig_skillup = 0.0
        state.digging.zone_empty[1] = false
        state.greens_cache.count = 0
        state.greens_cache.next_update_ms = 0
        state.environment_cache.weather = 'Unknown'
        state.environment_cache.moon = { phase = 'Unknown', percent = 0 }
        state.environment_cache.next_update_ms = 0

        if save_after ~= false then
            settings.save()
        end
    end

    local function update_jp_reset_state()
        update_timer_display_cache()
        local day_key = memory_cache.timer_display.jst_day_key
        if day_key == nil then
            return
        end

        if state.jp_reset.last_day_key == nil then
            state.jp_reset.last_day_key = day_key
            return
        end

        if day_key ~= state.jp_reset.last_day_key then
            state.jp_reset.last_day_key = day_key
            if state.settings.auto_clear_on_jp_reset == true then
                clear_session(true)
                print_message('Session auto-cleared at JP daily reset.')
            end
        end
    end

    local function handle_dig(dig_success)
        local _, rank_info = get_dig_rank_info(state.settings.dig_skill)

        if state.settings.auto_show_on_dig then
            state.visible[1] = true
            state.settings.visible = true
        end

        state.settings.dig_tries = state.settings.dig_tries + 1

        if dig_success ~= nil and dig_success ~= '' then
            local item_name = dig_success
            state.settings.dig_items = state.settings.dig_items + 1
            state.digging.zone_empty[1] = false
            state.last_item = item_name
            state.settings.dig_rewards[item_name] = (tonumber(state.settings.dig_rewards[item_name]) or 0) + 1

            if is_elemental_ore(item_name) then
                play_ore_sound()
            end
        end

        start_dig_delay_timer(rank_info.dig_delay)
    end

    local function compute_metrics()
        local moon, weather = get_cached_environment()
        local greens_total = get_cached_gysahl_greens()
        local dig_rank, rank_info = get_dig_rank_info(state.settings.dig_skill)
        update_timer_display_cache()
        local dig_rate = 0.85
        local skill_modifier = 0.5 + (dig_rank / 20)
        local moon_dist = tonumber(moon.percent) or 0
        if moon_dist < 50 then
            moon_dist = 100 - moon_dist
        end
        local moon_modifier = 1 - (100 - moon_dist) / 100
        local acc_estimate = (dig_rate * moon_modifier * skill_modifier) * 100
        local accuracy = 0
        if state.settings.dig_tries > 0 then
            accuracy = (state.settings.dig_items / state.settings.dig_tries) * 100
        end

        local reward_rows = {}
        for item_name, count in pairs(state.settings.dig_rewards or T{}) do
            table.insert(reward_rows, {
                name = item_name,
                count = tonumber(count) or 0,
            })
        end

        table.sort(reward_rows, function(a, b)
            if a.count ~= b.count then
                return a.count > b.count
            end
            return a.name < b.name
        end)

        local ore_possible = false
        if not state.digging.zone_empty[1]
            and moon.phase == 'Waxing Crescent'
            and moon.percent > 6
            and moon.percent < 25
        then
            ore_possible = weather ~= 'Clear' and weather ~= 'Sunshine' and weather ~= 'Clouds'
        end

        return {
            moon = moon,
            weather = weather,
            greens_total = greens_total,
            rank = rank_info,
            accuracy = accuracy,
            acc_estimate = acc_estimate,
            reward_rows = reward_rows,
            ore_possible = ore_possible,
            ore_window_timer_text = memory_cache.timer_display.ore_window_timer_text or '--:--:--',
            ore_window_timer_color = memory_cache.timer_display.ore_window_timer_color or data.Colors.text_dim,
            est_remaining = math.floor(greens_total * (dig_rate * moon_modifier * skill_modifier)),
            fatigue_remaining = math.max(0, rank_info.daily_limit - state.settings.dig_items),
        }
    end

    local function on_packet_in(e)
        if tonumber(e.id) == 0x00B then
            state.digging.zone_empty[1] = false
            reset_area_delay_timer_state()
            state.area_delay.was_mounted = false
            reset_dig_delay_timer_state()
        end
    end

    local function on_packet_out(e)
        local last_attempt_secs = (now_ms() - state.last_attempt) / 1000.0
        if tonumber(e.id) ~= 0x01A or last_attempt_secs <= 2 then
            return
        end

        local packed = e.data_modified or e.data
        local ok, item_id = pcall(struct.unpack, 'H', packed, 0x0A)
        if not ok or tonumber(item_id) ~= 0x1104 then
            return
        end

        state.attempt_type = 'digging'
        state.last_attempt = now_ms()
    end

    local function on_text_in(e)
        local last_attempt_secs = (now_ms() - state.last_attempt) / 1000.0
        if state.attempt_type ~= 'digging' or last_attempt_secs >= 60 then
            return
        end

        local message = string.lower(e.message or '')
        message = strip_colors(message)

        local dig_success = normalize_reward_name(message:match('obtained:%s*(.-)%s*[%.!]$') or message:match('obtained:%s*(.+)$'))
        local dig_unable = message:find('you dig and you dig', 1, true) ~= nil
        local area_recently_dug = message:find('already dug in this area recently', 1, true) ~= nil
        local dig_skill_up, dig_skill = message:match('skill increases by (.*) raising it to (.*)!')
        local zone_empty = message:match('the zone has nothing left to dig up')

        if zone_empty then
            state.digging.zone_empty[1] = true
        end

        if dig_skill_up ~= nil then
            local previous_skill = tonumber(state.settings.dig_skill) or 0
            local old_rank = select(1, get_dig_rank_info(state.settings.dig_skill))
            state.digging.dig_skillup = state.digging.dig_skillup + (tonumber(dig_skill_up) or 0)
            local did_rankup = false
            local did_levelup = false
            local parsed_skill = tonumber(dig_skill)
            if parsed_skill ~= nil then
                state.settings.dig_skill = parsed_skill
                did_levelup = math.floor(parsed_skill) > math.floor(previous_skill)
                local new_rank = select(1, get_dig_rank_info(state.settings.dig_skill))
                if new_rank > old_rank then
                    did_rankup = true
                end
            end

            if did_rankup then
                play_rankup_sound()
            elseif did_levelup then
                play_levelup_sound()
            else
                play_skillup_sound()
            end
        end

        if area_recently_dug then
            local _, rank_info = get_dig_rank_info(state.settings.dig_skill)
            start_dig_delay_timer(rank_info.dig_delay)
            state.attempt_type = ''
            return
        end

        if dig_success ~= nil or dig_unable then
            calculate_dpm(state.last_attempt)
            handle_dig(dig_success)
            state.attempt_type = ''
        end
    end

    local function get_current_zone_name()
        local ok, zone_id = pcall(function()
            return AshitaCore:GetMemoryManager():GetParty():GetMemberZone(0)
        end)
        if not ok or zone_id == nil or zone_id == 0 then
            return nil
        end

        local ok2, zone_name = pcall(function()
            return AshitaCore:GetResourceManager():GetString('zones.names', zone_id)
        end)
        if ok2 and type(zone_name) == 'string' and zone_name ~= '' then
            return zone_name
        end

        return nil
    end

    return {
        update_area_delay_timer_state = update_area_delay_timer_state,
        update_jp_reset_state = update_jp_reset_state,
        get_area_delay_display = get_area_delay_display,
        get_dig_delay_display = get_dig_delay_display,
        get_jp_reset_display = get_jp_reset_display,
        get_day_change_display = get_day_change_display,
        clear_session = clear_session,
        compute_metrics = compute_metrics,
        get_current_zone_name = get_current_zone_name,
        on_packet_in = on_packet_in,
        on_packet_out = on_packet_out,
        on_text_in = on_text_in,
    }
end
