-- Settings
local startCategory = 1
local setReflections = 1
local setSounds = 1
local themeColor = 0 -- 0 Colors.blue, 1 Colors.red, 2 Colors.yellow, 3 Colors.green, 4 Colors.grey, 5 Colors.black, 6 Colors.purple, 7 Colors.orange
local menuItems = 3
local setBackground = 1
local setLanguage = 0
local showHomebrews = 0

if System.doesFileExist(data_dir .. "/config.dat") then
    local file_config = System.openFile(data_dir .. "/config.dat", FREAD)
    local filesize = System.sizeFile(file_config)
    local str = System.readFile(file_config, filesize)
    System.closeFile(file_config)
    
    local getCategory = tonumber(string.sub(str, 1, 1)); if getCategory ~= nil then startCategory = getCategory end
    local getReflections = tonumber(string.sub(str, 2, 2)); if getReflections ~= nil then setReflections = getReflections end
    local getSounds = tonumber(string.sub(str, 3, 3)); if getSounds ~= nil then setSounds = getSounds end
    local getthemeColor = tonumber(string.sub(str, 4, 4)); if getthemeColor ~= nil then themeColor = getthemeColor end
    local getBackground = tonumber(string.sub(str, 5, 5)); if getBackground ~= nil then setBackground = getBackground end
    local getLanguage = tonumber(string.sub(str, 6, 6)); if getLanguage ~= nil then setLanguage = getLanguage end
    local getView = tonumber(string.sub(str, 7, 7)); if getView ~= nil then showView = getView end
    local getHomebrews = tonumber(string.sub(str, 8, 8)); if getHomebrews ~= nil then showHomebrews = getHomebrews end
else
    local file_config = System.openFile(data_dir .. "/config.dat", FCREATE)
    System.writeFile(file_config, startCategory .. setReflections .. setSounds .. themeColor .. setBackground .. setLanguage .. showView .. showHomebrews, 8)
    System.closeFile(file_config)
end