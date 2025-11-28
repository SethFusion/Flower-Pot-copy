-- Career stats
G.FUNCS.career_stats = function(e)
    G.SETTINGS.paused = true
    G.FUNCS.overlay_menu{
        definition = G.UIDEF.career_stats()
    }
end

function G.UIDEF.career_stats()
    return create_UIBox_generic_options({back_func = 'high_scores', contents ={
        {n=G.UIT.C, config = {align = "cm"}, nodes = {
            {n=G.UIT.O, config={id = 'career_stats', object = UIBox{definition = build_career_stats_master(1), config = {offset = {x=0,y=0}}}}}
        }}
    }})
end

function build_career_stats_master(page)
    local statlist = FlowerPot.carrer_records
    page = page or 1
    local row_count = 8
    local total_page_count = row_count * 2
    local career_stat_uiboxes_left = {}
    for i = 1, row_count do
        local career_stat = statlist[i+(total_page_count*(page-1))]
        if career_stat ~= nil then
            career_stat_uiboxes_left[#career_stat_uiboxes_left+1] = create_UIBox_career_stats_row(career_stat)
        end
    end
    local career_stat_uiboxes_right = {}
    for i = row_count+1, total_page_count do
        local career_stat = statlist[i+(total_page_count*(page-1))]
        if career_stat ~= nil then
            career_stat_uiboxes_right[#career_stat_uiboxes_right+1] = create_UIBox_career_stats_row(career_stat)
        end
    end

    local career_stat_options = {}
    for i = 1, math.ceil(#statlist/total_page_count) do
            table.insert(career_stat_options, localize('k_page')..' '..tostring(i)..'/'..tostring(math.ceil(#statlist/total_page_count)))
    end

    return {n=G.UIT.ROOT, config = {align = "cm", colour = G.C.CLEAR}, nodes = {
        {n=G.UIT.R, config = {align = "cm"}, nodes = {
            {n=G.UIT.C, config = {align = "tm", padding = 0.1, r = 0.1, colour = G.C.UI.TRANSPARENT_DARK, minh = 8.7}, nodes = {
                {n=G.UIT.C, config = {align = "cm", padding = 0.05}, nodes = career_stat_uiboxes_left}
            }},
            {n=G.UIT.C, config = {align = "tm", padding = 0.1, r = 0.1, colour = G.C.UI.TRANSPARENT_DARK, minh = 8.7}, nodes = {
                {n=G.UIT.C, config = {align = "cm", padding = 0.05}, nodes = career_stat_uiboxes_right}
            }}
        }},
        #statlist > total_page_count and {n=G.UIT.R, config={align = "cm"}, nodes={
            create_option_cycle({options = career_stat_options, w = 4.5, cycle_shoulders = true, opt_callback = 'career_stats_page', current_option = page, colour = G.C.RED, no_pips = true, focus_args = {snap_to = true, nav = 'wide'}})
        }} or nil
    }}
end


function create_UIBox_career_stats_row(career_stat)
    local career_stat_key = career_stat[1] -- index of key
    local str_color = career_stat[2] -- index of color
    local str_type = career_stat[3] -- index of str_type
    if str_type == "blank" then return end

    local career_stat_record = nil
    if type(str_type) == 'function' then
        career_stat_record, str_type = str_type()
    else
        career_stat_record = G.PROFILES[G.SETTINGS.profile].career_stats[career_stat_key]
    end
    if not career_stat_record then return nil end -- record is nil or invalid

    local label_text = localize(career_stat_key)
    if not label_text then label_text = "err-no dictionary found" end
    local label_scale = 0.65 - 0.005*math.max(string.len(label_text)-8, 0)
    local label_w, score_w, h = 3.5, 4, 0.8

    local row_data = {}
    if str_type == 'number' then
        row_data = {
            {n=G.UIT.O, config={object = DynaText({string = {number_format(career_stat_record)}, colours = {str_color},shadow = true, float = true, scale = score_number_scale(0.85, career_stat_record)})}}
        }
    elseif str_type == 'money' then
        row_data = {
            {n=G.UIT.O, config={object = DynaText({string = {localize('$')..number_format(career_stat_record)}, colours = {str_color},shadow = true, float = true, scale = score_number_scale(0.85, career_stat_record)})}},
        }
    elseif str_type == 'string' then
        row_data = {
            {n=G.UIT.O, config={object = DynaText({string = {career_stat_record}, colours = {str_color},shadow = true, float = true, scale = 0.65 - 0.005*math.max(string.len(career_stat_record)-8, 0)})}}
        }
    end
    return {n=G.UIT.R, config={align = "cm", padding = 0.05, r = 0.1, colour = darken(G.C.JOKER_GREY, 0.1), emboss = 0.05}, nodes={
        {n=G.UIT.C, config={align = "cm", padding = 0.05, minw = label_w, maxw = label_w}, nodes={
            {n=G.UIT.T, config={text = label_text, scale = label_scale, colour = G.C.UI.TEXT_LIGHT, shadow = true}},
        }},
        {n=G.UIT.C, config={align = "cl", minh = h, r = 0.1, minw = score_w, colour = G.C.BLACK, emboss = 0.05}, nodes={
            {n=G.UIT.C, config={align = "cm", padding = 0.05, r = 0.1, minw = score_w, maxw = score_w}, nodes=row_data},
        }},
    }}
end

G.FUNCS.career_stats_page = function(args)
    if not args or not args.cycle_config then return end
    local career_stats_uibox = G.OVERLAY_MENU:get_UIE_by_ID('career_stats')

    career_stats_uibox.config.object:remove()
    career_stats_uibox.config.object = UIBox{
	    definition = build_career_stats_master(args.cycle_config.current_option),
	    config = {offset = {x=0,y=0}, parent = career_stats_uibox},
	}
    career_stats_uibox.config.object:recalculate()
end