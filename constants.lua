local data = {}

data.MoonPhasePercent = T{
    [1] = 100, [2] = 98, [3] = 95, [4] = 93, [5] = 90, [6] = 88, [7] = 86,
    [8] = 83, [9] = 81, [10] = 79, [11] = 76, [12] = 74, [13] = 71, [14] = 69,
    [15] = 67, [16] = 64, [17] = 62, [18] = 60, [19] = 57, [20] = 55, [21] = 52,
    [22] = 50, [23] = 48, [24] = 45, [25] = 43, [26] = 40, [27] = 38, [28] = 36,
    [29] = 33, [30] = 31, [31] = 29, [32] = 26, [33] = 24, [34] = 21, [35] = 19,
    [36] = 17, [37] = 14, [38] = 12, [39] = 10, [40] = 7, [41] = 5, [42] = 2,
    [43] = 0, [44] = 2, [45] = 5, [46] = 7, [47] = 10, [48] = 12, [49] = 14,
    [50] = 17, [51] = 19, [52] = 21, [53] = 24, [54] = 26, [55] = 29, [56] = 31,
    [57] = 33, [58] = 36, [59] = 38, [60] = 40, [61] = 43, [62] = 45, [63] = 48,
    [64] = 50, [65] = 52, [66] = 55, [67] = 57, [68] = 60, [69] = 62, [70] = 64,
    [71] = 67, [72] = 69, [73] = 71, [74] = 74, [75] = 76, [76] = 79, [77] = 81,
    [78] = 83, [79] = 86, [80] = 88, [81] = 90, [82] = 93, [83] = 95, [84] = 98,
}

data.MoonPhase = T{
    [1] = 'Full Moon', [2] = 'Full Moon', [3] = 'Full Moon',
    [4] = 'Waning Gibbous', [5] = 'Waning Gibbous', [6] = 'Waning Gibbous', [7] = 'Waning Gibbous',
    [8] = 'Waning Gibbous', [9] = 'Waning Gibbous', [10] = 'Waning Gibbous', [11] = 'Waning Gibbous',
    [12] = 'Waning Gibbous', [13] = 'Waning Gibbous', [14] = 'Waning Gibbous', [15] = 'Waning Gibbous',
    [16] = 'Waning Gibbous', [17] = 'Waning Gibbous',
    [18] = 'Last Quarter', [19] = 'Last Quarter', [20] = 'Last Quarter', [21] = 'Last Quarter',
    [22] = 'Last Quarter', [23] = 'Last Quarter', [24] = 'Last Quarter', [25] = 'Last Quarter',
    [26] = 'Waning Crescent', [27] = 'Waning Crescent', [28] = 'Waning Crescent', [29] = 'Waning Crescent',
    [30] = 'Waning Crescent', [31] = 'Waning Crescent', [32] = 'Waning Crescent', [33] = 'Waning Crescent',
    [34] = 'Waning Crescent', [35] = 'Waning Crescent', [36] = 'Waning Crescent', [37] = 'Waning Crescent',
    [38] = 'Waning Crescent',
    [39] = 'New Moon', [40] = 'New Moon', [41] = 'New Moon', [42] = 'New Moon', [43] = 'New Moon',
    [44] = 'New Moon', [45] = 'New Moon',
    [46] = 'Waxing Crescent', [47] = 'Waxing Crescent', [48] = 'Waxing Crescent', [49] = 'Waxing Crescent',
    [50] = 'Waxing Crescent', [51] = 'Waxing Crescent', [52] = 'Waxing Crescent', [53] = 'Waxing Crescent',
    [54] = 'Waxing Crescent', [55] = 'Waxing Crescent', [56] = 'Waxing Crescent', [57] = 'Waxing Crescent',
    [58] = 'Waxing Crescent',
    [59] = 'First Quarter', [60] = 'First Quarter', [61] = 'First Quarter', [62] = 'First Quarter',
    [63] = 'First Quarter', [64] = 'First Quarter', [65] = 'First Quarter', [66] = 'First Quarter',
    [67] = 'Waxing Gibbous', [68] = 'Waxing Gibbous', [69] = 'Waxing Gibbous', [70] = 'Waxing Gibbous',
    [71] = 'Waxing Gibbous', [72] = 'Waxing Gibbous', [73] = 'Waxing Gibbous', [74] = 'Waxing Gibbous',
    [75] = 'Waxing Gibbous', [76] = 'Waxing Gibbous', [77] = 'Waxing Gibbous', [78] = 'Waxing Gibbous',
    [79] = 'Waxing Gibbous', [80] = 'Waxing Gibbous',
    [81] = 'Full Moon', [82] = 'Full Moon', [83] = 'Full Moon', [84] = 'Full Moon',
}

data.Weather = T{
    [0] = 'Clear', [1] = 'Sunshine', [2] = 'Clouds', [3] = 'Fog',
    [4] = 'Fire', [5] = 'Fire x2', [6] = 'Water', [7] = 'Water x2',
    [8] = 'Earth', [9] = 'Earth x2', [10] = 'Wind', [11] = 'Wind x2',
    [12] = 'Ice', [13] = 'Ice x2', [14] = 'Thunder', [15] = 'Thunder x2',
    [16] = 'Light', [17] = 'Light x2', [18] = 'Dark', [19] = 'Dark x2',
}

