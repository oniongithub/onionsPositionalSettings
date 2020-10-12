local localPlayer = entity.get_local_player();  
local playerX, playerY, playerZ = entity.get_origin(localPlayer)
local x, y = renderer.world_to_screen(playerX, playerY, playerZ)
local ceiling = playerZ + (100000 * client.trace_line(localPlayer, playerX, playerY, playerZ, playerX, playerY, playerZ + 100000));
local maxDistance = 250;
local locationCreation = { false, 0, 0, 0 };
local locations = {};
local doubleTap = ui.reference("RAGE", "Other", "Double Tap")
local dtEnabled = false;
local map = globals.mapname();
if (ui.get(doubleTap)) then
    dtEnabled = true;
end
local hasShot = false;

ui.new_label("LUA", "B", "   penis head onion lua!!   ")
local onion_enabled = ui.new_checkbox("LUA", "B", "Enabled")
local onion_antirecharge_enabled = ui.new_checkbox("LUA", "B", "Disable Recharge in Region")
local onion_debug_lines = ui.new_checkbox("LUA", "B", "Debug Lines")
local onion_draw_distance = ui.new_slider("LUA", "B", "Draw Distance", 5, 5000, 250)
local onion_draw_color_custom = ui.new_checkbox("LUA", "B", "Custom Colors")
local onion_colors = { ui.new_checkbox("LUA", "B", "Draw Color"), ui.new_color_picker("LUA", "B", "Draw Color", 3, 136, 252, 100), ui.new_checkbox("LUA", "B", "Hover Color"), ui.new_color_picker("LUA", "B", "Hover Color", 252, 198, 3, 100) }
local onion_text_posname = ui.new_textbox("LUA", "B", "Position Name");

local function pointInside(x1, x2, y1, y2, x3, y3)
    local sizeTable = { tonumber(x1), tonumber(x2), tonumber(x3), tonumber(y1), tonumber(y2), tonumber(y3) };

    for i = 1, #sizeTable do
        if (sizeTable[i] > 0) then
            sizeTable[i] = sizeTable[i] + 100000
        end

        sizeTable[i] = math.abs(sizeTable[i]);
    end

    if (sizeTable[1] > sizeTable[2]) then
        if (sizeTable[3] > sizeTable[1] or sizeTable[3] < sizeTable[2]) then
            return false;
        end
    else
        if (sizeTable[3] < sizeTable[1] or sizeTable[3] > sizeTable[2]) then
            return false;
        end
    end

    if (sizeTable[4] > sizeTable[5]) then
        if (sizeTable[6] > sizeTable[4] or sizeTable[6] < sizeTable[5]) then
            return false;
        end
    else
        if (sizeTable[6] < sizeTable[4] or sizeTable[6] > sizeTable[5]) then
            return false;
        end
    end

    return true;
end

local function splitStr(inputstr, sep)
    if sep == nil then
            sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(t, str)
    end
    return t
end

