Config = {}

Config.transitionTime = 2000 -- camera transition time between your ped and dialog ped
Config.Debug = false -- debug for debugging
Config.pedDataList = { -- peds :D 
    {
        ped = 'a_m_m_beach_01',
        ped_id = 'fisherman_1', -- must be unique
        coords = vector4(1255.79, 791.82, 104.37 - 1, 180),
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
                        onSelect = function() end
                    },
                    {
                        id = 'giveFish',
                        label = 'Give him fish',
                        reqRep = 60,
                        nextDialog = 'fisherman_talk_end',
                        onSelect = function() end
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
                        onSelect = function() end
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
        ped_id = 'fisherWoman', -- must be unique
        coords = vector4(1253.69, 791.22, 104.58 - 1,190),
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
                        onSelect = function() end
                    },
                    {
                        id = 'giveFish',
                        label = 'Give him fish 10',
                        reqRep = 10,
                        nextDialog = 'fisherman_talk_endd',
                        onSelect = function() end
                    },
                    {
                        id = 'giveFish',
                        label = 'Give him fish 20',
                        reqRep = 20,
                        nextDialog = 'fisherman_talk_endd',
                        onSelect = function() end
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
                        nextDialog = 'fisherman_talk_end',
                        onSelect = function() end
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