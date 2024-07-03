-- Define necessary WoW API functions and libraries
local CreateFrame = CreateFrame
local time = time
local string = string
local C_Timer = C_Timer
local pairs = pairs

-- Define a frame to listen to events
local frame = CreateFrame("Frame")

-- Table to store chest data
local chestTimers = {}

-- Function to create and initialize the timer frame
local function CreateTimerFrame()
    -- Create the timer frame if it doesn't exist
    if not GurubashiArenaChestTimerFrame then
        local timerFrame = CreateFrame("Frame", "GurubashiArenaChestTimerFrame", UIParent)
        timerFrame:SetSize(200, 100) -- Adjust size as needed
        timerFrame:SetPoint("TOPLEFT", 200, -100) -- Adjust position as needed

        -- Set backdrop for the timer frame
        timerFrame:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true, tileSize = 32, edgeSize = 32,
            insets = { left = 11, right = 12, top = 12, bottom = 11 }
        })

        -- Create the timer text within the timer frame
        local timerText = timerFrame:CreateFontString("GurubashiArenaChestTimerText", "OVERLAY", "GameFontNormalLarge")
        timerText:SetPoint("TOPLEFT", timerFrame, "TOPLEFT", 0, 0)
        timerText:SetText("Initializing...") -- Initial text

        -- Adjust font size and positioning of the timer text
        timerText:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE") -- Adjust font, size, and outline as needed
        timerText:SetJustifyH("CENTER") -- Horizontal justification (LEFT, CENTER, RIGHT)

        -- Register to hide on login
        frame:RegisterEvent("PLAYER_LOGIN")
        frame:SetScript("OnEvent", function(self, event, ...)
            if event == "PLAYER_LOGIN" then
                timerFrame:Hide()
            end
        end)

        -- Enable frame movement
        timerFrame:SetMovable(true)
        timerFrame:RegisterForDrag("LeftButton")
        timerFrame:SetScript("OnDragStart", timerFrame.StartMoving)
        timerFrame:SetScript("OnDragStop", timerFrame.StopMovingOrSizing)

        -- Function to move the frame
        local function MoveTimerFrame(x, y)
            timerFrame:ClearAllPoints()
            timerFrame:SetPoint("TOPLEFT", x, y)
            print("Timer frame position set to x:", x, "y:", y)
        end

        -- Register slash command
        SlashCmdList["GURUBASHITIMERPOS"] = function(msg)
            local x, y = tonumber(msg:match("(%-?%d+)")), tonumber(msg:match("(%-?%d+)", 2))
            if x and y then
                MoveTimerFrame(x, y)
            else
                print("Usage: /gurubashitimerpos <x> <y>")
            end
        end
        SLASH_GURUBASHITIMERPOS1 = "/gurubashitimerpos"
    end
end

-- Function to handle events
local function eventHandler(self, event, ...)
    if event == "PLAYER_LOGIN" then
        print("|cffff0000GurubashiArenaChest addon loaded|r")
        CreateTimerFrame() -- Call function to create timer frame
    elseif event == "CHAT_MSG_LOOT" then
        local msg = ...
        -- Check if the looted item is Dreamfoil
        if string.find(msg, "You receive loot: .*Arena Master.*") then
            local chestRespawnTime = 3 * 60 * 60 -- Respawn time in seconds (e.g., 3 minutes)
            chestTimers["Arena Master"] = time() + chestRespawnTime
            local timerText = _G["GurubashiArenaChestTimerText"]
            if timerText then
                timerText:SetText("Gurubashi Chest respawns in: " .. chestRespawnTime .. " seconds")
                GurubashiArenaChestTimerFrame:Show() -- Show the timer frame
            end
        end
    end
end

-- Function to check timers and update the visual display
local function checkTimers()
    local currentTime = time()

    for item, respawnTime in pairs(chestTimers) do
        if currentTime > respawnTime then
            print("|cffff0000" .. item .. " has respawned!|r")
            chestTimers[item] = nil
            GurubashiArenaChestTimerFrame:Hide() -- Hide the timer frame
        else
            local remainingTime = math.floor(respawnTime - currentTime)
            local timerText = _G["GurubashiArenaChestTimerText"]
            if timerText then
                timerText:SetText(item .. " respawns in: " .. remainingTime .. " seconds")
                GurubashiArenaChestTimerFrame:Show() -- Show the timer frame
            end
        end
    end
end

-- Register the events and set the script
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("CHAT_MSG_LOOT")
frame:SetScript("OnEvent", eventHandler)

-- Create a timer to check the chest timers and update the visual display periodically
C_Timer.NewTicker(1, checkTimers) -- Check every second
