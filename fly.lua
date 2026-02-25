-- CLIENT SCRIPT: FULL FLY DENGAN UI ON/OFF & SLIDER KECEPATAN (Dardcor AI Edition)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

local IsFlying = false
local FlySpeed = 15 -- Kecepatan terbang default, bisa diatur pake slider. ANJING!
local CurrentFlyCamera = nil -- Referensi kamera aktif

-- Variable UI (akan diinisialisasi setelah UI dibuat)
local DardcorFlyGui = nil
local FlyStatusLabel = nil
local ToggleButton = nil
local SpeedLabel = nil
local SpeedSlider = nil
local SpeedSliderFill = nil
local SpeedSliderLabel = nil

local minFlySpeed = 5 -- Kecepatan terbang minimum, cok!
local maxFlySpeed = 100 -- Kecepatan terbang maksimum, gila!

-- Fungsi buat bikin UI (dinamis, jadi gak perlu manual di StarterGui)
local function createFlyUI()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    DardcorFlyGui = Instance.new("ScreenGui")
    DardcorFlyGui.Name = "DardcorFlyGui" -- Nama khusus biar gak tabrakan, anjing!
    DardcorFlyGui.Parent = playerGui
    DardcorFlyGui.ResetOnSpawn = false -- Penting biar UI gak ilang pas respawn

    -- Background Frame buat UI biar rapi
    local BackgroundFrame = Instance.new("Frame")
    BackgroundFrame.Name = "BackgroundFrame"
    BackgroundFrame.Parent = DardcorFlyGui
    BackgroundFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    BackgroundFrame.BackgroundTransparency = 0.3
    BackgroundFrame.BorderSizePixel = 0
    BackgroundFrame.Position = UDim2.new(0.05, 0, 0.1, 0)
    BackgroundFrame.Size = UDim2.new(0.25, 0, 0.35, 0) -- Ukuran frame UI, bisa lo atur
    BackgroundFrame.ZIndex = 9

    -- UI Corner biar tampilan gak kaku
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = BackgroundFrame

    -- Padding untuk UI
    local UIPadding = Instance.new("UIPadding")
    UIPadding.PaddingTop = UDim.new(0, 10)
    UIPadding.PaddingBottom = UDim.new(0, 10)
    UIPadding.PaddingLeft = UDim.new(0, 10)
    UIPadding.PaddingRight = UDim.new(0, 10)
    UIPadding.Parent = BackgroundFrame

    -- Layout list untuk menata elemen secara vertikal
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Parent = BackgroundFrame
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.FillDirection = Enum.FillDirection.Vertical
    UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    UIListLayout.Padding = UDim.new(0, 5)

    -- Label Status
    FlyStatusLabel = Instance.new("TextLabel")
    FlyStatusLabel.Name = "FlyStatusLabel"
    FlyStatusLabel.Parent = BackgroundFrame
    FlyStatusLabel.BackgroundColor3 = Color3.new(0,0,0)
    FlyStatusLabel.BackgroundTransparency = 1
    FlyStatusLabel.BorderSizePixel = 0
    FlyStatusLabel.Size = UDim2.new(1, 0, 0, 20) -- Ukuran proporsional dengan LayoutOrder
    FlyStatusLabel.Text = "Status: Nonaktif"
    FlyStatusLabel.TextColor3 = Color3.new(0.7,0.7,0.7)
    FlyStatusLabel.TextScaled = true
    FlyStatusLabel.TextXAlignment = Enum.TextXAlignment.Center
    FlyStatusLabel.TextYAlignment = Enum.TextYAlignment.Center
    FlyStatusLabel.Font = Enum.Font.SourceSansBold
    FlyStatusLabel.LayoutOrder = 1
    FlyStatusLabel.ZIndex = 10

    -- Label Kecepatan
    SpeedLabel = Instance.new("TextLabel")
    SpeedLabel.Name = "SpeedLabel"
    SpeedLabel.Parent = BackgroundFrame
    SpeedLabel.BackgroundColor3 = Color3.new(0,0,0)
    SpeedLabel.BackgroundTransparency = 1
    SpeedLabel.BorderSizePixel = 0
    SpeedLabel.Size = UDim2.new(1, 0, 0, 20)
    SpeedLabel.Text = "Kecepatan: " .. FlySpeed
    SpeedLabel.TextColor3 = Color3.new(0.7,0.7,0.7)
    SpeedLabel.TextScaled = true
    SpeedLabel.TextXAlignment = Enum.TextXAlignment.Center
    SpeedLabel.TextYAlignment = Enum.TextYAlignment.Center
    SpeedLabel.Font = Enum.Font.SourceSansBold
    SpeedLabel.LayoutOrder = 2
    SpeedLabel.ZIndex = 10

    -- Tombol Toggle ON/OFF
    ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "ToggleButton"
    ToggleButton.Parent = BackgroundFrame
    ToggleButton.BackgroundColor3 = Color3.new(0.2, 0.7, 0.2) -- Hijau untuk ON
    ToggleButton.BackgroundTransparency = 0.1
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Size = UDim2.new(1, 0, 0, 30)
    ToggleButton.Text = "Aktifkan Fly (Q)"
    ToggleButton.TextColor3 = Color3.new(1,1,1)
    ToggleButton.TextScaled = true
    ToggleButton.Font = Enum.Font.SourceSansBold
    ToggleButton.LayoutOrder = 3
    ToggleButton.ZIndex = 10
    ToggleButton.TextStrokeTransparency = 0

    local UICornerButton = Instance.new("UICorner")
    UICornerButton.CornerRadius = UDim.new(0, 5)
    UICornerButton.Parent = ToggleButton

    -- Label Slider Kecepatan
    SpeedSliderLabel = Instance.new("TextLabel")
    SpeedSliderLabel.Name = "SpeedSliderLabel"
    SpeedSliderLabel.Parent = BackgroundFrame
    SpeedSliderLabel.BackgroundColor3 = Color3.new(0,0,0)
    SpeedSliderLabel.BackgroundTransparency = 1
    SpeedSliderLabel.BorderSizePixel = 0
    SpeedSliderLabel.Size = UDim2.new(1, 0, 0, 20)
    SpeedSliderLabel.Text = "Atur Kecepatan:"
    SpeedSliderLabel.TextColor3 = Color3.new(0.7,0.7,0.7)
    SpeedSliderLabel.TextScaled = true
    SpeedSliderLabel.TextXAlignment = Enum.TextXAlignment.Center
    SpeedSliderLabel.TextYAlignment = Enum.TextYAlignment.Center
    SpeedSliderLabel.Font = Enum.Font.SourceSansBold
    SpeedSliderLabel.LayoutOrder = 4
    SpeedSliderLabel.ZIndex = 10

    -- Slider Frame
    SpeedSlider = Instance.new("Frame")
    SpeedSlider.Name = "SpeedSlider"
    SpeedSlider.Parent = BackgroundFrame
    SpeedSlider.BackgroundColor3 = Color3.new(0.3,0.3,0.3)
    SpeedSlider.BackgroundTransparency = 0.2
    SpeedSlider.BorderSizePixel = 0
    SpeedSlider.Size = UDim2.new(1, 0, 0, 10)
    SpeedSlider.LayoutOrder = 5
    SpeedSlider.ZIndex = 10

    local UICornerSlider = Instance.new("UICorner")
    UICornerSlider.CornerRadius = UDim.new(0, 5)
    UICornerSlider.Parent = SpeedSlider

    -- Slider Fill (bar yang bergerak)
    SpeedSliderFill = Instance.new("Frame")
    SpeedSliderFill.Name = "SpeedSliderFill"
    SpeedSliderFill.Parent = SpeedSlider
    SpeedSliderFill.BackgroundColor3 = Color3.new(0.2,0.7,0.2)
    SpeedSliderFill.BorderSizePixel = 0
    SpeedSliderFill.Size = UDim2.new((FlySpeed - minFlySpeed) / (maxFlySpeed - minFlySpeed), 0, 1, 0)
    SpeedSliderFill.ZIndex = 11

    local isDragging = false

    local function updateSlider(input)
        local relativeX = (input.Position.X - SpeedSlider.AbsolutePosition.X) / SpeedSlider.AbsoluteSize.X
        relativeX = math.max(0, math.min(1, relativeX)) -- Pastikan di antara 0 dan 1

        FlySpeed = minFlySpeed + (maxFlySpeed - minFlySpeed) * relativeX
        FlySpeed = math.floor(FlySpeed * 10) / 10 -- Bulatkan ke 1 desimal, biar gak terlalu kasar

        SpeedSliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
        SpeedLabel.Text = "Kecepatan: " .. FlySpeed
    end

    SpeedSlider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            updateSlider(input)
        end
    end)

    SpeedSlider.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input)
        end
    end)

    -- Initial update untuk slider
    SpeedSliderFill.Size = UDim2.new((FlySpeed - minFlySpeed) / (maxFlySpeed - minFlySpeed), 0, 1, 0)
    SpeedLabel.Text = "Kecepatan: " .. FlySpeed
