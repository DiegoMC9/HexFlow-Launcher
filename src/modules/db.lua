GamesDB = {}
local dbFile = "ux0:/data/HexFlow/games.db"
local app_dir = "ux0:/app"

local covers_psv = "ux0:/data/HexFlow/COVERS/PSVITA/"
local covers_psp = "ux0:/data/HexFlow/COVERS/PSP/"
local covers_psx = "ux0:/data/HexFlow/COVERS/PSX/"

local db = Database.open(dbFile)

-- GamesDB.scanComplete
function GamesDB.init()
local res = Database.execQuery(db, [[CREATE TABLE IF NOT EXISTS GAMES(
APPID  CHAR(10)   PRIMARY KEY NOT NULL,
CAT    CHAR(4)    NOT NULL,
TITLE  TEXT       NOT NULL,
ICON   TEXT       NOT NULL,
COVER  TEXT       NOT NULL,
PIC    TEXT			  NOT NULL,
OVERR  INTEGER		DEFAULT 0
);]])
end
function GamesDB.close()
  Database.close(db)
end
-- scan app directory for games
function GamesDB.scan()
  System.setMessage ("scanning library", false, BUTTON_NONE)
  local dir = System.listDirectory(app_dir)
  for _,dirEntry in pairs(dir) do
    local app ={}
		local cover, coveralt= nil, nil
    if dirEntry.directory then
      -- get app name to match with custom cover dirEntry name
      if System.doesFileExist(app_dir .. "/" .. dirEntry.name .. "/sce_sys/param.sfo") then
        local info = System.extractSfo(app_dir .. "/" .. dirEntry.name .. "/sce_sys/param.sfo")
        app.title = info.title
				app.titleid = info.titleid
      end
			if string.match(dirEntry.name, "PCS") and not string.match(dirEntry.name, "PCSI") then
        -- Scan PSVita Games
        cover = covers_psv .. app.title .. ".png"
        coveralt = covers_psv .. dirEntry.name .. ".png"
				app.cat="VITA"
      elseif string.match(dirEntry.name, "NP") or string.match(dirEntry.name, "UL") or string.match(dirEntry.name, "UC") then
        -- Scan PSP Games
        cover = covers_psp .. app.title .. ".png"
        coveralt = covers_psp .. dirEntry.name .. ".png"
				app.cat="PSP"	
      elseif string.match(dirEntry.name, "SC") or string.match(dirEntry.name, "SL") then
        -- Scan PSX Games
        cover = covers_psx .. app.title .. ".png"
        coveralt = covers_psx .. dirEntry.name .. ".png"
				app.cat="PSX"
      else
        -- Scan Homebrews
        cover = covers_psv .. app.title .. ".png"
        coveralt = covers_psv .. dirEntry.name .. ".png"
				app.cat="HB"
      end
    end
		if cover and System.doesFileExist(cover) then
			app.cover = cover --custom cover by app name
		elseif coveralt and System.doesFileExist(coveralt) then
			app.cover = coveralt --custom cover by app id
		else
			if System.doesFileExist("ur0:/appmeta/" .. dirEntry.name .. "/icon0.png") then
				app.cover = "ur0:/appmeta/" .. dirEntry.name .. "/icon0.png"  --app icon
			else
				app.cover = "app0:/DATA/noimg.png" --blank grey
			end
		end
    app.icon = "ur0:/appmeta/" .. app.titleid .. "/icon0.png"
    app.pic = "ur0:/appmeta/" .. app.titleid .. "/pic0.png"
    local query = string.format("INSERT INTO GAMES(APPID,CAT,TITLE,ICON,COVER,PIC) VALUES(%s,%s,%s,%s,%s,%s);",app.titleid,app.cat,app.title,app.icon,app.cover,app.pic)
    Database.execQuery(db,query)
	end
  System.closeMessage()
  System.setMessage ("scan complete", false,BUTTON_OK)
end
-- returns list of tables representing games
function GamesDB.GetGames(category)
  return Database.execQuery(db, "SELECT * FROM GAMES WHERE CAT IS PSV ORDER BY NAME DESC;") 
end
-- -- old code
-- dirEntrys_table = {}
-- function listDirectory(dir)
    
--     folders_table = {}
--     games_table = {}
--     psp_table = {}
--     psx_table = {}
--     homebrews_table = {}
-- 	-- app_type = 0 -- 0 homebrew, 1 psvita, 2 psp, 3 psx
-- 	local customCategory = 0
	
