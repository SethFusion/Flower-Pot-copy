-- Poker hand stats
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
    local career_stat_uiboxes = {}
    for i = 1, row_count do
        local career_stat = statlist[i+(row_count*(page-1))]
        if career_stat ~= nil then
            career_stat_uiboxes[#career_stat_uiboxes+1] = create_UIBox_career_stats_row(career_stat)
        end
    end

    local career_stat_options = {}
    for i = 1, math.ceil(#statlist/row_count) do
            table.insert(career_stat_options, localize('k_page')..' '..tostring(i)..'/'..tostring(math.ceil(#statlist/row_count)))
    end

    return {n=G.UIT.ROOT, config = {align = "cm", colour = G.C.CLEAR}, nodes = {
        {n=G.UIT.C, config = {align = "cm"}, nodes = {
            {n=G.UIT.R, config = {align = "cm", padding = 0.1, r = 0.1, colour = G.C.UI.TRANSPARENT_DARK, minh = 8.7}, nodes = {
                {n=G.UIT.C, config = {align = "cm", padding = 0.05}, nodes = career_stat_uiboxes}
            }},
            #statlist > row_count and {n=G.UIT.R, config={align = "cm"}, nodes={
                create_option_cycle({options = career_stat_options, w = 4.5, cycle_shoulders = true, opt_callback = 'career_stats_page', current_option = page, colour = G.C.RED, no_pips = true, focus_args = {snap_to = true, nav = 'wide'}})
            }} or nil
        }}
    }}
end

function create_UIBox_career_stats_row(career_stat)
    local career_stat_key = career_stat[1] -- index of key
    local str_color = career_stat[2] -- index of color
    local str_type = career_stat[3] -- index of str_type
    if str_type == "blank" then return end

    local career_stat_record = nil
    if type(str_type) == 'function' then
        career_stat_record = str_type()
        str_type = 'number'
    else
        career_stat_record = G.PROFILES[G.SETTINGS.profile].career_stats[career_stat_key]
    end

    local label_text = localize(career_stat_key)
    if not career_stat_record then return nil end -- record is nil
    if not label_text then return nil end -- there is no localized label to display

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

function aaacreate_UIBox_high_scores_row(score)
  if score == 'poker_hand' then 
    local handname, amount = localize('k_none'), 0
    for k, v in pairs(G.PROFILES[G.SETTINGS.profile].hand_usage) do if v.count > amount then handname = v.order; amount = v.count end end
    score_tab = {
      {n=G.UIT.O, config={object = DynaText({string = {amount < 1 and handname or localize(handname,'poker_hands')}, colours = {G.C.WHITE},shadow = true, float = true, scale = 0.55})}},
      {n=G.UIT.T, config={text = " ("..amount..")", scale = 0.45, colour = G.C.JOKER_GREY}}
    }
  elseif score == 'hand' then 
    local chip_sprite = Sprite(0,0,0.4,0.4,G.ASSET_ATLAS["ui_"..(G.SETTINGS.colourblind_option and 2 or 1)], {x=0, y=0})
    chip_sprite.states.drag.can = false
    score_tab = {
      {n=G.UIT.C, config={align = "cm"}, nodes={
        {n=G.UIT.O, config={w=0.4,h=0.4 , object = chip_sprite}}
      }},
      {n=G.UIT.C, config={align = "cm"}, nodes={
        {n=G.UIT.O, config={object = DynaText({string = {number_format(G.PROFILES[G.SETTINGS.profile].high_scores[score].amt)}, colours = {G.C.RED},shadow = true, float = true, scale = math.min(0.75, score_number_scale(1.5, G.PROFILES[G.SETTINGS.profile].high_scores[score].amt))})}},
      }},
    }
  elseif score == 'collection' then 
    score_tab = {
      {n=G.UIT.C, config={align = "cm"}, nodes={
        {n=G.UIT.O, config={object = DynaText({string = {'%'..math.floor(0.01+100*G.PROFILES[G.SETTINGS.profile].high_scores[score].amt/G.PROFILES[G.SETTINGS.profile].high_scores[score].tot)}, colours = {G.C.WHITE},shadow = true, float = true, scale = math.min(0.75, score_number_scale(1.5, G.PROFILES[G.SETTINGS.profile].high_scores[score].amt))})}},
        {n=G.UIT.T, config={text = " ("..G.PROFILES[G.SETTINGS.profile].high_scores[score].amt..'/'..G.PROFILES[G.SETTINGS.profile].high_scores[score].tot..")", scale = 0.45, colour = G.C.JOKER_GREY}}
      }},
    }
  else
    score_tab = {
      {n=G.UIT.O, config={object = DynaText({string = {number_format(G.PROFILES[G.SETTINGS.profile].high_scores[score].amt)}, colours = {G.C.FILTER},shadow = true, float = true, scale = score_number_scale(0.85, G.PROFILES[G.SETTINGS.profile].high_scores[score].amt)})}},
    }
  end
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