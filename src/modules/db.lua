GamesDB = {}
local dbFile = "ux0:/data/HexFlow/games.db"
local db = Database.open(dbFile)
local app_dir = "ux0:/app"

local covers_psv = "ux0:/data/HexFlow/COVERS/PSVITA/"
local covers_psp = "ux0:/data/HexFlow/COVERS/PSP/"
local covers_psx = "ux0:/data/HexFlow/COVERS/PSX/"

local status,errorString = 0, ""
-- GamesDB.scanComplete
function GamesDB.init()
	local query = [[CREATE TABLE IF NOT EXISTS VITA(
                                APPID   CHAR(10)  PRIMARY KEY NOT NULL
                                TITLE   TEXT      NOT NULL
																ICON		TEXT			NOT NULL
                                COVER   TEXT      NOT NULL
																PIC			TEXT			NOT NULL
																OVERR		INTEGER		DEFAULT 0 
															);]]
status,errorString = Database.query(db, query)
status,errorString = Database.query(db, [[CREATE TABLE IF  NOT EXISTS PSP(
                                APPID   CHAR(10)  PRIMARY KEY NOT NULL
                                TITLE   TEXT      NOT NULL
																ICON		TEXT			NOT NULL
                                COVER   TEXT      NOT NULL
																PIC			TEXT			NOT NULL
																OVERR		INTEGER		DEFAULT 0 
															);]])
status,errorString = Database.query(db, [[CREATE TABLE IF  NOT EXISTS PSX(
                                APPID   CHAR(10)  PRIMARY KEY NOT NULL
                                TITLE   TEXT      NOT NULL
																ICON		TEXT			NOT NULL
                                COVER   TEXT      NOT NULL
																PIC			TEXT			NOT NULL
																OVERR		INTEGER		DEFAULT 0 
															);]])
status,errorString= Database.query(db, [[CREATE TABLE IF  NOT EXISTS HB(
                                APPID   CHAR(10)  PRIMARY KEY NOT NULL
                                TITLE   TEXT      NOT NULL
																ICON		TEXT			NOT NULL
                                COVER   TEXT      NOT NULL
																PIC			TEXT			NOT NULL
																OVERR		INTEGER		DEFAULT 0 
															);]])
end
-- scan app directory for games
function GamesDB.scan()
  local dir = System.listDirectory(app_dir)
	local app ={}
  for file in dir do
		local custom_path, custom_path_id= nil, nil
    if file.directory then
      -- get app name to match with custom cover file name
      if System.doesFileExist(app_dir .. "/" .. file.name .. "/sce_sys/param.sfo") then
        app.info = System.extractSfo(app_dir .. "/" .. file.name .. "/sce_sys/param.sfo")
        app.title = info.title
				app.titleid = info.titleid
      end
			if string.match(file.name, "PCS") and not string.match(file.name, "PCSI") then
        -- Scan PSVita Games
        app.cover = covers_psv .. app.title .. ".png"
        custom_path_id = covers_psv .. file.name .. ".png"
				app.cat="VITA"
      elseif string.match(file.name, "NP") or string.match(file.name, "UL") or string.match(file.name, "UC") then
        -- Scan PSP Games
        custom_path = covers_psp .. app.title .. ".png"
        custom_path_id = covers_psp .. file.name .. ".png"
				app.cat="PSP"	
      elseif string.match(file.name, "SC") or string.match(file.name, "SL") then
        -- Scan PSX Games
        custom_path = covers_psx .. app.title .. ".png"
        custom_path_id = covers_psx .. file.name .. ".png"
				app.cat="PSX"
      else
        -- Scan Homebrews
        custom_path = covers_psv .. app.title .. ".png"
        custom_path_id = covers_psv .. file.name .. ".png"
				app.cat="HB"
      end
    end
		if custom_path and System.doesFileExist(custom_path) then
			app.cover = custom_path --custom cover by app name
		elseif custom_path_id and System.doesFileExist(custom_path_id) then
			app.cover = custom_path_id --custom cover by app id
		else
			if System.doesFileExist("ur0:/appmeta/" .. file.name .. "/icon0.png") then
				app.cover = "ur0:/appmeta/" .. file.name .. "/icon0.png"  --app icon
			else
				app.cover = "app0:/DATA/noimg.png" --blank grey
			end
		end
	
	
	
	
	--add blank icon to all
	app.icon = "ur0:/appmeta/" .. games_table[p].name .. "/icon0.png"
  app.pic = "ur0:/appmeta/" .. games_table[p].name .. "/pic0.png"
	
	Database.query(db,"INSERT INTO games."..app.cat.."(APPID,TITLE,ICON,COVER,PIC) VALUES("
												.. app.titleid ..","..app.title..","..app.icon..","..app.cover..","..app.pic..");")													
	end
