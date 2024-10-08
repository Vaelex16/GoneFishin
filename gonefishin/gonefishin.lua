addon.name      = 'GoneFishin';
addon.author    = 'Vaelex';
addon.version   = '1.2';
addon.desc      = 'Displays statistical data from fishing, as well as quick a quick view for fish/feelings.';
addon.link      = 'https://github.com/Vaelex16/GoneFishin/';

require('common');
local fonts = require('fonts');
local settings = require('settings');
local chat = require('chat');
local imgui = require('imgui');
local scaling = require('scaling');

local function print_help(isError)
    -- Print the help header..
    if (isError) then
        print(chat.header(addon.name):append(chat.error(
                                                 'Invalid command syntax for command: '))
                  :append(chat.success('/' .. 'gf')));
    else
        print(
            chat.header(addon.name):append(chat.message('Available commands:')));
    end

    local cmds = T{
        {'/gf config', 'Opens the config window.'},    
        {'/gf reset', 'Resets the current fishing session.'},
        {'/gf save', 'Saves the current settings to disk.'},
        {'/gf reload', 'Reloads current settings from disk.'},        
        {'/gf pause', 'Pauses the current session timer.'},
        {'/gf show', 'Shows the fishing session window.'},
        {'/gf hide','Hides the fishing session window.'},
    }
    -- Print the command list..
    cmds:ieach(function(v)
        print(chat.header(addon.name):append(chat.error('Usage: ')):append(
                  chat.message(v[1]):append(' - ')):append(chat.color1(6, v[2])));
    end);
end

local player;