local function loadLocations()
    if (localPlayer ~= nil) then
        locations = {};
        local loc = readfile("onionPositions_" .. map .. ".db")

        if (loc ~= nil and loc ~= "") then
            local lines = splitStr(loc, "\n")

            for i = 1, #lines do
                local splitLine = splitStr(lines[i], "|");

                if (#splitLine == 6) then
                    table.insert(locations, {splitLine[1], splitLine[2], {splitLine[3], splitLine[4]}, {splitLine[5], splitLine[6]}});
                else
                    table.insert(locations, {'Name', splitLine[1], {splitLine[2], splitLine[3]}, {splitLine[4], splitLine[5]}});
                end
            end
        end
    end
end

local function createLocation()
    if (ui.get(onion_enabled) and localPlayer ~= nil) then
        if (locationCreation[1]) then
            locationCreation[1] = false;
            
            local name = "Name"

            if (ui.get(onion_text_posname) ~= nil) then
                name = ui.get(onion_text_posname);
            end

            local text = readfile("onionPositions_" .. map .. ".db");
            if (text ~= "" and text ~= nil) then
                writefile("onionPositions_" .. map .. ".db", text .. "\n" .. name .. "|" .. locationCreation[4] .. "|" .. locationCreation[2] .. "|" .. locationCreation[3] .. "|" .. playerX .. "|" .. playerY);
            else
                writefile("onionPositions_" .. map .. ".db", name .. "|" .. locationCreation[4] .. "|" .. locationCreation[2] .. "|" .. locationCreation[3] .. "|" .. playerX .. "|" .. playerY)
            end

            loadLocations()
            locationCreation[2], locationCreation[3], locationCreation[4] = 0, 0, 0;
        else
            locationCreation[1] = true;
            locationCreation[2], locationCreation[3], locationCreation[4] = playerX, playerY, playerZ;
        end
    end
end

local function logLocation()
    if (ui.get(onion_enabled) and localPlayer ~= nil) then
        client.color_log(66, 164, 245, "playerX: " .. playerX .. " playerY: " .. playerY .. " playerZ: " .. playerZ .. " Player Ceiling: " .. ceiling .. "\n");

        for i = 0, 1 do
            local yAxis = client.trace_line(localPlayer, playerX, playerY, playerZ, playerX, playerY - 100 + (200 * i), playerZ)
            local xAxis = client.trace_line(localPlayer, playerX, playerY, playerZ, playerX - 100 + (200 * i), playerY, playerZ)
            local xX, xY = renderer.world_to_screen(playerX + ((-100 + (200 * i)) * xAxis), playerY, playerZ)
            local yX, yY = renderer.world_to_screen(playerX, playerY + ((-100 + (200 * i)) * yAxis), playerZ)

            if (yAxis ~= 1) then
                client.color_log(0, 255, 0, "Hit on the Y Axis, yAxis: " .. yAxis .. ", Original playerY: " .. playerY - 100 + (200 * i) .. ", playerY Hit: " .. playerY + ((-100 + (200 * i)) * yAxis) .. ", i: " .. i .. "\n");
            else
                client.color_log(255, 0, 0, "No hit on the Y Axis, i: " .. i .. "\n");
            end

            if (xAxis ~= 1) then
                client.color_log(0, 255, 0, "Hit on the X Axis, xAxis: " .. xAxis .. ", Original playerX: " .. playerX - 100 + (200 * i) .. ", playerX Hit: " .. playerX + ((-100 + (200 * i)) * xAxis) .. ", i: " .. i .. "\n");
            else
                client.color_log(255, 0, 0, "No hit on the X Axis, i: " .. i .. "\n");
            end
        end
    end
end

loadLocations();
local onion_button_log = ui.new_button("LUA", "B", "Log Location", logLocation)
local onion_button_createpos = ui.new_button("LUA", "B", "Create Position", createLocation)
local onion_button_updatepos = ui.new_button("LUA", "B", "Update Positions", loadLocations)
local isInside = false;
local insideIndex;

client.set_event_callback("paint", function()
    localPlayer = entity.get_local_player();
    map = globals.mapname();

    for i = 1, #onion_colors do
        ui.set_visible(onion_colors[i], ui.get(onion_draw_color_custom))
    end

    if (ui.get(onion_enabled) and localPlayer ~= nil) then
        playerX, playerY, playerZ = entity.get_origin(localPlayer)
        x, y = renderer.world_to_screen(playerX, playerY, playerZ)
        ceiling = playerZ + (100000 * client.trace_line(localPlayer, playerX, playerY, playerZ, playerX, playerY, playerZ + 100000));

        if (locationCreation[1]) then
            p, pp = renderer.world_to_screen(locationCreation[2], locationCreation[3], locationCreation[4])
            c, cc = renderer.world_to_screen(playerX, locationCreation[3], locationCreation[4])
            d, dd = renderer.world_to_screen(locationCreation[2], playerY, locationCreation[4])
            k, kk = renderer.world_to_screen(playerX, playerY, locationCreation[4])
            renderer.line(p, pp, c, cc, 255, 255, 255, 255);
            renderer.line(p, pp, d, dd, 255, 255, 255, 255);
            renderer.line(k, kk, c, cc, 255, 255, 255, 255);
            renderer.line(k, kk, d, dd, 255, 255, 255, 255);
        end
        
        if (ui.get(onion_debug_lines)) then
            for i = 0, 1 do
                local yAxis = client.trace_line(localPlayer, playerX, playerY, playerZ, playerX, playerY - 100 + (200 * i), playerZ)
                local xAxis = client.trace_line(localPlayer, playerX, playerY, playerZ, playerX - 100 + (200 * i), playerY, playerZ)
                local xX, xY = renderer.world_to_screen(playerX + ((-100 + (200 * i)) * xAxis), playerY, playerZ)
                local yX, yY = renderer.world_to_screen(playerX, playerY + ((-100 + (200 * i)) * yAxis), playerZ)
                renderer.line(x, y, yX, yY, 255, 255, 255, 255)
                renderer.line(x, y, xX, xY, 255, 255, 255, 255)
            end

            local testX, testY = renderer.world_to_screen(playerX, playerY, ceiling)
            renderer.line(x, y, testX, testY, 255, 255, 255, 255)
        end

        for i = 1, #locations do
            if (pointInside(locations[i][3][1], locations[i][4][1], locations[i][3][2], locations[i][4][2], playerX, playerY)) then                 
                if (not isInside) then
                    isInside = true;
                    insideIndex = i;
                end

                if (dtEnabled) then
                    if (ui.get(onion_antirecharge_enabled)) then
                        if (hasShot) then
                            ui.set(doubleTap, false);
                        else
                            ui.set(doubleTap, true);
                        end
                    end
                end
                    
                trX, trY = renderer.world_to_screen(locations[i][3][1], locations[i][3][2], locations[i][2])
                tlX, tlY = renderer.world_to_screen(locations[i][3][1], locations[i][4][2], locations[i][2])
                blX, blY = renderer.world_to_screen(locations[i][4][1], locations[i][3][2], locations[i][2])
                brX, brY = renderer.world_to_screen(locations[i][4][1], locations[i][4][2], locations[i][2])

                if (ui.get(onion_colors[3]) and ui.get(onion_draw_color_custom)) then
                    renderer.triangle(tlX, tlY, brX, brY, blX, blY, ui.get(onion_colors[4]))
                    renderer.triangle(tlX, tlY, trX, trY, blX, blY, ui.get(onion_colors[4]))
                else
                    renderer.triangle(tlX, tlY, brX, brY, blX, blY, 255, 255, 255, 150)
                    renderer.triangle(tlX, tlY, trX, trY, blX, blY, 255, 255, 255, 150)
                end
            else
                if (not isInside or i == insideIndex) then
                    if (dtEnabled) then
                        if (ui.get(onion_antirecharge_enabled)) then
                            ui.set(doubleTap, true);
                            hasShot = false;
                            isInside = false;
                            insideIndex = nil;
                        end
                    end
                end

                if (math.sqrt((playerX - locations[i][4][1])^2 + (playerY - locations[i][4][2])^2) <= ui.get(onion_draw_distance) or math.sqrt((playerX - locations[i][3][1])^2 + (playerY - locations[i][3][2])^2) <= ui.get(onion_draw_distance)) then
                    trX, trY = renderer.world_to_screen(locations[i][3][1], locations[i][3][2], locations[i][2])
                    tlX, tlY = renderer.world_to_screen(locations[i][3][1], locations[i][4][2], locations[i][2])
                    blX, blY = renderer.world_to_screen(locations[i][4][1], locations[i][3][2], locations[i][2])
                    brX, brY = renderer.world_to_screen(locations[i][4][1], locations[i][4][2], locations[i][2])

                    if (ui.get(onion_colors[1]) and ui.get(onion_draw_color_custom)) then
                        renderer.triangle(tlX, tlY, brX, brY, blX, blY, ui.get(onion_colors[2]))
                        renderer.triangle(tlX, tlY, trX, trY, blX, blY, ui.get(onion_colors[2]))
                    else
                        renderer.triangle(tlX, tlY, brX, brY, blX, blY, 255, 255, 255, 150)
                        renderer.triangle(tlX, tlY, trX, trY, blX, blY, 255, 255, 255, 150)
                    end
                end
            end
        end
    end
end)

client.set_event_callback("weapon_fire", function( info )
    if (client.userid_to_entindex(info.userid) == localPlayer) then
        hasShot = true;
    end
end);
