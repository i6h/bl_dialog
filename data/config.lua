
-- ============================ 
-- === Configuration ===
-- ============================

Config = {}

Config.transitionTime = 2000 -- Camera transition time between your ped and dialog ped
Config.interaction = 'target' -- Options: 'target' from bl_bridge, 'interact' from darktrovx

Config.pedDataList = {
    {
        ped = 'a_m_m_beach_01',
        ped_id = 'fisherman_1',
        coords = vector4(1255.79, 791.82, 103.37, 180),
        -- animation = {
        --     dict = "amb@world_human_stand_mobile@male@text@enter",
        --     name = "enter",
        --     loop = false 
        -- },
        -- prop = {
        --     propModel = 'prop_fishing_rod_01',
        --     bone = 28422,
        --     pos = vector3(0.1, 0.0, 0.0),
        --     rot = vector3(0.0, 0.0, 0.0),
        -- },
        scenario = "WORLD_HUMAN_CLIPBOARD",
        dialog = {
            {
                id = 'initial_fisherman_talk',
                job = 'Fisher Man',
                name = 'Nijjer',
                text = 'Give me fish then I\'ll let you go',
                buttons = {
                    {
                        id = 'leave1',
                        label = 'Don\'t give him fish',
                        reqRep = 0,
                        nextDialog = 'fisherman_second',
                        onSelect = function() 
                            -- Additional logic here
                        end
                    },
                    {
                        id = 'giveFish',
                        label = 'Give him fish',
                        reqRep = 60,
                        nextDialog = 'fisherman_talk_end',
                        onSelect = function() 
                            -- Additional logic here
                        end
                    },
                },
            },
            {
                id = 'fisherman_second',
                job = 'Fisher Man',
                name = 'Nijjer',
                text = 'You can\'t run from me, I\'m catching you!',
                buttons = {
                    {
                        id = 'comply',
                        label = 'Ok, I\'ll comply',
                        reqRep = 20,
                        nextDialog = 'fisherman_talk_end',
                        onSelect = function() 
                            -- Additional logic here
                        end
                    },
                },
            },
            {
                id = 'fisherman_talk_end',
                job = 'Fisher Man',
                name = 'Nijjer',
                text = 'Nijjer is happy now!',
                buttons = {
                    {
                        id = 'end',
                        label = 'End conversation',
                        close = true,
                    },
                },
            },
        }
    },
    {
        ped = 'a_f_m_beach_01',
        ped_id = 'fisherWoman',
        coords = vector4(1253.69, 791.22, 103.58, 190),
        -- animation = nil,
        -- prop = nil,
        scenario = nil,
        dialog = {
            {
                id = 'initial_fisherman_talkk',
                job = 'Fisher Woman',
                name = 'Robert',
                text = 'Give me fish then I\'ll let you go',
                buttons = {
                    {
                        id = 'leave1',
                        label = 'Don\'t give him fish',
                        reqRep = 0,
                        nextDialog = 'fisherman_secondd',
                        onSelect = function() 
                            -- Additional logic here
                        end
                    },
                    {
                        id = 'giveFish10',
                        label = 'Give him fish 10',
                        reqRep = 10,
                        nextDialog = 'fisherman_talk_endd',
                        onSelect = function() 
                            -- Additional logic here
                        end
                    },
                    {
                        id = 'giveFish20',
                        label = 'Give him fish 20',
                        reqRep = 20,
                        nextDialog = 'fisherman_talk_endd',
                        onSelect = function() 
                            -- Additional logic here
                        end
                    },
                },
            },
            {
                id = 'fisherman_secondd',
                job = 'Fisher Woman',
                name = 'Robert',
                text = 'You can\'t run from me, I\'m catching you!',
                buttons = {
                    {
                        id = 'comply',
                        label = 'Ok, I\'ll comply',
                        reqRep = 20,
                        nextDialog = 'fisherman_talk_endd',
                        onSelect = function() 
                            -- Additional logic here
                        end
                    },
                },
            },
            {
                id = 'fisherman_talk_endd',
                job = 'Fisher Woman',
                name = 'Robert',
                text = 'Robert is happy now!',
                buttons = {
                    {
                        id = 'end',
                        label = 'End conversation',
                        close = true,
                    },
                },
            },
        }
    },
}
