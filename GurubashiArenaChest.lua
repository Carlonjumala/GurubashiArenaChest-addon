-- Declare necessary WoW API functions and libraries
local CreateFrame = CreateFrame
local time = time
local print = print
local string = string
local C_Timer = C_Timer
local pairs = pairs

-- Define a frame to listen to events
local frame = CreateFrame("Frame")

-- Table to store chest data
local chestTimers = {}

-- Function to handle events
local function eventHandler(self, event, ...)
    if event == "PLAYER_LOGIN" then
        print("|cffff0000GurubashiArenaChest|r" .. "addon loaded")
    elseif event == "CHAT_MSG_LOOT" then
        local msg = ...
        print("Loot message: " .. msg)

        -- Check if the looted item is the one we're interested in
        if string.find(msg, "You receive loot: [Arena Master]") then
            local itemID = 13463 -- Item ID for Arena Master from Gurubashi Arena Chest
            local chestRespawnTime = 3 * 60 -- Respawn time in seconds (e.g., 3 minutes)
            chestTimers[itemID] = time() + chestRespawnTime
            print("Gurubashi arena chest looted! Starting timer.")
        end
    end
end

-- Function to check timers
local function checkTimers()
    for itemID, respawnTime in pairs(chestTimers) do
        if time() > respawnTime then
            print("Gurubashi Arena Chest has respawned!")
            chestTimers[itemID] = nil
        end
    end
end

-- Register the events and set the script
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("CHAT_MSG_LOOT")
frame:SetScript("OnEvent", eventHandler)

-- Create a timer to check the chest timers periodically
C_Timer.NewTicker(10, checkTimers) -- Check every 10 seconds
