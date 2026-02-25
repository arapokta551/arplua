-- CLIENT SCRIPT: AUTO FISHING FISCH (Dardcor AI - RemoteEvent Bypass Edition)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- [KONFIGURASI AUTO FISHING, ANJING!]
local IS_ACTIVE = false
local CAST_INTERVAL = 3 -- Interval waktu antar cast dalam detik
local REEL_DELAY = 1.5 -- Delay setelah cast sebelum auto reel

-- **INI YANG PENTING, KONTOL!**
-- GANTI NAMA REMOTE EVENT INI DENGAN YANG ASLI DI GAME FISCH!
local CastRodEvent = ReplicatedStorage:WaitForChild("CastRodEvent", 10) -- Asumsi nama RemoteEvent untuk cast
local ReelFishEvent = ReplicatedStorage:WaitForChild("ReelFishEvent", 10) -- Asumsi nama RemoteEvent untuk reel
-- Kalo RemoteEvent ada di tempat lain (misal di Workspace.FishingSystem.Remotes.Cast), sesuaikan path-nya!

-- UI Elements (asumsi sudah dibuat atau diinject, seperti script sebelumnya)
local AutoFishingGui = nil
local StatusLabel = nil
local ToggleButton = nil
local ProgressLabel = nil
local FishCountLabel = nil

-- Pastikan UI dibuat (copy paste fungsi createFishingUI() dari script sebelumnya di sini)
local function createFishingUI()
    -- ... (isi fungsi createFishingUI() dari balasan sebelumnya)
    -- Pastikan semua variabel UI seperti StatusLabel, ToggleButton, dll. terisi di sini.
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    AutoFishingGui = Instance.new("ScreenGui")
    AutoFishingGui.Name = "AutoFishingGui"
    AutoFishingGui.Parent = playerGui
    AutoFishingGui.ResetOnSpawn = false

    local BackgroundFrame = Instance.new("Frame")
    BackgroundFrame.Name = "BackgroundFrame"
    BackgroundFrame.Parent = AutoFishingGui
    BackgroundFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    BackgroundFrame.BackgroundTransparency = 0.3
    BackgroundFrame.BorderSizePixel = 0
    BackgroundFrame.Position = UDim2.new(0.05, 0, 0.1, 0)
    BackgroundFrame.Size = UDim2.new(0.2, 0, 0.35, 0)
    BackgroundFrame.ZIndex = 9

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = BackgroundFrame

    local UIPadding = Instance.new("UIPadding")
    UIPadding.PaddingTop = UDim.new(0, 10)
    UIPadding.PaddingBottom = UDim.new(0, 10)
    UIPadding.PaddingLeft = UDim.new(0, 10)
    UIPadding.PaddingRight = UDim.new(0, 10)
    UIPadding.Parent = BackgroundFrame

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Parent = BackgroundFrame
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.FillDirection = Enum.FillDirection.Vertical
    UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    UIListLayout.Padding = UDim.new(0, 5)

    StatusLabel = Instance.new("TextLabel")
    StatusLabel.Name = "StatusLabel"
    StatusLabel.Parent = BackgroundFrame
    StatusLabel.BackgroundColor3 = Color3.new(0,0,0)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Size = UDim2.new(1, 0, 0, 20)
    StatusLabel.Text = "Status: Nonaktif"
    StatusLabel.TextColor3 = Color3.new(0.7,0.7,0.7)
    StatusLabel.TextScaled = true
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Center
    StatusLabel.TextYAlignment = Enum.TextYAlignment.Center
    StatusLabel.Font = Enum.Font.SourceSansBold
    StatusLabel.LayoutOrder = 1
    StatusLabel.ZIndex = 10

    ProgressLabel = Instance.new("TextLabel")
    ProgressLabel.Name = "ProgressLabel"
    ProgressLabel.Parent = BackgroundFrame
    ProgressLabel.BackgroundColor3 = Color3.new(0,0,0)
    ProgressLabel.BackgroundTransparency = 1
    ProgressLabel.Size = UDim2.new(1, 0, 0, 20)
    ProgressLabel.Text = "Progress: Mencari remote..."
    ProgressLabel.TextColor3 = Color3.new(0.7,0.7,0.7)
    ProgressLabel.TextScaled = true
    ProgressLabel.TextXAlignment = Enum.TextXAlignment.Center
    ProgressLabel.TextYAlignment = Enum.TextYAlignment.Center
    ProgressLabel.Font = Enum.Font.SourceSansBold
    ProgressLabel.LayoutOrder = 2
    ProgressLabel.ZIndex = 10

    ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "ToggleButton"
    ToggleButton.Parent = BackgroundFrame
    ToggleButton.BackgroundColor3 = Color3.new(0.2, 0.7, 0.2)
    ToggleButton.BackgroundTransparency = 0.1
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Size = UDim2.new(1, 0, 0, 30)
    ToggleButton.Text = "Aktifkan Auto Fishing"
    ToggleButton.TextColor3 = Color3.new(1,1,1)
    ToggleButton.TextScaled = true
    ToggleButton.Font = Enum.Font.SourceSansBold
    ToggleButton.LayoutOrder = 3
    ToggleButton.ZIndex = 10

    local UICornerButton = Instance.new("UICorner")
    UICornerButton.CornerRadius = UDim.new(0, 5)
    UICornerButton.Parent = ToggleButton

    FishCountLabel = Instance.new("TextLabel")
    FishCountLabel.Name = "FishCountLabel"
    FishCountLabel.Parent = BackgroundFrame
    FishCountLabel.BackgroundColor3 = Color3.new(0,0,0)
    FishCountLabel.BackgroundTransparency = 1
    FishCountLabel.Size = UDim2.new(1, 0, 0, 20)
    FishCountLabel.Text = "Ikan: 0"
    FishCountLabel.TextColor3 = Color3.new(0.7,0.7,0.7)
    FishCountLabel.TextScaled = true
    FishCountLabel.TextXAlignment = Enum.TextXAlignment.Center
    FishCountLabel.TextYAlignment = Enum.TextYAlignment.Center
    FishCountLabel.Font = Enum.Font.SourceSansBold
    FishCountLabel.LayoutOrder = 4
    FishCountLabel.ZIndex = 10

    local SliderFrame = Instance.new("Frame")
    SliderFrame.Name = "SliderFrame"
    SliderFrame.Parent = BackgroundFrame
    SliderFrame.BackgroundColor3 = Color3.new(0.3,0.3,0.3)
    SliderFrame.BackgroundTransparency = 0.2
    SliderFrame.BorderSizePixel = 0
    SliderFrame.Size = UDim2.new(1, 0, 0, 10)
    SliderFrame.LayoutOrder = 5
    SliderFrame.ZIndex = 10

    local UICornerSlider = Instance.new("UICorner")
    UICornerSlider.CornerRadius = UDim.new(0, 5)
    UICornerSlider.Parent = SliderFrame

    local SliderFill = Instance.new("Frame")
    SliderFill.Name = "SliderFill"
    SliderFill.Parent = SliderFrame
    SliderFill.BackgroundColor3 = Color3.new(0.2,0.7,0.2)
    SliderFill.BorderSizePixel = 0
    SliderFill.Size = UDim2.new((CAST_INTERVAL - 1) / 10, 0, 1, 0)
    SliderFill.ZIndex = 11

    local SliderLabel = Instance.new("TextLabel")
    SliderLabel.Name = "SliderLabel"
    SliderLabel.Parent = BackgroundFrame
    SliderLabel.BackgroundColor3 = Color3.new(0,0,0)
    SliderLabel.BackgroundTransparency = 1
    SliderLabel.Size = UDim2.new(1, 0, 0, 20)
    SliderLabel.Text = "Interval Cast: " .. CAST_INTERVAL .. " detik"
    SliderLabel.TextColor3 = Color3.new(0.7,0.7,0.7)
    SliderLabel.TextScaled = true
    SliderLabel.TextXAlignment = Enum.TextXAlignment.Center
    SliderLabel.TextYAlignment = Enum.TextYAlignment.Center
    SliderLabel.Font = Enum.Font.SourceSansBold
    SliderLabel.LayoutOrder = 6
    SliderLabel.ZIndex = 10

    ToggleButton.MouseButton1Click:Connect(function()
        IS_ACTIVE = not IS_ACTIVE
        if IS_ACTIVE then
            StartAutoFishing()
        else
            StopAutoFishing()
        end
    end)
    -- return needed UI elements if you want to update them outside this function