end
-- returns list of tables representing games
function GamesDB.GetGames(category)
  return Database.query(db, "SELECT * FROM games."..category.." ORDER BY NAME DESC;") 
end
-- old code
files_table = {}
function listDirectory(dir)
    
    folders_table = {}
    games_table = {}
    psp_table = {}
    psx_table = {}
    homebrews_table = {}
	-- app_type = 0 -- 0 homebrew, 1 psvita, 2 psp, 3 psx
	local customCategory = 0
	
	local file_over = System.openFile(data_dir .. "/overrides.dat", FREAD)
	local filesize = System.sizeFile(file_over)
	local str = System.readFile(file_over, filesize)
	System.closeFile(file_over)

    for _, file in pairs(dir) do
	local custom_path, custom_path_id, app_type = nil, nil, nil
        if file.directory then
            -- get app name to match with custom cover file name
            if System.doesFileExist(app_dir .. "/" .. file.name .. "/sce_sys/param.sfo") then
                info = System.extractSfo(app_dir .. "/" .. file.name .. "/sce_sys/param.sfo")
                app.title = info.title
            end

            if string.match(file.name, "PCS") and not string.match(file.name, "PCSI") then
                -- Scan PSVita Games
                table.insert(folders_table, file)
                --table.insert(games_table, file)
                custom_path = covers_psv .. app.title .. ".png"
                custom_path_id = covers_psv .. file.name .. ".png"
				file.app_type=1
				
				--END OVERRIDDEN CATEGORY of Vita game
				-- Scan PSP Games
            elseif System.doesFileExist(app_dir .. "/" .. file.name .. "/data/boot.bin") and not System.doesFileExist("ux0:pspemu/PSP/GAME/" .. file.name .. "/EBOOT.PBP") then
                table.insert(folders_table, file)
                --table.insert(psp_table, file)
                custom_path = covers_psp .. app.title .. ".png"
                custom_path_id = covers_psp .. file.name .. ".png"
				file.app_type=2
				
            elseif System.doesFileExist(app_dir .. "/" .. file.name .. "/data/boot.bin") and System.doesFileExist("ux0:pspemu/PSP/GAME/" .. file.name .. "/EBOOT.PBP") then
                -- Scan PSX Games
                table.insert(folders_table, file)
                --table.insert(psx_table, file)
                custom_path = covers_psx .. app.title .. ".png"
                custom_path_id = covers_psx .. file.name .. ".png"
				file.app_type=3
				
				--END OVERRIDDEN CATEGORY of PSX game
            else
                -- Scan Homebrews
                table.insert(folders_table, file)
                --table.insert(homebrews_table, file)
                custom_path = covers_psv .. app.title .. ".png"
                custom_path_id = covers_psv .. file.name .. ".png"
					file.app_type=0
            end

        end
        
		if custom_path and System.doesFileExist(custom_path) then
			img_path = custom_path --custom cover by app name
		elseif custom_path_id and System.doesFileExist(custom_path_id) then
			img_path = custom_path_id --custom cover by app id
		else
			if System.doesFileExist("ur0:/appmeta/" .. file.name .. "/icon0.png") then
				img_path = "ur0:/appmeta/" .. file.name .. "/icon0.png"  --app icon
			else
				img_path = "app0:/DATA/noimg.png" --blank Colors.grey
			end
		end
        
        table.insert(files_table, 4, file.app_type)
		
		
        --add blank icon to all
        file.icon = imgCoverTmp
        file.icon_path = img_path
		
        table.insert(files_table, 4, file.icon)
        
        file.apptitle = app.title
        table.insert(files_table, 4, file.apptitle)
        
    end
    table.sort(files_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(folders_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    
    table.sort(games_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(homebrews_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(psp_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(psx_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    
    return_table = TableConcat(folders_table, files_table)
    
    total_all = #files_table
    total_games = #games_table
    total_homebrews = #homebrews_table
    
    return return_table
end