local default_settings = T{
    
    displayTimeout = T {600},
    sessionTimeout = T {60},
    opacity = T {1.0},
    padding = T {1.0},
    scale = T {1.0},
    font_scale = T {1.5},
    x = T {100},
    y = T {100},

    goodColor = {0.0, 1.0, 0.0, 1.0},
    itemColor = {1.0, 1.0, 0.0, 1.0},
    badColor = {1.0, 0.0, 0.0, 1.0},

    showItem = T {true},
    showMonster = T {true},
    showGiveup = T {true},
    showSkill = T {true},
    showNothing = T {true},
    visible = T {true},
    fishInfoVisible =  T {true},
    playerSkill = nil,
    showPlayerSkill = T {true},
    showFishValue = T{true},
    showTotalGil = T{true},
    showGPH = T{true},

    FishValues = T {
    [1] = "abaia:1920",
    [2] = "adoulinian kelp:0",
    [3] = "ahtapot:700",
    [4] = "alabaligi:98",
    [5] = "armored pisces:969",
    [6] = "arrowwood log:5",
    [7] = "bastore bream:600",
    [8] = "bastore sardine:9",
    [9] = "bastore sweeper:93",
    [10] = "betta:186",
    [11] = "bhefhel marlin:307",
    [12] = "bibiki urchin:750",
    [13] = "bibikibo:99",
    [14] = "black bubble-eye:9",
    [15] = "black eel:192",
    [16] = "black ghost:314",
    [17] = "black sole:700",
    [18] = "bladefish:408",
    [19] = "blindfish:229",
    [20] = "bluetail:300",
    [21] = "brass loach:276",
    [22] = "bugbear mask:0",
    [23] = "ca cuong:560",
    [24] = "caedarva frog:100",
    [25] = "calico comet:12",
    [26] = "cave cherax:1600",
    [27] = "cheval salmon:20",
    [28] = "cobalt jellyfish:11",
    [29] = "cone calamary:165",
    [30] = "copper frog:20",
    [31] = "copper ring:19",
    [32] = "coral butterfly:127",
    [33] = "coral fragment:1750",
    [34] = "crayfish:10",
    [35] = "crescent fish:403",
    [36] = "crystal bass:0",
    [37] = "damp scroll:1",
    [38] = "dark bass:20",
    [39] = "denizanasi:7",
    [40] = "dil:700",
    [41] = "elshimo frog:52",
    [42] = "elshimo newt:179",
    [43] = "emperor fish:615",
    [44] = "fat greedie:0",
    [45] = "fish scale shield:384",
    [46] = "forest carp:22",
    [47] = "garpike:610",
    [48] = "gavial fish:500",
    [49] = "gerrothorax:118",
    [50] = "giant catfish:102",
    [51] = "giant chirai:1100",
    [52] = "giant donko:195",
    [53] = "gigant octopus:238",
    [54] = "gigant squid:612",
    [55] = "gil:0",
    [56] = "gold carp:289",
    [57] = "gold lobster:194",
    [58] = "greedie:11",
    [59] = "grimmonite:717",
    [60] = "gugru tuna:100",
    [61] = "gugrusaurus:1795",
    [62] = "gurnard:475",
    [63] = "hamsi:7",
    [64] = "hydrogauge:0",
    [65] = "icefish:156",
    [66] = "istakoz:200",
    [67] = "istavrit:100",
    [68] = "istiridye:279",
    [69] = "jungle catfish:612",
    [70] = "kalamar:170",
    [71] = "kalkanbaligi:780",
    [72] = "kaplumbaga:830",
    [73] = "kayabaligi:310",
    [74] = "kilicbaligi:450",
    [75] = "lakerda:103",
    [76] = "lamp marimo:31",
    [77] = "lik:1795",
    [78] = "lionhead:12",
    [79] = "lungfish:231",
    [80] = "matsya:25688",
    [81] = "megalodon:864",
    [82] = "mercanbaligi:600",
    [83] = "mithra snare:0",
    [84] = "moat carp:10",
    [85] = "moblin mask:0",
    [86] = "mola mola:975",
    [87] = "monke-onke:306",
    [88] = "moorish idol:242",
    [89] = "morinabaligi:548",
    [90] = "muddy siredon:0",
    [91] = "mythril dagger:1431",
    [92] = "mythril sword:4100",
    [93] = "nebimonite:53",
    [94] = "noble lady:400",
    [95] = "norg shell:503",
    [96] = "nosteau herring:80",
    [97] = "ogre eel:32",
    [98] = "pamtam kelp:8",
    [99] = "pearlscale:12",
    [100] = "phanauet newt:4",
    [101] = "pipira:47",
    [102] = "pirarucu:901",
    [103] = "pterygotus:750",
    [104] = "quus:19",
    [105] = "red terrapin:306",
    [106] = "rhinochimera:613",
    [107] = "ripped cap:0",
    [108] = "rusty bucket:51",
    [109] = "rusty cap:97",
    [110] = "rusty greatsword:86",
    [111] = "rusty leggings:12",
    [112] = "rusty pick:115",
    [113] = "rusty subligar:15",
    [114] = "ryugu titan:1500",
    [115] = "sandfish:26",
    [116] = "sazanbaligi:300",
    [117] = "sea zombie:628",
    [118] = "shall shell:300",
    [119] = "shining trout:26",
    [120] = "silver ring:250",
    [121] = "silver shark:500",
    [122] = "takitaro:714",
    [123] = "tarutaru snare:0",
    [124] = "tavnazian goby:400",
    [125] = "three-eyed fish:512",
    [126] = "tiger cod:52",
    [127] = "tiny goldfish:1",
    [128] = "titanic sawfish:1652",
    [129] = "titanictus:714",
    [130] = "tricolored carp:52",
    [131] = "tricorn:616",
    [132] = "trilobite:40",
    [133] = "trumpet shell:512",
    [134] = "turnabaligi:693",
    [135] = "uskumru:300",
    [136] = "veydal wrasse:420",
    [137] = "vongola clam:192",
    [138] = "yayinbaligi:225",
    [139] = "yellow globe:20",
    [140] = "yilanbaligi:200",
    [141] = "zafmlug bass:31",
    [142] = "zebra eel:385",
}
}

local GoneFishin = 
{
    Settings = settings.load(default_settings),
    fishValues = T {},

    -- Movement variables..
    move = T {dragging = false, drag_x = 0, drag_y = 0, shift_down = false},

    -- Editor variables..
    editor = T {open = T {false}},
    gilPerHour = 0,
    pricing = T {},
    fishType = '',
    fishColor = {},
    fishFeel = '',
    feelColor = {},
    hooked = false,

    -- Log variables
    TotalCasts = 0,
    SkillUps =  0.0,
    Hooked = false,
    FirstCast = 0,
    LastCast = 0,
	Fish = {},
    LastBiteType = '',
    LastSessionLength = 0,
    fishInfoActive = false,
    fishLogActive = false,
    sessionPaused = false,
    totalGil = 0,
    GPH = 0;
}

local function split(inputstr, sep)
    if sep == nil then sep = '%s'; end
    local t = {};
    for str in string.gmatch(inputstr, '([^' .. sep .. ']+)') do
        table.insert(t, str);
    end
    return t;
end

local function PopulatePricing()
    local fish;
    local value;    
    for k, v in pairs(GoneFishin.Settings.FishValues) do
        for k2, v2 in pairs(split(v, ':')) do
           if(k2 == 1) then fish = v2; end
           if(k2 == 2) then value = v2; end
        end
        GoneFishin.fishValues[fish] = value;
    end
end