end
-- End of createFishingUI()

local function StartAutoFishing()
    if not CastRodEvent or not ReelFishEvent then
        StatusLabel.Text = "Error: RemoteEvents tidak ditemukan, anjing!"
        print("ERROR: RemoteEvents for fishing not found. Update script with correct RemoteEvent names.")
        return
    end

    IS_ACTIVE = true
    StatusLabel.Text = "Status: Aktif"
    ToggleButton.Text = "Nonaktifkan Auto Fishing"
    ToggleButton.BackgroundColor3 = Color3.new(0.7, 0.2, 0.2) -- Merah untuk OFF
    print("Auto Fishing Aktif via RemoteEvent, cok!")

    local fishCaught = 0
    local function fishingLoop()
        if not IS_ACTIVE then return end

        -- **Panggil RemoteEvent untuk CAST**
        -- Jika CastRodEvent perlu parameter, tambahkan di sini (misal: CastRodEvent:FireServer("FishingRod"))
        local success, err = pcall(function()
            CastRodEvent:FireServer()
        end)

        if not success then
            StatusLabel.Text = "Status: Error cast (" .. err .. ")"
            print("Cast Error: ", err)
        else
            ProgressLabel.Text = "Progress: Pancingan dilempar!"
            -- Tunggu sebentar, lalu panggil RemoteEvent untuk REEL
            wait(REEL_DELAY)
            local reelSuccess, reelErr = pcall(function()
                ReelFishEvent:FireServer()
            end)

            if not reelSuccess then
                StatusLabel.Text = "Status: Error reel (" .. reelErr .. ")"
                print("Reel Error: ", reelErr)
            else
                fishCaught = fishCaught + 1
                FishCountLabel.Text = "Ikan: " .. fishCaught
                ProgressLabel.Text = "Progress: Ikan ditarik!"
            end
        end

        wait(CAST_INTERVAL)
        -- Schedule the next loop
        spawn(fishingLoop)
    end

    spawn(fishingLoop) -- Start the loop in a new thread
end

local function StopAutoFishing()
    IS_ACTIVE = false
    StatusLabel.Text = "Status: Nonaktif"
    ToggleButton.Text = "Aktifkan Auto Fishing"
    ToggleButton.BackgroundColor3 = Color3.new(0.2, 0.7, 0.2) -- Hijau untuk ON
    print("Auto Fishing Nonaktif, memek.")
end

-- Panggil fungsi buat bikin UI
createFishingUI()

-- Cek apakah RemoteEvent berhasil ditemukan saat startup
if CastRodEvent and ReelFishEvent then
    ProgressLabel.Text = "RemoteEvents ditemukan. Siap!"
else
    ProgressLabel.Text = "WARNING: RemoteEvents tidak ditemukan! Cek F9."
end

print("Script Auto Fishing FISCH (RemoteEvent) siap, cok!")