-- 	local dirEntry_over = System.opendirEntry(data_dir .. "/overrides.dat", FREAD)
-- 	local dirEntrysize = System.sizedirEntry(dirEntry_over)
-- 	local str = System.readdirEntry(dirEntry_over, dirEntrysize)
-- 	System.closedirEntry(dirEntry_over)

--     for _, dirEntry in pairs(dir) do
-- 	local custom_path, custom_path_id, app_type = nil, nil, nil
--         if dirEntry.directory then
--             -- get app name to match with custom cover dirEntry name
--             if System.doesdirEntryExist(app_dir .. "/" .. dirEntry.name .. "/sce_sys/param.sfo") then
--                 info = System.extractSfo(app_dir .. "/" .. dirEntry.name .. "/sce_sys/param.sfo")
--                 app.title = info.title
--             end

--             if string.match(dirEntry.name, "PCS") and not string.match(dirEntry.name, "PCSI") then
--                 -- Scan PSVita Games
--                 table.insert(folders_table, dirEntry)
--                 --table.insert(games_table, dirEntry)
--                 custom_path = covers_psv .. app.title .. ".png"
--                 custom_path_id = covers_psv .. dirEntry.name .. ".png"
-- 				dirEntry.app_type=1
				
-- 				--END OVERRIDDEN CATEGORY of Vita game
-- 				-- Scan PSP Games
--             elseif System.doesdirEntryExist(app_dir .. "/" .. dirEntry.name .. "/data/boot.bin") and not System.doesdirEntryExist("ux0:pspemu/PSP/GAME/" .. dirEntry.name .. "/EBOOT.PBP") then
--                 table.insert(folders_table, dirEntry)
--                 --table.insert(psp_table, dirEntry)
--                 custom_path = covers_psp .. app.title .. ".png"
--                 custom_path_id = covers_psp .. dirEntry.name .. ".png"
-- 				dirEntry.app_type=2
				
--             elseif System.doesdirEntryExist(app_dir .. "/" .. dirEntry.name .. "/data/boot.bin") and System.doesdirEntryExist("ux0:pspemu/PSP/GAME/" .. dirEntry.name .. "/EBOOT.PBP") then
--                 -- Scan PSX Games
--                 table.insert(folders_table, dirEntry)
--                 --table.insert(psx_table, dirEntry)
--                 custom_path = covers_psx .. app.title .. ".png"
--                 custom_path_id = covers_psx .. dirEntry.name .. ".png"
-- 				dirEntry.app_type=3
				
-- 				--END OVERRIDDEN CATEGORY of PSX game
--             else
--                 -- Scan Homebrews
--                 table.insert(folders_table, dirEntry)
--                 --table.insert(homebrews_table, dirEntry)
--                 custom_path = covers_psv .. app.title .. ".png"
--                 custom_path_id = covers_psv .. dirEntry.name .. ".png"
-- 					dirEntry.app_type=0
--             end

--         end
        
-- 		if custom_path and System.doesdirEntryExist(custom_path) then
-- 			img_path = custom_path --custom cover by app name
-- 		elseif custom_path_id and System.doesdirEntryExist(custom_path_id) then
-- 			img_path = custom_path_id --custom cover by app id
-- 		else
-- 			if System.doesdirEntryExist("ur0:/appmeta/" .. dirEntry.name .. "/icon0.png") then
-- 				img_path = "ur0:/appmeta/" .. dirEntry.name .. "/icon0.png"  --app icon
-- 			else
-- 				img_path = "app0:/DATA/noimg.png" --blank Colors.grey
-- 			end
-- 		end
        
--         table.insert(dirEntrys_table, 4, dirEntry.app_type)
		
		
--         --add blank icon to all
--         dirEntry.icon = imgCoverTmp
--         dirEntry.icon_path = img_path
		
--         table.insert(dirEntrys_table, 4, dirEntry.icon)
        
--         dirEntry.apptitle = app.title
--         table.insert(dirEntrys_table, 4, dirEntry.apptitle)
        
--     end
--     table.sort(dirEntrys_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
--     table.sort(folders_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    
--     table.sort(games_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
--     table.sort(homebrews_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
--     table.sort(psp_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
--     table.sort(psx_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    
--     return_table = TableConcat(folders_table, dirEntrys_table)
    
--     total_all = #dirEntrys_table
--     total_games = #games_table
--     total_homebrews = #homebrews_table
    
--     return return_table
-- end