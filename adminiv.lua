-- AdminIV Local Scanner (Delta Executor) - SAFE client-only
-- Key: 4455
-- Nota: Este script SOLO opera en el cliente. No intenta llamar Remotes ni cambiar servidor.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

if not LocalPlayer then return end

-- CONFIG ------------------------------------------------
local REQUIRED_KEY = "4455"
local SEARCH_NAMES = { -- nombres exactos o parciales que buscamos (case-insensitive)
    "vaca", "saturno", "saturnita", "blackhole", "agarrini", "palini",
    "karkerkar", "vaquitas", "chicleteira", "bicicleteira",
    "supreme", "combinasion", "dragon", "cannelloni", "garama", "madundung", "brainrot"
}
local MAX_CLONES = 3 -- cantidad máxima de clones locales simultáneas (por rendimiento)
local SCAN_BATCH_YIELD = 0.03 -- pausa entre lotes para no trabar el teléfono
local UI_SIZE = UDim2.new(0, 360, 0, 420)
local BUTTON_COLOR = Color3.fromRGB(20, 160, 140) -- azul verdoso pequeño
----------------------------------------------------------

-- Helpers
local function lower(s) return (s or ""):lower() end
local function containsAnyName(name)
    local lname = lower(name)
    for _, token in ipairs(SEARCH_NAMES) do
        if string.find(lname, token) then return true end
    end
    return false
end

-- Create GUI (lightweight)
local screen = Instance.new("ScreenGui")
screen.Name = "AdminIV_Local"
screen.ResetOnSpawn = false
screen.Parent = LocalPlayer:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UI_SIZE
main.Position = UDim2.new(0.5, -UI_SIZE.X.Offset/2, 0.15, 0)
main.BackgroundColor3 = Color3.fromRGB(25,25,25)
main.BorderSizePixel = 0
main.Parent = screen
main.Active = true
-- allow dragging (mobile friendly little hack)
local dragInput, dragging, dragStart, startPos
main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)
main.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Header
local header = Instance.new("Frame", main)
header.Size = UDim2.new(1,0,0,38)
header.BackgroundColor3 = Color3.fromRGB(40,40,40)
header.BorderSizePixel = 0

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(0.7,0,1,0)
title.Position = UDim2.new(0,8,0,0)
title.Text = "ADMINIV"
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextSize = 20
title.Font = Enum.Font.SourceSansBold
title.TextColor3 = Color3.fromRGB(200,255,200)
title.BackgroundTransparency = 1

-- minimize and close
local btnMin = Instance.new("TextButton", header)
btnMin.Size = UDim2.new(0,32,0,28)
btnMin.Position = UDim2.new(0.7,0,0.12,0)
btnMin.Text = "_"
btnMin.Font = Enum.Font.SourceSansBold
btnMin.TextSize = 20
btnMin.BackgroundColor3 = Color3.fromRGB(50,50,50)
btnMin.TextColor3 = Color3.fromRGB(220,220,220)

local btnClose = Instance.new("TextButton", header)
btnClose.Size = UDim2.new(0,32,0,28)
btnClose.Position = UDim2.new(0.85,0,0.12,0)
btnClose.Text = "X"
btnClose.Font = Enum.Font.SourceSansBold
btnClose.TextSize = 18
btnClose.BackgroundColor3 = Color3.fromRGB(60,30,30)
btnClose.TextColor3 = Color3.fromRGB(255,255,255)

local content = Instance.new("Frame", main)
content.Size = UDim2.new(1,-8,1,-48)
content.Position = UDim2.new(0,4,0,44)
content.BackgroundTransparency = 1

-- Key entry popup (modal)
local keyFrame = Instance.new("Frame", screen)
keyFrame.Size = UDim2.new(0,300,0,140)
keyFrame.Position = UDim2.new(0.5,-150,0.45,-70)
keyFrame.BackgroundColor3 = Color3.fromRGB(20,20,20)
keyFrame.BorderSizePixel = 0
keyFrame.ZIndex = 5

local kTitle = Instance.new("TextLabel", keyFrame)
kTitle.Size = UDim2.new(1,0,0,36)
kTitle.Position = UDim2.new(0,0,0,6)
kTitle.Text = "KEY REQUIRED"
kTitle.TextColor3 = Color3.fromRGB(180,255,180)
kTitle.Font = Enum.Font.SourceSansBold
kTitle.TextSize = 18
kTitle.BackgroundTransparency = 1

