-- Shared configuration for TV script

Config = {}

-- All TV, Computer, and Tablet Models available
Config.Props = {
    -- TVs
    "v_res_m_tv",
    "v_res_d_tv",
    "v_res_tv01",
    "v_res_tv02",
    "v_res_tv_broken",
    "v_res_tv_broken2",
    "v_res_bk_tv_stand",
    "v_res_bk_monitor",
    "v_res_fh_monitor",
    "v_res_j_tv",
    "v_res_j_tv_tuner",
    "prop_tv_flat_huge",
    "prop_tv_flat_large",
    "prop_tv_flat_mid",
    "prop_tv_flat_small",
    "prop_tv_cabinet",
    "prop_arcade_tv",
    "prop_monitor_02",
    "prop_monitor_03",
    "prop_monitor_04",
    "prop_monitor_05",
    "prop_monitor_06",
    "prop_monitor_07",
    "prop_monitor_08",
    "prop_monitor_09",
    "prop_monitor_10",
    "prop_monitor_11",
    "prop_monitor_12",
    "prop_monitor_13",
    "prop_monitor_14",
    
    -- Computers
    "p_monitor",
    "p_monitor_02",
    "prop_pc",
    "prop_pc_broken",
    "prop_pc_monitor",
    "prop_keyboard_01",
    "prop_keyboard_02",
    "prop_keyboard_03",
    "prop_monitor_keyboard",
    "prop_desktop_01",
    "prop_laptop_01a",
    "prop_laptop_01b",
    "prop_laptop_02",
    "prop_laptop_03",
    
    -- Tablets & Phones
    "prop_tablet_01a",
    "prop_tablet_01b",
    "prop_tablet_02",
    "prop_tablet_03",
    "prop_notepad_01",
    "prop_phone_01",
    "prop_phone_02",
    
    -- Additional monitors and screens
    "ba_prop_battle_monitor_01",
    "ba_prop_battle_monitor_02",
    "ba_prop_battle_monitor_03",
    "ba_prop_battle_monitor_04",
    "ba_prop_battle_monitor_05",
    "ba_prop_battle_monitor_06",
    "ba_prop_battle_monitor_07",
    "ba_prop_battle_monitor_08",
    "ba_prop_battle_monitor_09",
    "ba_prop_battle_monitor_10",
    "ba_prop_battle_monitor_11",
}

-- Supported video platforms
Config.SupportedPlatforms = {
    "youtube",
    "twitch",
    "vimeo",
    "custom",
    "mp4",
    "webm",
    "ogg"
}

-- Interaction distance (in meters)
Config.InteractionDistance = 25.0

-- Enable notifications
Config.EnableNotifications = true