data.Colors = {
    window_bg = { 0.05, 0.05, 0.05, 0.98 },
    panel_bg = { 0.09, 0.09, 0.08, 0.96 },
    border = { 0.74, 0.62, 0.35, 1.0 },
    title_bg = { 0.34, 0.23, 0.09, 1.0 },
    title_bg_active = { 0.45, 0.30, 0.10, 1.0 },
    gold = { 0.98, 0.88, 0.48, 1.0 },
    gold_soft = { 0.92, 0.76, 0.42, 1.0 },
    text = { 0.92, 0.92, 0.90, 1.0 },
    text_dim = { 0.68, 0.68, 0.66, 1.0 },
    success = { 0.34, 0.82, 0.42, 1.0 },
    warn = { 0.90, 0.60, 0.20, 1.0 },
    danger = { 0.90, 0.30, 0.26, 1.0 },
    info = { 0.52, 0.74, 0.96, 1.0 },
}

data.WeatherColors = {
    ['Clear'] = data.Colors.text,
    ['Sunshine'] = data.Colors.text,
    ['Clouds'] = data.Colors.text,
    ['Fog'] = { 0.74, 0.68, 0.82, 1.0 },
    ['Fire'] = { 0.95, 0.38, 0.26, 1.0 },
    ['Fire x2'] = { 0.95, 0.38, 0.26, 1.0 },
    ['Water'] = { 0.38, 0.65, 0.95, 1.0 },
    ['Water x2'] = { 0.38, 0.65, 0.95, 1.0 },
    ['Earth'] = { 0.72, 0.58, 0.32, 1.0 },
    ['Earth x2'] = { 0.72, 0.58, 0.32, 1.0 },
    ['Wind'] = { 0.42, 0.86, 0.42, 1.0 },
    ['Wind x2'] = { 0.42, 0.86, 0.42, 1.0 },
    ['Ice'] = { 0.48, 0.82, 0.96, 1.0 },
    ['Ice x2'] = { 0.48, 0.82, 0.96, 1.0 },
    ['Thunder'] = { 0.74, 0.52, 0.96, 1.0 },
    ['Thunder x2'] = { 0.74, 0.52, 0.96, 1.0 },
    ['Light'] = data.Colors.gold,
    ['Light x2'] = data.Colors.gold,
    ['Dark'] = { 0.84, 0.50, 0.96, 1.0 },
    ['Dark x2'] = { 0.84, 0.50, 0.96, 1.0 },
    ['Unknown'] = data.Colors.text,
}