local keyBox = Instance.new("TextBox", keyFrame)
keyBox.Size = UDim2.new(0.9,0,0,36)
keyBox.Position = UDim2.new(0.05,0,0,50)
keyBox.Text = ""
keyBox.ClearTextOnFocus = false
keyBox.PlaceholderText = "Ingrese la clave"
keyBox.Font = Enum.Font.SourceSans
keyBox.TextSize = 18

local keyBtn = Instance.new("TextButton", keyFrame)
keyBtn.Size = UDim2.new(0.4,0,0,28)
keyBtn.Position = UDim2.new(0.3,0,0,95)
keyBtn.Text = "Abrir"
keyBtn.Font = Enum.Font.SourceSansBold
keyBtn.TextSize = 16
keyBtn.BackgroundColor3 = BUTTON_COLOR
keyBtn.TextColor3 = Color3.new(1,1,1)

-- small controls area
local topPanel = Instance.new("Frame", content)
topPanel.Size = UDim2.new(1,0,0,46)
topPanel.Position = UDim2.new(0,0,0,0)
topPanel.BackgroundTransparency = 1

local searchBtn = Instance.new("TextButton", topPanel)
searchBtn.Size = UDim2.new(0,0,1,0) -- width by offset
searchBtn.Position = UDim2.new(0,8,0,6)
searchBtn.Size = UDim2.new(0,140,0,34)
searchBtn.Text = "Buscar Brainrots Secret"
searchBtn.Font = Enum.Font.SourceSansBold
searchBtn.TextSize = 14
searchBtn.BackgroundColor3 = BUTTON_COLOR
searchBtn.TextColor3 = Color3.new(1,1,1)
searchBtn.AutoButtonColor = true

local saveBaseBtn = Instance.new("TextButton", topPanel)
saveBaseBtn.Size = UDim2.new(0,92,0,28)
saveBaseBtn.Position = UDim2.new(0,156,0,9)
saveBaseBtn.Text = "Guardar Base"
saveBaseBtn.Font = Enum.Font.SourceSans
saveBaseBtn.TextSize = 12
saveBaseBtn.BackgroundColor3 = Color3.fromRGB(70,70,70)
saveBaseBtn.TextColor3 = Color3.new(1,1,1)

local teleportBaseBtn = Instance.new("TextButton", topPanel)
teleportBaseBtn.Size = UDim2.new(0,92,0,28)
teleportBaseBtn.Position = UDim2.new(0,256,0,9)
teleportBaseBtn.Text = "Ir a Mi Base"
teleportBaseBtn.Font = Enum.Font.SourceSans
teleportBaseBtn.TextSize = 12
teleportBaseBtn.BackgroundColor3 = Color3.fromRGB(70,70,70)
teleportBaseBtn.TextColor3 = Color3.new(1,1,1)

-- scrolling list of found items
local listFrame = Instance.new("ScrollingFrame", content)
listFrame.Size = UDim2.new(1, -12, 1, -56)
listFrame.Position = UDim2.new(0,6,0,52)
listFrame.CanvasSize = UDim2.new(0,0,0,0)
listFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
listFrame.BorderSizePixel = 0
listFrame.ScrollBarThickness = 6

-- internal state
local foundItems = {} -- { {obj=Instance, path=string, info=table} }
local clones = {} -- active local clones
local myBaseCFrame = nil
local minimized = false

-- UI helpers
local function clearList()
    for _, c in ipairs(listFrame:GetChildren()) do
        if c:IsA("TextButton") or c:IsA("TextLabel") then c:Destroy() end
    end
end