local function CalcGPH()
    local total = 0;
    for k, v in pairs(GoneFishin.Fish) do
        local gil = GoneFishin.fishValues[k]
        if(gil ~= nil) then
            total = total + (gil * v);
        end
      
    end
    GoneFishin.totalGil = total;
    local elapsedTime;
    if(GoneFishin.sessionPaused == false) then
        elapsedTime =os.difftime(os.time(),GoneFishin.FirstCast)+GoneFishin.LastSessionLength;
    else
        elapsedTime = GoneFishin.LastSessionLength; 
    end
    GoneFishin.GPH = (total / elapsedTime)*3600;
end

local MAX_HEIGHT_IN_LINES = 26;

-- Used for debugging purposes
function dumpTable(table, maxDepth, currentDepth)
    if currentDepth == nil then
        currentDepth = 0
    end

    if maxDepth == nil then
        maxDepth = 20
    end

    if (currentDepth > maxDepth) then
        return
    end

    for k,v in pairs(table) do
        if (type(k) == "table") then
            dumpTable(k, maxDepth, currentDepth+1)
        elseif (type(v) == "table") then
            print(string.rep(" ", currentDepth)..k..":")
            dumpTable(v, maxDepth, currentDepth+1)
        else
            if (type(v) == "function") then
                print(string.rep(" ", currentDepth)..k..": <function>")
            elseif (type(v) == "userdata") then
                print(string.rep(" ", currentDepth)..k..": <userdata>")
            else
                print(string.rep(" ", currentDepth)..k..": ",v)
            end
        end
    end
end

-- Depreciated
function AssembleLogString()
    local elapsedTime = os.date('!%H:%M:%S',os.difftime(os.time(),GoneFishin.FirstCast) + GoneFishin.LastSessionLenth)
    local s = string.format('%s%-20s%-8s%s|r\n', '|cFF7f99b2|','Fish','Qty','Bite Rate');
    for k, v in pairs(GoneFishin.Fish) do
        local bite = string.format("%.2f",v/GoneFishin.TotalCasts*100)   
        if(k == 'item' and GoneFishin.Settings.showItem == true) then
            s = s .. string.format('%-20s%-8s%s%%\n',k,v,bite)
        elseif(k == 'monster' and GoneFishin.Settings.showMonster == true) then
            s = s .. string.format('%-20s%-8s%s%%\n',k,v,bite)
        elseif(k == 'giveup' and GoneFishin.Settings.showGiveup == true) then
            s = s .. string.format('%-20s%-8s%s%%\n',k,v,bite)
        elseif(k == 'skill' and GoneFishin.Settings.showSkill == true) then
            s = s .. string.format('%-20s%-8s%s%%\n',k,v,bite)
        elseif(k == 'nothing' and GoneFishin.Settings.showNothing == true) then
        else
            s = s .. string.format('%-20s%-8s%s%%\n',k,v,bite)
        end
    end
    if(GoneFishin.FirstCast ~= 0) then
        s = s .. string.format('\n Session: %s', elapsedTime)
    end
    s = s .. string.format('\n Casts: %d\n Skill-Ups: %.1f', GoneFishin.TotalCasts, GoneFishin.SkillUps);
    return s;
end

local fishes = {
    { text='Something caught the hook!!!', fish='Large'},
    { text='Something caught the hook!', fish='Small'},
    { text='You feel something pulling at your line.', fish='Item'},
    { text='Something clamps onto your line ferociously!', fish='Monster'},    
};

local feels = {
    { text='You have a good feeling about this one!', feel='Good'},
    { text='You have a bad feeling about this one.', feel='Bad'},
    { text='You have a terrible feeling about this one...', feel='Terrible'},
    { text='You don\'t know if you have enough skill to reel this one in.', feel='Unknown'},
    { text='You\'re fairly sure you don\'t have enough skill to reel this one in.', feel='Fairly'},
    { text='You\'re positive you don\'t have enough skill to reel this one in!', feel='Positive'},
    { text='Your keen angler\'s senses tell you that this is the pull of a', feel='Angler'},
    { text='This strength... You get the sense that you are on the verge of an epic catch!', feel='Epic'},
};

local function CalcRGBValues(red, green, blue, alpha)
    return T {red/256, green/256, blue/256, alpha};
end

local function ResetSession()
    GoneFishin.TotalCasts = 0;
    GoneFishin.SkillUps =  0.0;
    GoneFishin.Hooked = false;
    GoneFishin.FirstCast = 0;
    GoneFishin.LastCast = 0;
    GoneFishin.LastSessionLength = 0;
	GoneFishin.Fish = {};
    print(chat.header(addon.name):append(chat.message('Fishing session has been reset.')));
end