data.ZoneItems = {
    ['batallia downs'] = {
        'Bird Feather', 'Bone Chip', 'Black Chocobo Feather', 'Copper Ore',
        'Flint Stone', 'Iron Ore', 'Pebble', 'Purple Rock', 'Red Jar', 'Reishi Mushroom',
        'Bird Egg', 'Colored Egg', 'Hard-Boiled Egg', 'Soft-Boiled Egg', 'Sairui-Ran',
    },
    ['buburimu peninsula'] = {
        'Bird Feather', 'Seashell', 'Giant Femur', 'Shell Bug', 'Shall Shell',
        'Turtle Shell', 'Gold Beastcoin', 'Crawler Cocoon', 'Crab Shell', 'High-Quality Crab Shell',
    },
    ['bibiki bay'] = {
        'Bird Feather', 'Coral Fragment', 'Giant Femur', 'Lugworm', 'Platinum Ore',
        'Seashell', 'Shall Shell', 'Shell Bug', 'Tin Ore', 'Turtle Shell',
    },
    ["carpenter's landing"] = {
        'Acorn', 'Arrowwood Log', 'Holly Log', 'King Truffle', 'Little Worm',
        'Maple Log', 'Mistletoe', 'Oak Log', 'Scream Fungus', 'Willow Log',
    },
    ["carpenters' landing"] = {
        'Acorn', 'Arrowwood Log', 'Holly Log', 'King Truffle', 'Little Worm',
        'Maple Log', 'Mistletoe', 'Oak Log', 'Scream Fungus', 'Willow Log',
    },
    ['eastern altepa desert'] = {
        'Bone Chip', 'Giant Femur', 'Pebble', 'Silver Ore', 'Mythril Ore',
        "Philosopher's Stone", 'Platinum Ore', 'Wyvern Scales', 'Zinc Ore',
    },
    ['east ronfaure'] = {
        'Acorn', 'Arrowwood Log', 'Little Worm', 'Ash Log', 'Chocobo Feather',
        'Maple Log', 'Chestnut', 'Chestnut Log', 'King Truffle', 'Mistletoe', 'Fruit Seeds',
    },
    ['east sarutabaruta'] = {
        'Lauan Log', 'Papaka Grass', 'Pebble', 'Ebony Log', 'Bird Feather',
        'Insect Wing', 'Moko Grass', 'Yagudo Feather', 'Saruta Cotton', 'Green Rock',
        'Rosewood Log', 'Herb Seeds',
    },
    ['jugner forest'] = {
        'Acorn', 'Arrowwood Log', 'Holly Log', 'King Truffle', 'Little Worm',
        'Maple Log', 'Mistletoe', 'Oak Log', 'Scream Fungus', 'Willow Log', 'Ebony Log',
    },
    ['konschtat highlands'] = {
        'Bird Feather', 'Bone Chip', 'Elm Log', 'Fish Scales', 'Flint Stone',
        'Lizard Molt', 'Mythril Beastcoin', 'Pebble', 'Phoenix Feather', 'Pugil Scales', 'Zinc Ore',
    },
    ['la theine plateau'] = {
        'Little Worm', 'Arrowwood Log', 'Chocobo Feather', 'Dried Marjoram',
        'Yew Log', 'Chestnut Log', 'Fresh Mugwort', 'Scream Fungus', 'Sobbing Fungus', 'King Truffle',
    },
    ['meriphataud mountains'] = {
        'Adaman Ore', 'Black Chocobo Feather', 'Copper Ore', 'Giant Femur',
        'Gold Beastcoin', 'Insect Wing', 'Lizard Molt', 'Pebble', 'Yellow Rock', 'Iron Ore',
    },
    ['north gustaberg'] = {
        'Bone Chip', 'Little Worm', 'Pebble', 'Bird Feather', 'Fish Scales',
        'Insect Wing', 'Lizard Molt', 'Pugil Scales', 'Mythril Beastcoin', 'Mythril Ore', 'Darksteel Ore',
    },
    ['pashhow marshlands'] = {
        'Insect Wing', 'Pebble', 'Lizard Molt', 'Silver Ore', 'Willow Log',
        'Puffball', 'Black Rock', 'Mythril Beastcoin', 'Petrified Log', 'Turtle Shell',
    },
    ['rolanberry fields'] = {
        'Coral Fungus', 'Deathball', 'Flint Stone', 'Gold Beastcoin', 'Mythril Beastcoin',
        'Orichalcum Ore', 'Pebble', 'Puffball', 'Sage', 'Red Jar', 'Darksteel Ore',
    },
    ['sauromugue champaign'] = {
        'Black Chocobo Feather', 'Bone Chip', 'Flint Stone', 'Gold Beastcoin',
        'Iron Ore', 'Lizard Molt', 'Pebble', 'Red Jar', 'Translucent Rock', 'Adaman Ore',
    },
    ['south gustaberg'] = {
        'Pebble', 'Little Worm', 'Insect Wing', 'Bone Chip', 'Rock Salt',
        'Lizard Molt', 'Mythril Beastcoin', 'Bird Feather', 'White Rock', 'Mythril Ore', 'Grain Seeds',
    },
    ['tahrongi canyon'] = {
        'Bone Chip', 'Pebble', 'Insect Wing', 'Seashell', 'Tin Ore',
        'Yagudo Feather', 'Giant Femur', 'Red Rock', 'Gold Ore', 'Platinum Ore',
    },
    ["the sanctuary of zi'tah"] = {
        'Pebble', 'Bone Chip', 'Maple Log', 'Yew Log', 'Elm Log',
        'Green Rock', 'Translucent Rock', 'Petrified Log', 'Tree Cuttings', 'Golem Shard',
    },
    ['valkurm dunes'] = {
        'Bone Chip', 'Seashell', 'Giant Femur', 'Shell Bug', 'Blue Rock',
        'Wyvern Scales', 'Copper Ore', 'Silver Ore', 'Gold Ore', 'Coral Fragment',
    },
    ['west ronfaure'] = {
        'Acorn', 'Arrowwood Log', 'Little Worm', 'Ash Log', 'Chocobo Feather',
        'Maple Log', 'Moko Grass', 'Chestnut', 'Chestnut Log', 'Mistletoe', 'Vegetable Seeds',
    },
    ['west sarutabaruta'] = {
        'Lauan Log', 'Little Worm', 'Pebble', 'Gysahl Greens', 'Bird Feather',
        'Insect Wing', 'Moko Grass', 'Yagudo Feather', 'Saruta Cotton', 'Rosewood Log',
        'Ebony Log', 'Tree Cuttings',
    },
    ['western altepa desert'] = {
        'Bone Chip', 'Giant Femur', 'Pebble', 'Iron Ore', 'Zinc Ore',
        'Coral Fragment', 'Darksteel Ore', 'Fish Scales', 'Gold Ore', "Philosopher's Stone", 'Giant Bird Plume',
    },
    ['yhoator jungle'] = {
        'Bone Chip', 'Lauan Log', 'Kazham Pineapple', 'Dryad Root', 'Ebony Log',
        'Mahogany Log', 'Coral Fungus', 'Petrified Log', 'Reishi Mushroom',
    },
    ['yuhtunga jungle'] = {
        'Bone Chip', 'Cinnamon', 'Rattan Lumber', 'Danceshroom', 'King Truffle',
        'Petrified Log', 'Puffball', 'Ebony Log', 'Mushroom Locust', 'Rosewood Log',
    },
}

return data