local function renderList()
    clearList()
    local y = 6
    for i, entry in ipairs(foundItems) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -12, 0, 44)
        btn.Position = UDim2.new(0, 6, 0, y)
        btn.BackgroundColor3 = Color3.fromRGB(55,55,55)
        btn.TextColor3 = Color3.fromRGB(240,240,240)
        btn.Font = Enum.Font.SourceSans
        btn.TextSize = 14
        btn.Text = string.format("%s  —  %s", entry.obj.Name, entry.path or "workspace")
        btn.Parent = listFrame

        -- info label small
        local infoLbl = Instance.new("TextLabel", btn)
        infoLbl.Size = UDim2.new(0.6,0,1,0)
        infoLbl.Position = UDim2.new(0.38, 0, 0, 0)
        infoLbl.BackgroundTransparency = 1
        infoLbl.TextXAlignment = Enum.TextXAlignment.Left
        infoLbl.Font = Enum.Font.SourceSansItalic
        infoLbl.TextSize = 12
        local infoText = ""
        if entry.info.TimeLeft then infoText = infoText .. ("⏳ "..tostring(entry.info.TimeLeft).."s ") end
        if entry.info.IncomePerSecond then infoText = infoText .. ("💰 "..tostring(entry.info.IncomePerSecond).."/s") end
        infoLbl.Text = infoText

        -- small action subpanel
        local actPanel = Instance.new("Frame", btn)
        actPanel.Size = UDim2.new(0.45,0,1,0)
        actPanel.Position = UDim2.new(0.55, 0, 0, 0)
        actPanel.BackgroundTransparency = 1

        -- Spawn local visual
        local spawnBtn = Instance.new("TextButton", actPanel)
        spawnBtn.Size = UDim2.new(0,72,0,28)
        spawnBtn.Position = UDim2.new(0,6,0,8)
        spawnBtn.Text = "Spawn"
        spawnBtn.Font = Enum.Font.SourceSans
        spawnBtn.TextSize = 12
        spawnBtn.BackgroundColor3 = Color3.fromRGB(80,80,80)
        spawnBtn.TextColor3 = Color3.new(1,1,1)

        -- Teleport local
        local tpBtn = Instance.new("TextButton", actPanel)
        tpBtn.Size = UDim2.new(0,72,0,28)
        tpBtn.Position = UDim2.new(0,84,0,8)
        tpBtn.Text = "Ir"
        tpBtn.Font = Enum.Font.SourceSans
        tpBtn.TextSize = 12
        tpBtn.BackgroundColor3 = Color3.fromRGB(70,70,140)
        tpBtn.TextColor3 = Color3.new(1,1,1)

        -- Connect actions
        spawnBtn.MouseButton1Click:Connect(function()
            -- spawn local clone in front of player
            if #clones >= MAX_CLONES then
                -- remove oldest
                local old = table.remove(clones, 1)
                if old and old.Parent then old:Destroy() end
            end
            local target = entry.obj
            local ok, clone = pcall(function() return target:Clone() end)
            if not ok or not clone then
                warn("No se pudo clonar localmente: "..tostring(entry.obj))
                return
            end
            clone.Parent = Workspace -- local clone visible to you (may or may not replicate to others)
            -- place clone in front of player
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local hrp = char.HumanoidRootPart
                local cf = hrp.CFrame * CFrame.new(0, 0, -6)
                if clone:IsA("Model") then
                    -- try set primary part
                    if not clone.PrimaryPart then
                        for _, p in pairs(clone:GetDescendants()) do
                            if p:IsA("BasePart") then
                                clone.PrimaryPart = p
                                break
                            end
                        end
                    end
                    if clone.PrimaryPart then
                        clone:SetPrimaryPartCFrame(cf + Vector3.new(0,2,0))
                    else
                        -- brute: try to move first part
                        local firstPart = clone:FindFirstChildWhichIsA("BasePart", true)
                        if firstPart then firstPart.CFrame = cf + Vector3.new(0,2,0) end
                    end
                elseif clone:IsA("BasePart") then
                    clone.CFrame = cf + Vector3.new(0,2,0)
                end
            end
            table.insert(clones, clone)
        end)

        tpBtn.MouseButton1Click:Connect(function()
            -- teleport local player to object position (if it has a BasePart)
            local target = entry.obj
            local pos
            if target:IsA("Model") then
                pos = (target.PrimaryPart and target.PrimaryPart.Position) or (target:FindFirstChildWhichIsA("BasePart") and target:FindFirstChildWhichIsA("BasePart").Position)
            elseif target:IsA("BasePart") then
                pos = target.Position
            elseif target:IsA("Instance") and target:FindFirstChildWhichIsA then
                local part = target:FindFirstChildWhichIsA("BasePart")
                if part then pos = part.Position end
            end
            if pos and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = LocalPlayer.Character.HumanoidRootPart
                -- set CFrame locally
                hrp.CFrame = CFrame.new(pos + Vector3.new(0,3,0))
            else
                warn("No se puede teletransportar: posición no encontrada")
            end
        end)

        y = y + 50
    end
    listFrame.CanvasSize = UDim2.new(0,0,0, y + 20)
end

