-- CLIENT SCRIPT: StarterPlayer/StarterPlayerScripts/FlyScript

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

local IsFlying = false
local FlySpeed = 15 -- Kecepatan terbang, bisa lu ganti, anjing!
local FlyForce = 500 -- Kekuatan dorong saat terbang, sesuaikan kalo kurang mantap
local OriginalGravity = workspace.Gravity -- Simpen gravitasi asli
local FlyBodyVelocity = nil -- Objek BodyVelocity untuk kontrol terbang

-- Fungsi buat mulai terbang
local function StartFlying()
    if IsFlying then return end -- Kalo udah terbang, gak usah ngapa-ngapain lagi, tolol

    IsFlying = true
    Humanoid.PlatformStand = true -- Bikin karakter gak bisa jatuh
    workspace.Gravity = 0 -- Matiin gravitasi biar gak jatuh

    -- Bikin BodyVelocity buat ngontrol gerakan
    FlyBodyVelocity = Instance.new("BodyVelocity")
    FlyBodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge) -- Kekuatan maksimal, anjay
    FlyBodyVelocity.P = 10000 -- Tingkatin P biar responsif
    FlyBodyVelocity.Parent = RootPart -- Tempelin ke HumanoidRootPart

    print("Lo sekarang terbang, anjing!")
end

-- Fungsi buat berhenti terbang
local function StopFlying()
    if not IsFlying then return end -- Kalo gak terbang, gak usah ngapa-ngapain lagi

    IsFlying = false
    Humanoid.PlatformStand = false -- Balikin bisa jatuh lagi
    workspace.Gravity = OriginalGravity -- Balikin gravitasi asli

    -- Hapus BodyVelocity
    if FlyBodyVelocity then
        FlyBodyVelocity:Destroy()
        FlyBodyVelocity = nil
    end

    print("Lo udah gak terbang lagi, memek.")
end

-- Update gerakan pas terbang
RunService.RenderStepped:Connect(function()
    if IsFlying and FlyBodyVelocity then
        local moveVector = Vector3.new()
        local camera = workspace.CurrentCamera

        -- Cek input tombol buat arah gerakan
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then -- Maju
            moveVector = moveVector + camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then -- Mundur
            moveVector = moveVector - camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then -- Kiri
            moveVector = moveVector - camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then -- Kanan
            moveVector = moveVector + camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then -- Atas
            moveVector = moveVector + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.C) then -- Bawah
            moveVector = moveVector - Vector3.new(0, 1, 0)
        end

        -- Kalo ada gerakan, set kecepatan BodyVelocity
        if moveVector.Magnitude > 0 then
            FlyBodyVelocity.Velocity = moveVector.Unit * FlySpeed
        else
            -- Kalo gak ada input, tahan di posisi saat ini
            FlyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
        end
    end
end)


-- Listener buat input tombol (Q untuk mulai, E untuk berhenti)
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end

    if input.KeyCode == Enum.KeyCode.Q then
        if not IsFlying then
            StartFlying()
        end
    elseif input.KeyCode == Enum.KeyCode.E then
        if IsFlying then
            StopFlying()
        end
    end
end)

-- Pastiin kalo karakter mati, status terbangnya di-reset
Humanoid.Died:Connect(function()
    if IsFlying then
        StopFlying()
    end
end)

-- Kalo player keluar game, pastiin gravitasi balik normal
Players.PlayerRemoving:Connect(function(player)
    if player == LocalPlayer and IsFlying then
        StopFlying()
    end
end)

print("Script Fly Ready, jancok!")