local function PauseSession()
    GoneFishin.LastSessionLength = GoneFishin.LastSessionLength + os.difftime(os.time(),GoneFishin.FirstCast);
    GoneFishin.sessionPaused = true;
    print(chat.header(addon.name):append(chat.message('Fishing session paused.')));
end

local function ResumeSession()    
    GoneFishin.sessionPaused = false;
    GoneFishin.FirstCast = os.time();
    GoneFishin.LastCast = os.time();
    print(chat.header(addon.name):append(chat.message('Fishing session resumed.')));
end

local function ParseFishMessages(message)
    for _, i in ipairs(fishes) do
         if (string.match(message, i.text) ~= nil) then
            GoneFishin.fishType = i.fish
            if(string.match(i.fish,'Item') ~= nil) then
                GoneFishin.fishColor = GoneFishin.Settings.itemColor;
            elseif(string.match(i.fish,'Monster') ~= nil) then
                GoneFishin.fishColor = GoneFishin.Settings.badColor;
            else 
                GoneFishin.fishColor = GoneFishin.Settings.goodColor;
            end
            GoneFishin.fishInfoActive = true;            
            break;
         end
    end
    for _, i in ipairs(feels) do
         if (string.match(message, i.text) ~= nil) then
            GoneFishin.fishFeel = i.feel
            if(string.match(i.feel,'Good') ~= nil or string.match(i.feel,'Unknown') ~= nil or string.match(i.feel,'Epic') ~= nil or string.match(i.feel,'Angler') ~= nil) then
                GoneFishin.feelColor = GoneFishin.Settings.goodColor;
            elseif(string.match(i.feel,'Bad') ~= nil or string.match(i.feel,'Fairly') ~= nil) then
                GoneFishin.feelColor = GoneFishin.Settings.itemColor;
            elseif(string.match(i.feel,'Positive') ~= nil or string.match(i.feel,'Terrible') ~= nil) then
                GoneFishin.feelColor = GoneFishin.Settings.badColor;
            end
            break;
         end
    end
end

local function RenderGeneralSettings()    
    imgui.BeginChild('settings_general' , { 400, imgui.GetTextLineHeightWithSpacing() * MAX_HEIGHT_IN_LINES}, true, ImGuiWindowFlags_AlwaysAutoResize);
    imgui.Text('General Settings');
    imgui.SliderFloat('Opacity', GoneFishin.Settings.opacity, 0.125, 1.0, '%.3f');
    imgui.ShowHelp('The backgorund opacity gone fishin windows.');
    imgui.SliderFloat('Font Scale', GoneFishin.Settings.font_scale, 0.1, 2.0,'%.3f');
    imgui.ShowHelp('The scaling of the font size.');    
    imgui.Separator();
    imgui.Text('Fishing Log');
    -- fish Log
    imgui.InputInt('Display Timeout', GoneFishin.Settings.displayTimeout);
    imgui.ShowHelp('How long should the fishing log stay open after the last cast.');
    imgui.InputInt('Session Auto Pause', GoneFishin.Settings.sessionTimeout);
    imgui.ShowHelp('How long should we wait to auto pause the session after the last cast.');
    imgui.Checkbox('Log Visible', GoneFishin.Settings.visible);
    imgui.ShowHelp('Toggles if the fishing log is visible or not.');
    imgui.Checkbox('Show Total Gil', GoneFishin.Settings.showTotalGil);
    imgui.ShowHelp('Toggles if total gil is visible or not.');
    imgui.Checkbox('Show GPH', GoneFishin.Settings.showGPH);
    imgui.ShowHelp('Toggles if GPH (gil per hour) visible or not.');
    imgui.Checkbox('Show Item tag', GoneFishin.Settings.showItem);
    imgui.ShowHelp('Toggles if the \'item\' tag is visible in the fishing log. NOTE This tag is across all items reguardless of if you actually reel them in.');
    imgui.Checkbox('Show Monster tag', GoneFishin.Settings.showMonster);
    imgui.ShowHelp('Toggles if the \'monster\' tag is visible in the fishing log.');
    imgui.Checkbox('Show Give up tag', GoneFishin.Settings.showGiveup);
    imgui.ShowHelp('Toggles if the \'give up\' tag is visible in the fishing log.');
    imgui.Checkbox('Show Lack of skill tag', GoneFishin.Settings.showSkill);
    imgui.ShowHelp('Toggles if the \'lack of skill\' tag is visible in the fishing log.');
    imgui.Checkbox('Show Nothing tag', GoneFishin.Settings.showNothing);
    imgui.ShowHelp('Toggles if the \'nothing\' tag is visible in the fishing log.');
    imgui.Checkbox('Show fish value', GoneFishin.Settings.showFishValue);
    imgui.ShowHelp('Toggles value column in the fishing log.');
    imgui.Checkbox('Show Player Skill', GoneFishin.Settings.showPlayerSkill);
    imgui.ShowHelp('Toggles showing the player\'s total fishing skill in the fishing log.');
    imgui.Separator();
    imgui.Text('Fish Info');
    -- fish info
    imgui.Checkbox('Show Fish Info', GoneFishin.Settings.fishInfoVisible);
    imgui.ShowHelp('Toggles the fish info window.');
    imgui.ColorEdit4( "Good Color", GoneFishin.Settings.goodColor );
    imgui.ShowHelp('Color of the text on the fish Info window indicating a positive outcome.');
    imgui.ColorEdit4( "Item Color", GoneFishin.Settings.itemColor );
    imgui.ShowHelp('Color of the text on the fish Info window indicating a item or unkown outcome.');
    imgui.ColorEdit4( "Bad Color", GoneFishin.Settings.badColor );
    imgui.ShowHelp('Color of the text on the fish Info window indicating a negative outcome.');
    
    if (imgui.Button('Save Settings')) then
        settings.save();
        print(chat.header(addon.name):append(chat.message('Settings saved.')));
    end
    imgui.EndChild();