-- Scan function (async-friendly)
local function scanForBrainrots()
    foundItems = {}
    clearList()
    -- quick scanner helper that yields periodically
    local function scanContainer(container, path)
        local children = container:GetChildren()
        for i = 1, #children do
            local obj = children[i]
            -- if name matches search tokens
            if obj and obj.Name and containsAnyName(obj.Name) then
                -- collect info
                local info = {}
                -- try common attributes (TimeLeft, IncomePerSecond) or values under obj
                local attrTime = obj:GetAttribute and obj:GetAttribute("TimeLeft")
                local attrIncome = obj:GetAttribute and obj:GetAttribute("IncomePerSecond")
                if attrTime then info.TimeLeft = attrTime end
                if attrIncome then info.IncomePerSecond = attrIncome end
                -- check for child NumberValues that might hold info
                local tv = obj:FindFirstChild("TimeLeft") or obj:FindFirstChildWhichIsA("NumberValue")
                if tv and tv.Value then info.TimeLeft = info.TimeLeft or tv.Value end
                local inc = obj:FindFirstChild("IncomePerSecond") or obj:FindFirstChild("Income")
                if inc and inc.Value then info.IncomePerSecond = info.IncomePerSecond or inc.Value end

                table.insert(foundItems, { obj = obj, path = path or tostring(container), info = info })
            end
            -- recursively scan but shallow depth to save performance
            if #obj:GetChildren() > 0 and #foundItems < 250 then
                scanContainer(obj, (path and (path.."/"..obj.Name) or obj.Name))
            end
            -- yield every few iterations to keep UI responsive (mobile)
            if i % 25 == 0 then task.wait(SCAN_BATCH_YIELD) end
        end
    end

    -- scan ReplicatedStorage and Workspace (client-visible)
    local ok1 = pcall(function() scanContainer(ReplicatedStorage, "ReplicatedStorage") end)
    local ok2 = pcall(function() scanContainer(Workspace, "Workspace") end)

    -- deduplicate by instance
    local unique = {}
    local final = {}
    for _, v in ipairs(foundItems) do
        if v.obj and not unique[v.obj] then
            unique[v.obj] = true
            table.insert(final, v)
        end
    end
    foundItems = final
    renderList()
end

-- Key handling
keyBtn.MouseButton1Click:Connect(function()
    local val = tostring(keyBox.Text or "")
    if val == REQUIRED_KEY then
        keyFrame:Destroy()
        main.Visible = true
    else
        keyBox.Text = ""
        keyBox.PlaceholderText = "Clave incorrecta"
    end
end)

-- Buttons
btnClose.MouseButton1Click:Connect(function()
    screen:Destroy()
end)
btnMin.MouseButton1Click:Connect(function()
    minimized = not minimized
    content.Visible = not minimized
    header.Size = minimized and UDim2.new(1,0,0,24) or UDim2.new(1,0,0,38)
end)

searchBtn.MouseButton1Click:Connect(function()
    -- asynchronous scan to keep UI smooth
    spawn(function()
        searchBtn.Text = "Buscando..."
        searchBtn.Active = false
        scanForBrainrots()
        searchBtn.Text = "Buscar Brainrots Secret"
        searchBtn.Active = true
    end)
end)

saveBaseBtn.MouseButton1Click:Connect(function()
    -- save current character position as base (if possible)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        myBaseCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
        saveBaseBtn.Text = "Base guardada"
        task.delay(2, function() pcall(function() saveBaseBtn.Text = "Guardar Base" end) end)
    else
        saveBaseBtn.Text = "No hay personaje"
        task.delay(2, function() pcall(function() saveBaseBtn.Text = "Guardar Base" end) end)
    end
end)

teleportBaseBtn.MouseButton1Click:Connect(function()
    if not myBaseCFrame then
        teleportBaseBtn.Text = "No guardada"
        task.delay(1.6, function() pcall(function() teleportBaseBtn.Text = "Ir a Mi Base" end) end)
        return
    end
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        -- local teleport only
        LocalPlayer.Character.HumanoidRootPart.CFrame = myBaseCFrame + Vector3.new(0,2,0)
    end
end)

-- initially hidden until key entered
main.Visible = false

-- Performance tip: destroy clones on character death to free memory
LocalPlayer.CharacterAdded:Connect(function(char)
    for _, c in ipairs(clones) do
        if c and c.Parent then pcall(function() c:Destroy() end) end
    end
    clones = {}
end)

-- End of script
print("AdminIV Local Scanner cargado (client-only). Ingrese la clave para abrir.")
