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

data.ElementalOreZones = {
    [2] = true,   -- Carpenters' Landing
    [4] = true,   -- Bibiki Bay
    [51] = true,  -- Wajaom Woodlands
    [52] = true,  -- Bhaflau Thickets
    [100] = true, -- West Ronfaure
    [101] = true, -- East Ronfaure
    [102] = true, -- La Theine Plateau
    [103] = true, -- Valkurm Dunes
    [104] = true, -- Jugner Forest
    [105] = true, -- Batallia Downs
    [106] = true, -- North Gustaberg
    [107] = true, -- South Gustaberg
    [108] = true, -- Konschtat Highlands
    [109] = true, -- Pashhow Marshlands
    [110] = true, -- Rolanberry Fields
    [115] = true, -- West Sarutabaruta
    [116] = true, -- East Sarutabaruta
    [117] = true, -- Tahrongi Canyon
    [118] = true, -- Buburimu Peninsula
    [119] = true, -- Meriphataud Mountains
    [120] = true, -- Sauromugue Champaign
    [121] = true, -- The Sanctuary of Zi'Tah
}

data.Colors = {
    -- Floos DarkGold palette: charcoal-brown panels with restrained gold trim.
    window_bg = { 0.051, 0.051, 0.051, 0.95 },
    panel_bg = { 0.098, 0.090, 0.075, 1.0 },
    border = { 0.957, 0.855, 0.592, 0.85 },
    title_bg = { 0.137, 0.125, 0.106, 1.0 },
    title_bg_active = { 0.176, 0.161, 0.137, 1.0 },
    gold = { 0.957, 0.855, 0.592, 1.0 },
    gold_soft = { 0.765, 0.684, 0.474, 1.0 },
    text = { 0.878, 0.855, 0.812, 1.0 },
    text_dim = { 0.600, 0.580, 0.540, 1.0 },
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
    ['batallia downs'] = { 'Pebble', 'Flint Stone', 'Bone Chip', 'Copper Ore', 'Iron Ore', 'Bird Feather', 'Red Jar', 'Purple Rock', 'Black Chocobo Feather', 'Reishi Mushroom' },
    ['bhaflau thickets'] = { 'Dried Marjoram', 'Pebble', 'Pine Nuts', 'Colibri Feather', 'Petrified Log', 'Blue Rock', 'Lesser Chigoe', 'Spider Web', 'Orichalcum Ore' },
    ['bibiki bay'] = { 'Seashell', 'Tin Ore', 'Lugworm', 'Giant Femur', 'Bird Feather', 'Shall Shell', 'Shell Bug', 'Turtle Shell' },
    ['buburimu peninsula'] = { 'Tin Ore', 'Seashell', 'Lugworm', 'Giant Femur', 'Bird Feather', 'Shell Bug', 'Shall Shell', 'Platinum Ore', 'Turtle Shell' },
    ["carpenter's landing"] = { 'Acorn', 'Little Worm', 'Arrowwood Log', 'Maple Log', 'Holly Log', 'Willow Log', 'Oak Log', 'Scream Fungus', 'Mistletoe', 'King Truffle' },
    ["carpenters' landing"] = { 'Acorn', 'Little Worm', 'Arrowwood Log', 'Maple Log', 'Holly Log', 'Willow Log', 'Oak Log', 'Scream Fungus', 'Mistletoe', 'King Truffle' },
    ['east ronfaure'] = { 'Acorn', 'Little Worm', 'Arrowwood Log', 'Chocobo Feather', 'Maple Log', 'Ronfaure Chestnut', 'Ash Log', 'Chestnut Log', 'Fruit Seeds', 'Mistletoe' },
    ['east sarutabaruta'] = { 'Pebble', 'Lauan Log', 'Papaka Grass', 'Insect Wing', 'Yagudo Feather', 'Bird Feather', 'Rosewood Log', 'Green Rock', 'Herb Seeds', 'Saruta Cotton' },
    ['eastern altepa desert'] = { 'Bone Chip', 'Pebble', 'Giant Femur', 'Zinc Ore', 'Silver Ore', 'Wyvern Scales', 'Mythril Ore', 'Platinum Ore', "Philosopher's Stone" },
    ['jugner forest'] = { 'Acorn', 'Arrowwood Log', 'Little Worm', 'Maple Log', 'Willow Log', 'Holly Log', 'Oak Log', 'Scream Fungus', 'Mistletoe' },
    ['konschtat highlands'] = { 'Pebble', 'Bone Chip', 'Flint Stone', 'Fish Scales', 'Zinc Ore', 'Elm Log', 'Bird Feather', 'Lizard Molt', 'Mythril Beastcoin', 'Phoenix Feather' },
    ['la theine plateau'] = { 'Pebble', 'Arrowwood Log', 'Little Worm', 'Tin Ore', 'Chocobo Feather', 'Yew Log', 'Zinc Ore', 'Chestnut Log', 'Dried Marjoram', 'Mahogany Log' },
    ['meriphataud mountains'] = { 'Pebble', 'Flint Stone', 'Insect Wing', 'Lizard Molt', 'Copper Ore', 'Giant Femur', 'Yellow Rock', 'Gold Beastcoin', 'Black Chocobo Feather', 'Adaman Ore' },
    ['north gustaberg'] = { 'Pebble', 'Insect Wing', 'Little Worm', 'Bone Chip', 'Fish Scales', 'Lizard Molt', 'Flint Stone', 'Bird Feather', 'Mythril Beastcoin', 'Darksteel Ore' },
    ['pashhow marshlands'] = { 'Insect Wing', 'Pebble', 'Lizard Molt', 'Willow Log', 'Silver Ore', 'Mythril Beastcoin', 'Black Rock', 'Puffball', 'Turtle Shell' },
    ['rolanberry fields'] = { 'Pebble', 'Flint Stone', 'Little Worm', 'Insect Wing', 'Sage', 'Mythril Beastcoin', 'Red Jar', 'Coral Fungus', 'Gold Beastcoin', 'Orichalcum Ore' },
    ['sauromugue champaign'] = { 'Pebble', 'Bone Chip', 'Flint Stone', 'Insect Wing', 'Lizard Molt', 'Iron Ore', 'Red Jar', 'Gold Beastcoin', 'Black Chocobo Feather' },
    ['south gustaberg'] = { 'Pebble', 'Little Worm', 'Lizard Molt', 'Bone Chip', 'Insect Wing', 'Rock Salt', 'Bird Feather', 'Mythril Beastcoin', 'Grain Seeds' },
    ['tahrongi canyon'] = { 'Pebble', 'Bone Chip', 'Seashell', 'Tin Ore', 'Insect Wing', 'Yagudo Feather', 'Giant Femur', 'Red Rock', 'Gold Ore' },
    ["the sanctuary of zi'tah"] = { 'Pebble', 'Bone Chip', 'Moko Grass', 'Arrowwood Log', 'Yew Log', 'Elm Log', 'Translucent Rock', 'King Truffle' },
    ['valkurm dunes'] = { 'Seashell', 'Bone Chip', 'Fish Scales', 'Lizard Molt', 'Lugworm', 'Giant Femur', 'Shall Shell', 'Shell Bug', 'Turtle Shell' },
    ['wajaom woodlands'] = { 'Moko Grass', 'Pebble', 'Pine Nuts', 'Black Chocobo Feather', 'Blue Rock', 'Ebony Log', 'Pephredo Hive Chip', 'Spider Web', 'Adaman Ore' },
    ['west ronfaure'] = { 'Little Worm', 'Acorn', 'Arrowwood Log', 'Moko Grass', 'Chocobo Feather', 'Maple Log', 'Ash Log', 'Ronfaure Chestnut', 'Chestnut Log', 'Vegetable Seeds', 'Mistletoe' },
    ['west sarutabaruta'] = { 'Pebble', 'Little Worm', 'Lauan Log', 'Insect Wing', 'Moko Grass', 'Yagudo Feather', 'Bird Feather', 'Saruta Cotton', 'Tree Cuttings' },
    ['western altepa desert'] = { 'Bone Chip', 'Pebble', 'Giant Femur', 'Zinc Ore', 'Iron Ore', 'Coral Fragment', 'Gold Ore', 'Darksteel Ore', "Philosopher's Stone" },
    ['yhoator jungle'] = { 'Bone Chip', 'Lauan Log', 'Kazham Pineapple', 'Dryad Root', 'Mahogany Log', 'Ebony Log', 'Coral Fungus', 'Petrified Log', 'Reishi Mushroom' },
    ['yuhtunga jungle'] = { 'Bone Chip', 'Rattan Lumber', 'Cinnamon', 'Danceshroom', 'Rosewood Log', 'Ebony Log', 'Petrified Log', 'Puffball', 'King Truffle' },
}

return data