end

local function RenderFishValueConfig()
    imgui.BeginChild('settings_general' , { 400, imgui.GetTextLineHeightWithSpacing() * MAX_HEIGHT_IN_LINES}, true, ImGuiWindowFlags_AlwaysAutoResize);
    imgui.Text('Fish Value Config');
    imgui.Text('These values indicate NPC worth')
    imgui.Text('Update to AH price if desired')
    imgui.Text('**NOTE** format MUST remain fish:value')
    local temp_strings = T {};
    temp_strings[1] = table.concat(GoneFishin.Settings.FishValues, '\n');
    if (imgui.InputTextMultiline('', temp_strings, 8192, {
        0, imgui.GetTextLineHeightWithSpacing() * (MAX_HEIGHT_IN_LINES - 8)
    })) then
        GoneFishin.Settings.FishValues = split(temp_strings[1], '\n');
    end
    if (imgui.Button('Save')) then
        settings.save();
        PopulatePricing();
        print(chat.header(addon.name):append(chat.message('Settings saved.')));
    end
    imgui.EndChild();
end

local function RenderEditor()
    if(not GoneFishin.editor.open[1]) then return; end

    imgui.SetNextWindowSize({0, 0},  ImGuiCond_Always);
    if(imgui.Begin('GoneFishin##Config', GoneFishin.editor.open, ImGuiWindowFlags_AlwaysAutoResize)) then
       
        if(imgui.BeginTabBar('##GoneFishin_tabbar', ImGuiTabBarFlags_NoCloseWithMiddleMouseButton)) then
            if(imgui.BeginTabItem('General', nil)) then
                RenderGeneralSettings();
                imgui.EndTabItem();
            end
            if(imgui.BeginTabItem('Fish Values', nil)) then
                RenderFishValueConfig();
                imgui.EndTabItem();
            end
            imgui.EndTabBar();
        end
    end
    imgui.End();
end

