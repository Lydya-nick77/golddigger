return function(deps)
    local data = deps.data
    local settings = deps.settings
    local state = deps.state
    local struct = deps.struct
    local print_message = deps.print_message
    local sound_player = deps.sound_player
    local rankup_sound_path = deps.rankup_sound_path
    local levelup_sound_path = deps.levelup_sound_path
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
    local level_up_pending_attempt = nil

    local dig_rank_data = {
        { name = 'Amateur',     area_delay = 60, dig_delay = 15, experience = 30 },
        { name = 'Recruit',     area_delay = 55, dig_delay = 10, experience = 40 },
        { name = 'Initiate',    area_delay = 50, dig_delay = 5,  experience = 45 },
        { name = 'Novice',      area_delay = 45, dig_delay = 3,  experience = 50 },
        { name = 'Apprentice',  area_delay = 40, dig_delay = 3,  experience = 55 },
        { name = 'Journeyman',  area_delay = 35, dig_delay = 3,  experience = 60 },
        { name = 'Craftsman',   area_delay = 30, dig_delay = 3,  experience = 65 },
        { name = 'Artisan',     area_delay = 25, dig_delay = 3,  experience = 70 },
        { name = 'Adept',       area_delay = 20, dig_delay = 3,  experience = 80 },
        { name = 'Veteran',     area_delay = 15, dig_delay = 3,  experience = 85 },
        { name = 'Expert',      area_delay = 10, dig_delay = 3,  experience = 100 },
    }

    local level_experience_required = {
        [1] = 155, [2] = 220, [3] = 355, [4] = 445, [5] = 615, [6] = 740, [7] = 900, [8] = 1070, [9] = 1230, [10] = 1320,
        [11] = 1470, [12] = 1705, [13] = 2015, [14] = 2245, [15] = 2495, [16] = 2755, [17] = 3020, [18] = 3315, [19] = 3610, [20] = 3915,
        [21] = 4315, [22] = 4655, [23] = 5010, [24] = 5380, [25] = 5765, [26] = 6160, [27] = 6570, [28] = 6995, [29] = 7435, [30] = 7895,
        [31] = 8485, [32] = 8975, [33] = 9480, [34] = 10000, [35] = 10545, [36] = 11085, [37] = 11660, [38] = 12240, [39] = 12680, [40] = 13115,
        [41] = 13745, [42] = 14200, [43] = 14665, [44] = 15130, [45] = 15605, [46] = 16080, [47] = 16560, [48] = 17045, [49] = 17535, [50] = 18025,
        [51] = 18730, [52] = 19240, [53] = 19755, [54] = 20275, [55] = 20790, [56] = 21325, [57] = 21850, [58] = 22390, [59] = 22925, [60] = 23470,
        [61] = 24185, [62] = 24735, [63] = 25305, [64] = 25865, [65] = 26430, [66] = 27000, [67] = 27575, [68] = 28165, [69] = 28750, [70] = 29335,
        [71] = 30085, [72] = 30685, [73] = 31290, [74] = 31900, [75] = 32510, [76] = 33125, [77] = 33745, [78] = 34365, [79] = 35000, [80] = 35630,
        [81] = 36395, [82] = 37040, [83] = 37680, [84] = 38335, [85] = 38990, [86] = 39645, [87] = 40305, [88] = 40970, [89] = 41640, [90] = 44745,
        [91] = 45565, [92] = 46280, [93] = 47005, [94] = 47735, [95] = 48465, [96] = 49210, [97] = 49950, [98] = 50695, [99] = 51440, [100] = 52200,
    }

    local function now_ms()
        return ashita.time.clock()['ms'] or 0
    end

    local function get_dig_rank_info(dig_level)
        local rank_key = math.max(0, math.min(10, math.floor((math.max(1, tonumber(dig_level) or 1)) / 10)))
        local rank_info = dig_rank_data[rank_key + 1] or dig_rank_data[1]
        return rank_key, rank_info
    end

    local function add_dig_experience(item_rank)
        local level = math.max(1, math.min(100, tonumber(state.settings.dig_level) or 1))
        local rank_index = math.max(0, math.min(10, tonumber(item_rank) or 0))
        local rank_info = dig_rank_data[rank_index + 1] or dig_rank_data[1]
        local experience = math.max(0, tonumber(state.settings.dig_experience) or 0) + rank_info.experience

        while level < 100 and experience >= (level_experience_required[level] or math.huge) do
            experience = experience - level_experience_required[level]
            level = level + 1
        end

        state.settings.dig_level = level
        state.settings.dig_experience = experience
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

    local function get_item_rank(item_name)
        if is_elemental_ore(item_name) then
            return 10
        end

        local zone_name = nil
        pcall(function()
            local zone_id = AshitaCore:GetMemoryManager():GetParty():GetMemberZone(0)
            zone_name = AshitaCore:GetResourceManager():GetString('zones.names', zone_id)
        end)

        local rank_key = item_name
        rank_key = rank_key:gsub('^chunk of ', '')
        rank_key = rank_key:gsub('^handful of ', '')
        rank_key = rank_key:gsub('^clump of ', '')
        rank_key = rank_key:gsub('^ball of ', '')
        rank_key = rank_key:gsub('^bag of ', '')
        rank_key = rank_key:gsub('^pinch of ', '')
        rank_key = rank_key:gsub('^piece of ', '')
        rank_key = rank_key:gsub('^sprig of ', '')
        rank_key = rank_key:gsub('^stick of ', '')

        local zone_ranks = type(zone_name) == 'string' and data.ZoneItemRanks[zone_name:lower()] or nil
        return zone_ranks and zone_ranks[rank_key] or 0
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

    local function reset_area_delay_timer_state()
        state.area_delay.active = false
        state.area_delay.end_ms = 0
        state.area_delay.ready = false
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
        local in_window = moon_index >= 46 and moon_index <= 58

        if in_window then
            local seconds_until_end = ((59 - moon_index) * 3456) - elapsed
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
        local _, rank_info = get_dig_rank_info(state.settings.dig_level)

        if state.settings.auto_show_on_dig then
            state.visible[1] = true
            state.settings.visible = true
        end

        state.settings.dig_tries = state.settings.dig_tries + 1

        if dig_success ~= nil and dig_success ~= '' then
            local item_name = dig_success
            state.settings.dig_items = state.settings.dig_items + 1
            if level_up_pending_attempt == state.last_attempt then
                level_up_pending_attempt = nil
            else
                add_dig_experience(get_item_rank(item_name))
            end
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
        local zone_id = 0
        pcall(function()
            zone_id = AshitaCore:GetMemoryManager():GetParty():GetMemberZone(0)
        end)
        local dig_rank, rank_info = get_dig_rank_info(state.settings.dig_level)
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

        local active_weather = weather ~= 'Unknown' and weather ~= 'Clear' and weather ~= 'Sunshine' and weather ~= 'Clouds'
        local ore_possible = data.ElementalOreZones[tonumber(zone_id) or 0] == true
            and active_weather
            and moon.phase == 'Waxing Crescent'

        return {
            moon = moon,
            weather = weather,
            greens_total = greens_total,
            rank = rank_info,
            level_experience_required = level_experience_required[state.settings.dig_level] or 0,
            accuracy = accuracy,
            acc_estimate = acc_estimate,
            reward_rows = reward_rows,
            ore_possible = ore_possible,
            ore_window_timer_text = memory_cache.timer_display.ore_window_timer_text or '--:--:--',
            ore_window_timer_color = memory_cache.timer_display.ore_window_timer_color or data.Colors.text_dim,
            est_remaining = math.floor(greens_total * (dig_rate * moon_modifier * skill_modifier)),
            fatigue_remaining = math.max(0, 100 - state.settings.dig_items),
        }
    end

    local function on_packet_in(e)
        if tonumber(e.id) == 0x00B then
            state.digging.zone_empty[1] = false
            reset_area_delay_timer_state()
            reset_dig_delay_timer_state()
            local _, rank_info = get_dig_rank_info(state.settings.dig_level)
            start_area_delay_timer(rank_info.area_delay)
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
        local message = string.lower(strip_colors(e.message or ''))
        local dig_level = tonumber(message:match('your wing skill improved to%s+(%d+)'))
        if dig_level ~= nil then
            local previous_level = tonumber(state.settings.dig_level) or 1
            local old_rank = select(1, get_dig_rank_info(previous_level))
            local did_levelup = dig_level > previous_level
            local did_rankup = false
            state.settings.dig_level = math.max(1, math.min(100, dig_level))
            if state.settings.dig_level ~= previous_level then
                state.settings.dig_experience = 0
                if state.attempt_type == 'digging' then
                    level_up_pending_attempt = state.last_attempt
                end
            end
            if did_levelup then
                local new_rank = select(1, get_dig_rank_info(state.settings.dig_level))
                did_rankup = new_rank > old_rank
            end

            if did_rankup then
                play_rankup_sound()
            elseif did_levelup then
                play_levelup_sound()
            end
        end

        local last_attempt_secs = (now_ms() - state.last_attempt) / 1000.0
        if state.attempt_type ~= 'digging' or last_attempt_secs >= 60 then
            return
        end

        local dig_success = normalize_reward_name(message:match('obtained:%s*(.-)%s*[%.!]$') or message:match('obtained:%s*(.+)$'))
        local dig_unable = message:find('you dig and you dig', 1, true) ~= nil
        local area_recently_dug = message:find('already dug in this area recently', 1, true) ~= nil
        local zone_empty = message:match('the zone has nothing left to dig up')

        if zone_empty then
            state.digging.zone_empty[1] = true
        end

        if area_recently_dug then
            local _, rank_info = get_dig_rank_info(state.settings.dig_level)
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
