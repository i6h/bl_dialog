# This is a fork of [bl dialog](https://github.com/Byte-Labs-Studio/bl_dialog) and has been edited to include ped spawning and a reputation system.
- I know it's not the best, but I gave it a try.
## You should run this sql to work
```sql
CREATE TABLE `dialog_reputation` (
	`identifier` VARCHAR(50) NOT NULL COLLATE 'utf8mb3_general_ci',
	`ped_id` VARCHAR(50) NOT NULL COLLATE 'utf8mb3_general_ci',
	`reputation` INT(11) NOT NULL DEFAULT '0',
	PRIMARY KEY (`identifier`, `ped_id`) USING BTREE
)
COLLATE='utf8mb3_general_ci'
ENGINE=InnoDB;
```

## dependency
* [bl_bridge](https://github.com/Byte-Labs-Studio/bl_bridge)
* [ox_lib](https://github.com/overextended/ox_lib)
* [oxmysql](https://github.com/overextended/oxmysql)

# BL Dialog

Docs: https://docs.byte-labs.net/bl_dialog/exports

Preview: https://streamable.com/gz0get 

## Code used for preview 

```lua
exports.bl_dialog:setupPed({
    ped = 'a_m_m_beach_01', -- ped modal
    ped_id = 'fisherman_1', -- must be unique
    coords = vector4(1255.79, 791.82, 104.37 - 1, 180), -- ped coords to spawn
    -- animation = { 
    --     dict = "amb@world_human_stand_mobile@male@text@enter",
    --     name = "enter",
    --     loop = false 
    -- },
    -- prop = nil,
    scenario = "WORLD_HUMAN_CLIPBOARD",
    dialog = {
        {
            id = 'initial_fisherman_talk',
            job = 'Fisher Man',
            name = 'Robert',
            text = 'Give me fish then ill let you go',
            buttons = {
                {
                    id = 'leave1',
                    label = 'Don\'t give him fish',
                    reqRep = 0,
                    nextDialog = 'fisherman_second', -- switch to second dialog
                    onSelect = function(switchDialog)
                        -- you can make ped hit you bcs you didnt give him fish?
                    end
                },
                {
                    id = 'leave1',
                    label = 'Give him fish',
                    reqRep = 2,
                    nextDialog = 'fisherman_talk_end', -- switch to third dialog
                },
            },
        },
        {
            id = 'fisherman_second',
            job = 'Fisher Man',
            name = 'Robert',
            text = 'You cant run from me, im catching you!',
            buttons = {
                {
                    id = 'leave2',
                    label = 'Ok, ill give you',
                    reqRep = 2,
                    nextDialog = 'initial_fish_talk',
                },
            },
        },
        {
            id = 'fisherman_talk_end',
            job = 'Fisher Man',
            name = 'Robert',
            text = 'Robert is happy now!',
            buttons = {
                {
                    id = 'end',
                    label = 'End conversation', --end conversation
                    close = true,
                },
            },
        },
    }
})
```
---
If there is an issue, you can message me anywhere.