local function RenderLog()
    if((os.time() - GoneFishin.LastCast) > GoneFishin.Settings.sessionTimeout[1] and GoneFishin.sessionPaused == false and GoneFishin.LastCast > 0) then
        PauseSession();
    end
    if((os.time() - GoneFishin.LastCast) > GoneFishin.Settings.displayTimeout[1] and GoneFishin.fishLogActive == true and GoneFishin.LastCast > 0) then
        GoneFishin.fishLogActive = false;        
        GoneFishin.FirstCast = 0;
        GoneFishin.LastCast = 0;
    end
    imgui.SetNextWindowBgAlpha(GoneFishin.Settings.opacity[1]);
    imgui.SetNextWindowSize({-1, -1}, ImGuiCond_Always);
    if(imgui.Begin('Gone Fishin##Log', GoneFishin.Settings.visible[1], bit.bor(ImGuiWindowFlags_NoDecoration,ImGuiWindowFlags_AlwaysAutoResize,ImGuiWindowFlags_NoFocusOnAppearing,ImGuiWindowFlags_NoNav))) then
        imgui.SetWindowFontScale(GoneFishin.Settings.font_scale[1] + 0.1);
        imgui.Text('Gone Fishin\'');
        imgui.Separator();
        imgui.Separator();
        if(GoneFishin.FirstCast ~= 0) then
            local elapsedTime = os.date('!%H:%M:%S',os.difftime(os.time(),GoneFishin.FirstCast)+GoneFishin.LastSessionLength)
            if(GoneFishin.sessionPaused) then
                elapsedTime = os.date('!%H:%M:%S',GoneFishin.LastSessionLength);
            end
            imgui.Text(string.format('Session: %s', elapsedTime));
            imgui.Text(string.format('Casts: %d', GoneFishin.TotalCasts)); 
            if(GoneFishin.Settings.showTotalGil or GoneFishin.Settings.showGPH) then CalcGPH(); end;
            if(GoneFishin.Settings.showTotalGil) then
                imgui.Text(string.format('Total Gil: %s', GoneFishin.totalGil));
            end
            if(GoneFishin.Settings.showGPH) then
                imgui.Text(string.format('GPH: %.2f', GoneFishin.GPH));
            end
            imgui.Text(string.format('Skill-Ups: %.1f', GoneFishin.SkillUps));
            if (GoneFishin.Settings.showPlayerSkill[1] == true) then
				imgui.SameLine()
				imgui.Text(string.format('\tFishing Skill: %.1f', GoneFishin.Settings.playerSkill))
			end
        end  
        imgui.Separator();
        if (imgui.Button('Pause')) then
            if(GoneFishin.sessionPaused == false) then
                PauseSession();
            else
                print(chat.header(addon.name):append(chat.message('session is already paused.')));
            end            
        end 
        imgui.SameLine();
        if (imgui.Button('Reset')) then
            ResetSession();
        end 
        imgui.SameLine();
        if (imgui.Button('Hide')) then
            GoneFishin.fishLogActive = false;
            print(chat.header(addon.name):append(chat.message('Fishing session window is now hidden.')));
        end 
        imgui.Separator();        
        if(imgui.BeginTable('Log##Tables',4,bit.bor(ImGuiTableFlags_BordersH,                                                 
                                                 ImGuiTableFlags_Reorderable,
                                                 ImGuiTableFlags_Sortable,	
                                                 ImGuiTableFlags_SizingFixedFit,
                                                 ImGuiTableFlags_ScrollX, 
                                                 ImGuiTableFlags_ScrollY))) then
            imgui.TableSetupColumn('Fish                    ');
            imgui.TableSetupColumn('Qty');
            imgui.TableSetupColumn('Bite Rate');
            if(GoneFishin.Settings.showFishValue[1] == true) then
                imgui.TableSetupColumn('Value');
            end
            imgui.TableHeadersRow();  
            for k, v in pairs(GoneFishin.Fish) do        	    
                local bite = string.format("%.2f",v/GoneFishin.TotalCasts*100)..'%';
                if((k == 'item' and GoneFishin.Settings.showItem[1] ~= true )
                    or (k == 'monster' and GoneFishin.Settings.showMonster[1] ~= true) 
                    or (k == 'giveup' and GoneFishin.Settings.showGiveup[1] ~= true) 
                    or (k == 'skill' and GoneFishin.Settings.showSkill[1] ~= true) 
                    or (k == 'nothing' and GoneFishin.Settings.showNothing[1] ~= true)) then 
                else
                    imgui.TableNextRow();
                    imgui.TableSetColumnIndex(0);
                    imgui.Text(k);
                    imgui.TableSetColumnIndex(1);
                    imgui.Text(tostring(v));
                    imgui.TableSetColumnIndex(2);
                    imgui.Text(bite);                    
                    if(GoneFishin.Settings.showFishValue[1] == true and GoneFishin.fishValues[k] ~= nil) then
                        imgui.TableSetColumnIndex(3);
                        imgui.Text(tostring(GoneFishin.fishValues[k] * v))
                    end
                end
            end
            imgui.EndTable();
        end
    end
    imgui.End();
end

local function RenderFishInfo()
    imgui.SetNextWindowBgAlpha(GoneFishin.Settings.opacity[1]);
    imgui.SetNextWindowSize({-1, -1}, ImGuiCond_Always);
        if(imgui.Begin('Gone Fishin##FishInfo', GoneFishin.Settings.visible[1], bit.bor(ImGuiWindowFlags_NoDecoration,ImGuiWindowFlags_AlwaysAutoResize,ImGuiWindowFlags_NoFocusOnAppearing,ImGuiWindowFlags_NoNav))) then        
            imgui.SetWindowFontScale(GoneFishin.Settings.font_scale[1] + 3.0);
            imgui.SetWindowFontScale(GoneFishin.Settings.font_scale[1]);
            imgui.TextColored(GoneFishin.fishColor, GoneFishin.fishType);
            imgui.SameLine();
            imgui.Text('|');
            imgui.SameLine();
            imgui.TextColored(GoneFishin.feelColor, GoneFishin.fishFeel);
    end
    imgui.End();
end

