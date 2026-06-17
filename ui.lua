return function(deps)
    local imgui = deps.imgui
    local data = deps.data
    local state = deps.state
    local settings = deps.settings
    local default_settings = deps.default_settings
    local print_message = deps.print_message
    local clear_session = deps.clear_session
    local compute_metrics = deps.compute_metrics
    local get_area_delay_display = deps.get_area_delay_display
    local get_dig_delay_display = deps.get_dig_delay_display
    local get_jp_reset_display = deps.get_jp_reset_display
    local get_day_change_display = deps.get_day_change_display
    local get_current_zone_name = deps.get_current_zone_name

    local function apply_font_scale(scale)
        local clamped = math.max(0.8, math.min(1.6, tonumber(scale) or 1.0))
        if imgui.SetWindowFontScale then
            imgui.SetWindowFontScale(clamped)
        else
            imgui.PushFont(imgui.GetFont(), imgui.GetFontSize() * clamped)
        end
    end

    local function unapply_font_scale()
        if not imgui.SetWindowFontScale then
            imgui.PopFont()
        end
    end

    local function begin_child_compat(id, size, border, flags)
        local ok, began = pcall(imgui.BeginChild, id, size, border, flags)
        if ok then
            return began
        end

        ok, began = pcall(imgui.BeginChild, id, size, flags)
        if ok then
            return began
        end

        ok, began = pcall(imgui.BeginChild, id, size)
        if ok then
            return began
        end

        return false
    end

    local function format_int(number)
        if number == nil then
            return '0'
        end

        local value = tonumber(number)
        if value == nil then
            return tostring(number)
        end

        local minus, int, fraction = tostring(value):match('([-]?)(%d+)([.]?%d*)')
        if int == nil then
            return tostring(number)
        end

        int = int:reverse():gsub('(%d%d%d)', '%1,')
        return minus .. int:reverse():gsub('^,', '') .. fraction
    end

    local function draw_shadowed_text(content, color)
        local text = tostring(content or '')
        local x, y = imgui.GetCursorScreenPos()
        local draw_list = imgui.GetWindowDrawList()
        if draw_list ~= nil and x ~= nil and y ~= nil then
            local text_color = imgui.GetColorU32(color or data.Colors.text)
            pcall(function()
                draw_list:AddText({ x + 1, y }, text_color, text)
            end)
        end
        imgui.TextUnformatted(text)
    end

    local function render_value_row(label, value, value_color, value_column_x)
        imgui.PushStyleColor(ImGuiCol_Text, data.Colors.text)
        draw_shadowed_text(label, data.Colors.text)
        imgui.PopStyleColor(1)
        imgui.SameLine(value_column_x)
        if value_color ~= nil then
            imgui.PushStyleColor(ImGuiCol_Text, value_color)
            draw_shadowed_text(value, value_color)
            imgui.PopStyleColor(1)
        else
            draw_shadowed_text(value)
        end
    end

    local function color_with_alpha(color, alpha_scale)
        local src = color or { 1, 1, 1, 1 }
        local scale = math.max(0.0, math.min(1.0, tonumber(alpha_scale) or 1.0))
        local a = math.max(0.0, math.min(1.0, (tonumber(src[4]) or 1.0) * scale))
        return { tonumber(src[1]) or 1.0, tonumber(src[2]) or 1.0, tonumber(src[3]) or 1.0, a }
    end

    local function render_card(id, title, width, height, rows, header_buttons_width, render_header_buttons)
        local alpha = tonumber(state.settings.window_alpha) or 1.0
        imgui.PushStyleColor(ImGuiCol_ChildBg, color_with_alpha(data.Colors.panel_bg, alpha))
        imgui.PushStyleColor(ImGuiCol_Border, color_with_alpha(data.Colors.border, alpha))
        imgui.PushStyleVar(ImGuiStyleVar_WindowPadding, { 10, 8 })
        imgui.PushStyleVar(ImGuiStyleVar_FramePadding, { 6, 4 })
        local label_max = 0
        for _, row in ipairs(rows or {}) do
            local raw = imgui.CalcTextSize(tostring((row or {}).label or ''))
            local measured = type(raw) == 'table' and (tonumber(raw[1]) or 0) or (tonumber(raw) or 0)
            label_max = math.max(label_max, measured)
        end
        local value_column_x = math.max(80, math.floor(label_max + 20))

        local began = begin_child_compat(id, { width, height }, true, 0)
        if began then
            imgui.TextColored(data.Colors.gold, title)
            if render_header_buttons ~= nil then
                local content_width_raw = imgui.GetContentRegionAvail()
                local content_width = tonumber(content_width_raw) or 0
                local right_x = math.max(1, content_width - (tonumber(header_buttons_width) or 0))
                imgui.SameLine(right_x)
                render_header_buttons()
            end
            imgui.Separator()
            for _, row in ipairs(rows) do
                render_value_row(row.label, row.value, row.color, value_column_x)
            end
        end
        imgui.EndChild()

        imgui.PopStyleVar(2)
        imgui.PopStyleColor(2)
    end

    local function get_text_width(text)
        local raw = imgui.CalcTextSize(tostring(text or ''))
        if type(raw) == 'table' then
            return tonumber(raw[1]) or 0
        end

        return tonumber(raw) or 0
    end

    local function compute_panel_width(rows, min_width, max_width)
        local label_max = 0
        local value_max = 0
        for _, row in ipairs(rows or {}) do
            label_max = math.max(label_max, get_text_width(row.label))
            value_max = math.max(value_max, get_text_width(row.value))
        end

        local desired = math.floor(label_max + value_max + 48)
        desired = math.max(tonumber(min_width) or 260, desired)
        if max_width ~= nil then
            desired = math.min(desired, tonumber(max_width) or desired)
        end

        return desired
    end

    local function render_rewards(metrics, width)
        local alpha = tonumber(state.settings.window_alpha) or 1.0
        imgui.PushStyleColor(ImGuiCol_ChildBg, color_with_alpha(data.Colors.panel_bg, alpha))
        imgui.PushStyleColor(ImGuiCol_Border, color_with_alpha(data.Colors.border, alpha))
        imgui.PushStyleVar(ImGuiStyleVar_WindowPadding, { 10, 8 })
        imgui.PushStyleVar(ImGuiStyleVar_ItemSpacing, { 6, 4 })

        local rewards_width = math.max(260, tonumber(width) or 260)
        local began = begin_child_compat('##golddigger_rewards', { rewards_width, 220 }, true, 0)
        if began then
            imgui.TextColored(data.Colors.gold, 'Rewards')
            imgui.Separator()

            if #metrics.reward_rows == 0 then
                imgui.TextColored(data.Colors.text_dim, 'No digs recorded yet.')
            else
                for _, row in ipairs(metrics.reward_rows) do
                    local label = ('%s x%s'):format(row.name, format_int(row.count))
                    draw_shadowed_text(label, data.Colors.text)
                end
            end
        end
        imgui.EndChild()

        imgui.PopStyleVar(2)
        imgui.PopStyleColor(2)
    end

    local function get_current_zone_items()
        local zone_name = type(get_current_zone_name) == 'function' and get_current_zone_name() or nil
        local lookup_key = zone_name ~= nil and zone_name:lower() or nil
        local items = lookup_key ~= nil and data.ZoneItems ~= nil and data.ZoneItems[lookup_key] or nil
        return zone_name, items
    end

    local function compute_zone_items_panel_size(zone_name, items, line_height)
        local width_max = get_text_width('Possible Items')
        if zone_name ~= nil and zone_name ~= '' then
            width_max = math.max(width_max, get_text_width(zone_name))
        end

        if items ~= nil then
            for _, item_name in ipairs(items) do
                width_max = math.max(width_max, get_text_width(item_name))
            end
        else
            width_max = math.max(width_max, get_text_width('N/A'))
        end

        local item_count = items ~= nil and #items or 1
        local row_count = 4 + item_count

        return math.max(120, math.floor(width_max + 20)), math.max(70, math.floor((row_count * line_height) + 10))
    end

    local function render_zone_items_panel(width, height, zone_name, items)
        local panel_width = math.max(120, tonumber(width) or 170)
        local panel_height = math.max(80, tonumber(height) or 120)

        local alpha = tonumber(state.settings.window_alpha) or 1.0
        imgui.PushStyleColor(ImGuiCol_ChildBg, color_with_alpha(data.Colors.panel_bg, alpha))
        imgui.PushStyleColor(ImGuiCol_Border, color_with_alpha(data.Colors.border, alpha))
        imgui.PushStyleVar(ImGuiStyleVar_WindowPadding, { 8, 6 })
        imgui.PushStyleVar(ImGuiStyleVar_ItemSpacing, { 4, 2 })

        local began = begin_child_compat('##golddigger_zone_items', { panel_width, panel_height }, true, 0)
        if began then
            imgui.TextColored(data.Colors.gold, 'Possible Items')
            imgui.Separator()
            if zone_name ~= nil then
                imgui.TextColored(data.Colors.text_dim, zone_name)
                imgui.Separator()
            end
            if items == nil then
                imgui.TextColored(data.Colors.text_dim, 'N/A')
            else
                for _, item in ipairs(items) do
                    draw_shadowed_text(item, data.Colors.text)
                end
            end
        end
        imgui.EndChild()

        imgui.PopStyleVar(2)
        imgui.PopStyleColor(2)
    end

    local function render_config_window()
        if not state.config_visible[1] then
            return
        end

        local alpha = tonumber(state.settings.window_alpha) or 1.0
        imgui.PushStyleColor(ImGuiCol_WindowBg, color_with_alpha(data.Colors.window_bg, alpha))
        imgui.PushStyleColor(ImGuiCol_Border, color_with_alpha(data.Colors.border, alpha))
        imgui.PushStyleColor(ImGuiCol_TitleBg, color_with_alpha(data.Colors.title_bg, alpha))
        imgui.PushStyleColor(ImGuiCol_TitleBgActive, color_with_alpha(data.Colors.title_bg_active, alpha))
        imgui.PushStyleVar(ImGuiStyleVar_WindowRounding, 6.0)
        imgui.PushStyleVar(ImGuiStyleVar_WindowBorderSize, 2.0)

        local began = imgui.Begin('Golddigger Config', state.config_visible, ImGuiWindowFlags_AlwaysAutoResize or 0)
        if began then
            apply_font_scale(state.settings.font_scale)

            local font_scale = { tonumber(state.settings.font_scale) or default_settings.font_scale }
            if imgui.SliderFloat('Font Size', font_scale, 0.8, 1.6, '%.2f') then
                state.settings.font_scale = math.max(0.8, math.min(1.6, font_scale[1]))
            end

            local window_alpha = { tonumber(state.settings.window_alpha) or default_settings.window_alpha }
            if imgui.SliderFloat('Window Transparency', window_alpha, 0.3, 1.0, '%.2f') then
                state.settings.window_alpha = math.max(0.3, math.min(1.0, window_alpha[1]))
            end

            local dig_skill = { tonumber(state.settings.dig_skill) or 0 }
            if imgui.InputFloat('Digging Skill', dig_skill, 0.1, 0.5, '%.1f') then
                state.settings.dig_skill = math.max(0, dig_skill[1])
            end

            local rankup_volume = { tonumber(state.settings.rankup_sound_volume) or default_settings.rankup_sound_volume }
            if imgui.SliderFloat('Rank Up Sound Volume', rankup_volume, 0.0, 100.0, '%.0f%%') then
                state.settings.rankup_sound_volume = math.max(0, math.min(100, rankup_volume[1]))
            end

            local auto_show = { state.settings.auto_show_on_dig ~= false }
            if imgui.Checkbox('Auto Show On Dig', auto_show) then
                state.settings.auto_show_on_dig = auto_show[1]
            end

            local show_moon = { state.settings.show_moon ~= false }
            if imgui.Checkbox('Show Moon', show_moon) then
                state.settings.show_moon = show_moon[1]
            end

            local show_last_item = { state.settings.show_last_item ~= false }
            if imgui.Checkbox('Show Last Item', show_last_item) then
                state.settings.show_last_item = show_last_item[1]
            end

            local show_ore = { state.settings.show_ore ~= false }
            if imgui.Checkbox('Show Ore Window', show_ore) then
                state.settings.show_ore = show_ore[1]
            end

            local show_zone_items = { state.settings.show_zone_items ~= false }
            if imgui.Checkbox('Show Zone Items', show_zone_items) then
                state.settings.show_zone_items = show_zone_items[1]
            end

            local reset_on_load = { state.settings.reset_on_load == true }
            if imgui.Checkbox('Reset Session On Load', reset_on_load) then
                state.settings.reset_on_load = reset_on_load[1]
            end

            local auto_clear_on_jp_reset = { state.settings.auto_clear_on_jp_reset == true }
            if imgui.Checkbox('Auto Clear Session At JP Reset', auto_clear_on_jp_reset) then
                state.settings.auto_clear_on_jp_reset = auto_clear_on_jp_reset[1]
            end

            if imgui.Button('Save Settings') then
                settings.save()
                print_message('Settings saved.')
            end
            imgui.SameLine()
            if imgui.Button('Reload Settings') then
                settings.reload()
                print_message('Settings reloaded.')
            end
            imgui.SameLine()
            if imgui.Button('Reset Settings') then
                settings.reset()
                print_message('Settings reset to defaults.')
            end

            unapply_font_scale()
        end
        imgui.End()

        imgui.PopStyleVar(2)
        imgui.PopStyleColor(4)
    end

    local function render_main_window()
        if not state.visible[1] then
            return
        end

        local metrics = compute_metrics()
        local area_delay_text, area_delay_color = get_area_delay_display(metrics.rank.area_delay)
        local dig_delay_text, dig_delay_color = get_dig_delay_display(metrics.rank.dig_delay)
        local reset_text, reset_color = get_jp_reset_display()
        local day_change_text, day_change_color = get_day_change_display()
        local weather_color = data.WeatherColors[metrics.weather] or data.Colors.text
        local ore_color = data.Colors.warn
        local ore_text = 'No'
        if state.digging.zone_empty[1] then
            ore_text = 'No - Empty Zone'
            ore_color = data.Colors.danger
        elseif metrics.ore_possible then
            ore_text = 'Yes'
            ore_color = data.Colors.success
        end

        imgui.PushStyleColor(ImGuiCol_WindowBg, { 0.0, 0.0, 0.0, 0.0 })
        imgui.PushStyleColor(ImGuiCol_Border, { 0.0, 0.0, 0.0, 0.0 })
        imgui.PushStyleVar(ImGuiStyleVar_WindowRounding, 6.0)
        imgui.PushStyleVar(ImGuiStyleVar_WindowBorderSize, 0.0)
        imgui.PushStyleVar(ImGuiStyleVar_FrameRounding, 4.0)
        imgui.PushStyleVar(ImGuiStyleVar_ChildRounding, 3.0)
        imgui.PushStyleVar(ImGuiStyleVar_WindowTitleAlign, { 0.5, 0.5 })

        local window_flags = bit.bor(ImGuiWindowFlags_NoCollapse or 0, ImGuiWindowFlags_AlwaysAutoResize or 0, ImGuiWindowFlags_NoTitleBar or 0)
        local began = imgui.Begin('Golddigger', state.visible, window_flags)
        if began then
            apply_font_scale(state.settings.font_scale)

            local session_rows = {}
            local function add_row(label, value, color)
                table.insert(session_rows, { label = label, value = value, color = color })
            end

            add_row('Skill', ('%.1f (+%.1f) (%s)'):format(state.settings.dig_skill, state.digging.dig_skillup, metrics.rank.name), data.Colors.info)
            add_row('Attempts', ('%s (%.2f dpm)'):format(format_int(state.settings.dig_tries), state.digging.dig_per_minute), data.Colors.text)
            add_row('Items Dug / Limit', ('%s/%s (%s to fatigue)'):format(format_int(state.settings.dig_items), format_int(metrics.rank.daily_limit), format_int(metrics.fatigue_remaining)), data.Colors.text)
            add_row('Accuracy', ('%.1f%% act / %.1f%% est'):format(metrics.accuracy, metrics.acc_estimate), data.Colors.info)
            add_row('Greens Left', ('%s (%d est)'):format(format_int(metrics.greens_total), metrics.est_remaining), data.Colors.text)
            if state.settings.show_moon then
                add_row('Moon', ('%s (%d%%)'):format(metrics.moon.phase, metrics.moon.percent), data.Colors.gold_soft)
            end
            add_row('Weather', metrics.weather, weather_color)
            if state.settings.show_ore then
                add_row('Ore Window', ore_text, ore_color)
            end
            if state.settings.show_last_item then
                add_row('Last Item', state.digging.zone_empty[1] and 'ZONE EMPTY' or (state.last_item ~= '' and state.last_item or '--'), state.digging.zone_empty[1] and data.Colors.danger or data.Colors.text)
            end
            add_row('Area Delay', area_delay_text, area_delay_color)
            add_row('Dig Delay', dig_delay_text, dig_delay_color)
            add_row('JP Reset In', reset_text, reset_color)
            add_row('Day Change In', day_change_text, day_change_color)

            local session_width = compute_panel_width(session_rows, 260, nil)
            local line_height = 18
            if imgui.GetTextLineHeightWithSpacing then
                line_height = tonumber(imgui.GetTextLineHeightWithSpacing()) or line_height
            end
            local session_height = math.max(120, math.floor(((#session_rows + 2) * line_height) + 20))
            local config_button_width = get_text_width('Config') + 12
            local clear_button_width = get_text_width('Clear Session') + 12
            local header_buttons_width = config_button_width + clear_button_width + 8
            local zone_items_panel_width = 170
            local zone_items_panel_height = 100
            local zone_name, zone_items = nil, nil
            if state.settings.show_zone_items ~= false then
                zone_name, zone_items = get_current_zone_items()
                zone_items_panel_width, zone_items_panel_height = compute_zone_items_panel_size(zone_name, zone_items, line_height)
            end
            local session_pos_x = tonumber(imgui.GetCursorPosX()) or 0
            local session_pos_y = tonumber(imgui.GetCursorPosY()) or 0

            imgui.BeginGroup()
            render_card('##golddigger_session', 'Golddigger', session_width, session_height, session_rows, header_buttons_width, function()
                if imgui.Button('Config') then
                    state.config_visible[1] = true
                end
                imgui.SameLine()
                if imgui.Button('Clear Session') then
                    clear_session(true)
                    print_message('Cleared digging session.')
                end
            end)
            imgui.EndGroup()

            if state.settings.show_zone_items ~= false then
                local side_x = session_pos_x + session_width + 6
                local side_y = session_pos_y + math.max(0, math.floor((session_height - zone_items_panel_height) / 2))
                imgui.SetCursorPos({ side_x, side_y })
                render_zone_items_panel(zone_items_panel_width, zone_items_panel_height, zone_name, zone_items)
            end

            imgui.SetCursorPos({ session_pos_x, session_pos_y + session_height + 8 })

            if state.settings.show_rewards then
                render_rewards(metrics, session_width)
            end

            unapply_font_scale()
        end
        imgui.End()

        if state.settings.visible ~= state.visible[1] then
            state.settings.visible = state.visible[1]
            settings.save()
        end

        imgui.PopStyleVar(5)
        imgui.PopStyleColor(2)
    end

    return {
        render_config_window = render_config_window,
        render_main_window = render_main_window,
    }
end