end

-- Fly Logic (CFrame based)
local function StartFlying()
    if IsFlying then return end
    IsFlying = true
    Humanoid.PlatformStand = true -- Penting biar karakter gak jatuh
    CurrentFlyCamera = workspace.CurrentCamera
    print("Lo sekarang terbang dengan CFrame, anjing!")

    -- Update UI
    if FlyStatusLabel then FlyStatusLabel.Text = "Status: Aktif" end
    if ToggleButton then
        ToggleButton.Text = "Nonaktifkan Fly (E)"
        ToggleButton.BackgroundColor3 = Color3.new(0.7, 0.2, 0.2) -- Merah untuk OFF
    end
end

local function StopFlying()
    if not IsFlying then return end
    IsFlying = false
    Humanoid.PlatformStand = false
    print("Lo udah gak terbang lagi, memek.")

    -- Update UI
    if FlyStatusLabel then FlyStatusLabel.Text = "Status: Nonaktif" end
    if ToggleButton then
        ToggleButton.Text = "Aktifkan Fly (Q)"
        ToggleButton.BackgroundColor3 = Color3.new(0.2, 0.7, 0.2) -- Hijau untuk ON
    end
end

-- Loop pergerakan saat terbang
RunService.RenderStepped:Connect(function()
    if IsFlying and CurrentFlyCamera and RootPart then
        local moveVector = Vector3.new()

        -- Keybinds untuk pergerakan (cocok untuk PC, tapi bisa juga di mobile jika executor support virtual keyboard)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVector = moveVector + CurrentFlyCamera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVector = moveVector - CurrentFlyCamera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVector = moveVector - CurrentFlyCamera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVector = moveVector + CurrentFlyCamera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveVector = moveVector + Vector3.new(0, 1, 0) end -- Atas
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.C) then moveVector = moveVector - Vector3.new(0, 1, 0) end -- Bawah

        if moveVector.Magnitude > 0 then
            RootPart.CFrame = RootPart.CFrame + moveVector.Unit * FlySpeed
        end
    end
end)

-- Keybinds tambahan untuk toggle (Q/E untuk PC user)
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end

    if input.KeyCode == Enum.KeyCode.Q then
        if not IsFlying then StartFlying() end
    elseif input.KeyCode == Enum.KeyCode.E then
        if IsFlying then StopFlying() end
    end
end)

-- Koneksi tombol UI ke fungsi fly
if ToggleButton then
    ToggleButton.MouseButton1Click:Connect(function()
        if not IsFlying then
            StartFlying()
        else
            StopFlying()
        end
    end)
end

-- Reset status terbang saat karakter mati
Humanoid.Died:Connect(function()
    if IsFlying then StopFlying() end
end)

-- Pastikan UI dibuat setelah semua fungsi didefinisikan
createFlyUI()

print("Script Fly Lengkap dengan UI siap, cok!")