settings.register('settings', 'settings_update', function (s)
    if (s ~= nil) then
        GoneFishin.Settings = s
    end
    settings.save();
end);

--[[
* event: command
* desc : Event called when the addon is processing a command.
--]]
ashita.events.register('command', 'command_cb', function(e)
    -- Parse the command arguments..
    local args = e.command:args();
    if (#args == 0 or not args[1]:any('/gf')) then return; end

    -- Block all related commands..
    e.blocked = true;

    if(#args == 2) then
        if (args[2]:any('config'))then
            GoneFishin.editor.open[1] = true;
            return;
        elseif(args[2]:any('reset'))then
            ResetSession();            
            return;
        elseif(args[2]:any('save'))then
            settings.save();
            print(chat.header(addon.name):append(chat.message('Settings saved.')));
            return;
        elseif(args[2]:any('reload'))then
            settings.reload();
            print(chat.header(addon.name):append(chat.message('Settings reloaded.')));
            return;
        elseif(args[2]:any('show'))then
            GoneFishin.fishLogActive = true;
            print(chat.header(addon.name):append(chat.message('Fishing session window is now shown.')));
            return;
        elseif(args[2]:any('hide'))then
            GoneFishin.fishLogActive = false;
            print(chat.header(addon.name):append(chat.message('Fishing session window is now hidden.')));
            return;
        elseif(args[2]:any('pause'))then
            PauseSession();
            return;
        elseif(args[2]:any('help'))then            
            print_help(true);
            return;
        end
    elseif(#args == 3) then
        if(args[2]:any('show')) then
            if(args[3]:any('item')) then
                GoneFishin.Settings.showItem[1] = true;
                print(chat.header(addon.name):append(chat.message('Fishing session window will now show \'item\' entry.')));
                return;
            elseif(args[3]:any('monster')) then
                GoneFishin.Settings.showMonster[1] = true;
                print(chat.header(addon.name):append(chat.message('Fishing session window will now show \'monster\' entry.')));
                return;
            elseif(args[3]:any('giveup')) then    
                GoneFishin.Settings.showGiveup[1] = true;
                print(chat.header(addon.name):append(chat.message('Fishing session window will now show \'giveup\' entry.')));
                return;
            elseif(args[3]:any('skill')) then
                GoneFishin.Settings.showSkill[1] = true;
                print(chat.header(addon.name):append(chat.message('Fishing session window will now show \'skill\' entry.')));
                return;
            elseif(args[3]:any('nothing')) then
                GoneFishin.Settings.showNothing[1] = true;
                print(chat.header(addon.name):append(chat.message('Fishing session window will now show \'nothing\' entry.')));
                return;
            end
        elseif(args[2]:any('hide')) then
            if(args[3]:any('item')) then
                GoneFishin.Settings.showItem[1] = false;                
                print(chat.header(addon.name):append(chat.message('Fishing session window will now hide \'item\' entry.')));
                return;
            elseif(args[3]:any('monster')) then
                GoneFishin.Settings.showMonster[1] = false;
                print(chat.header(addon.name):append(chat.message('Fishing session window will now hide \'monster\' entry.')));
                return;
            elseif(args[3]:any('giveup')) then    
                GoneFishin.Settings.showGiveup[1] = false;
                print(chat.header(addon.name):append(chat.message('Fishing session window will now hide \'giveup\' entry.')));
                return;
            elseif(args[3]:any('skill')) then
                GoneFishin.Settings.showSkill[1] = false;
                print(chat.header(addon.name):append(chat.message('Fishing session window will now hide \'skill\' entry.')));
                return;
            elseif(args[3]:any('nothing')) then
                GoneFishin.Settings.showNothing[1] = false;
                print(chat.header(addon.name):append(chat.message('Fishing session window will now hide \'nothing\' entry.')));
                return;
            end
        end
    end
        print_help(true);
end);

ashita.events.register('load', 'load_cb', function ()
    PopulatePricing();    
    settings.load();
    
end);

ashita.events.register('unload', 'unload_cb', function ()
    settings.save();
end);

ashita.events.register('packet_in', 'GoneFishin_HandleIncomingPacket', function (e)
    if (e.id == 0x037) then
        if (struct.unpack('B', e.data, 0x30 + 1) == 0) then
            GoneFishin.fishInfoActive = false;
        end
    end
end);


ashita.events.register('packet_out', 'GoneFishin_HandleOutgoingPacket', function (e)
    -- Packet info from: https://github.com/Windower/Lua/blob/dev/addons/libs/packets/: data.lua and fields.lua
    if (e.id == 0x01A) then -- Action Packet
        if (struct.unpack('H', e.data, 0x0A + 1) == 14) then -- If Action 0x0A + 1 = 0x0E Cast Fishing Rod
            GoneFishin.TotalCasts = GoneFishin.TotalCasts + 1;
            GoneFishin.LastCast =  os.time()
            if(GoneFishin.FirstCast == 0) then
                GoneFishin.FirstCast = os.time();
                GoneFishin.fishLogActive = true;
            end
            if(GoneFishin.sessionPaused) then ResumeSession(); end

            if (GoneFishin.Settings.playerSkill == nil) then
                local fishingSkill = AshitaCore:GetMemoryManager():GetPlayer():GetCraftSkill(0)
                GoneFishin.Settings.playerSkill = fishingSkill:GetSkill()
            end
        end
    end
end);

ashita.events.register('text_in', 'GoneFishin_HandleText', function (e)
    GoneFishin.hooked = false;
    ParseFishMessages(e.message);
    -- Fish log work
    local message = e.message;
    message = string.strip_colors(message);
    player = GetPlayerEntity();
    if(player == nil) then return; end
	local nothing = string.match(message, "You didn't catch anything.");
    local count = string.match(message, player.Name + " caught (%d*)? (.*)");
    local fish = string.match(message, player.Name + " caught a[n]? (.*)!");
    if(fish ~= nil) then fish = string.lower(fish); end
    local giveUp = string.match(message, "You give up.");
    local giveUpFalse = string.match(message, "You give up and reel in your line.");
    local item = string.match(message, "You feel something pulling at your line.");
    local skillup = string.match(message, "fishing skill rises (.*) points");
    local skill = string.match(message, "You lost your catch due to your lack of skill.");
    local monster = string.match(message, "Something clamps onto your line ferociously!");
    local cantfish = string.match(message, "You can't fish"); -- Endings: "without bait on the hook." , "at the moment."
    local skillLevelUp = string.match(message, "fishing skill reaches level (%d*)");

    if(count == 0 or count == nil) then
        count = 1;
    end
    if(fish and nothing == nil) then        
        if(GoneFishin.Fish[fish] ~= nil) then
            GoneFishin.Fish[fish] = GoneFishin.Fish[fish] + count;
        else
            GoneFishin.Fish[fish] = 1;
        end
        GoneFishin.hooked = true;
    elseif(nothing) then
        nothing = "nothing";
        if(GoneFishin.Fish[nothing] ~= nil) then
            GoneFishin.Fish[nothing] = GoneFishin.Fish[nothing] + count;
        else
            GoneFishin.Fish[nothing] = 1;
        end        
    elseif(item) then
        item = "item";
        LastBiteMsg = "item"
        if(GoneFishin.Fish[item] ~= nil) then
            GoneFishin.Fish[item] = GoneFishin.Fish[item] + 1;
        else
            GoneFishin.Fish[item] = 1;
        end     
    elseif(giveUp and giveUpFalse == nil) then 
        giveUp = "give up";
        if(GoneFishin.Fish[giveUp] ~= nil) then
            GoneFishin.Fish[giveUp] = GoneFishin.Fish[giveUp] + 1;
        else
            GoneFishin.Fish[giveUp] = 1;
        end 
    elseif(skill) then
        skill = "lack of skill";
        if(GoneFishin.Fish[skill] ~= nil) then
            GoneFishin.Fish[skill] = GoneFishin.Fish[skill] + 1;
        else
            GoneFishin.Fish[skill] = 1;
        end 
    elseif(monster) then
        monster = "monster";
        LastBiteMsg = "monster"
        if(GoneFishin.Fish[monster] ~= nil) then
            GoneFishin.Fish[monster] = GoneFishin.Fish[monster] + 1;
        else
            GoneFishin.Fish[monster] = 1;
        end
    elseif (cantfish) then
        GoneFishin.TotalCasts = GoneFishin.TotalCasts - 1;
    end
    if(skillup) then
        GoneFishin.SkillUps = GoneFishin.SkillUps + skillup;
        GoneFishin.Settings.playerSkill = GoneFishin.Settings.playerSkill + skillup;
    end
    if (skillLevelUp) then
        if ((skillLevelUp + 0.0) > GoneFishin.Settings.playerSkill) then
            GoneFishin.Settings.playerSkill = tonumber(skillLevelUp) + 0.0
        end
    end

end);

ashita.events.register('d3d_present', 'BotAPI_HandleRender', function ()
    if(GoneFishin.Settings.visible[1] and GoneFishin.fishLogActive) then
        RenderLog();
    end
    if(GoneFishin.Settings.fishInfoVisible[1] and GoneFishin.fishInfoActive) then
        RenderFishInfo();
    end
    RenderEditor();
end);