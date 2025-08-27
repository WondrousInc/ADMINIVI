-- AdminIV Spawner Script (Delta Executor)

local plr = game.Players.LocalPlayer

-- GUI principal
local ScreenGui = Instance.new("ScreenGui", plr.PlayerGui)
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 400, 0, 500)
Frame.Position = UDim2.new(0.5, -200, 0.5, -250)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.Active = true
Frame.Draggable = true

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1,0,0,40)
Title.Text = "AdminIV Spawner"
Title.BackgroundColor3 = Color3.fromRGB(50,50,50)
Title.TextColor3 = Color3.fromRGB(0,255,0)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 20

local SearchBtn = Instance.new("TextButton", Frame)
SearchBtn.Size = UDim2.new(1,-20,0,40)
SearchBtn.Position = UDim2.new(0,10,0,50)
SearchBtn.Text = "Buscar Exclusivos"
SearchBtn.BackgroundColor3 = Color3.fromRGB(0,170,0)
SearchBtn.TextColor3 = Color3.new(1,1,1)
SearchBtn.Font = Enum.Font.SourceSansBold
SearchBtn.TextSize = 18

local List = Instance.new("ScrollingFrame", Frame)
List.Size = UDim2.new(1,-20,0,380)
List.Position = UDim2.new(0,10,0,100)
List.CanvasSize = UDim2.new(0,0,3,0)
List.BackgroundColor3 = Color3.fromRGB(40,40,40)

-- Función para buscar objetos
local function scanGame()
    local found = {}
    
    local function scanFolder(folder)
        for _, obj in ipairs(folder:GetChildren()) do
            if obj:IsA("Model") or obj:IsA("Part") or obj:IsA("Accessory") then
                table.insert(found, obj)
            end
            if #obj:GetChildren() > 0 then
                scanFolder(obj)
            end
        end
    end
    
    scanFolder(game:GetService("ReplicatedStorage"))
    scanFolder(game:GetService("Workspace"))
    
    return found
end

-- Mostrar lista de spawns
local function showObjects(objects)
    List:ClearAllChildren()
    local y = 0
    for _, obj in ipairs(objects) do
        local Btn = Instance.new("TextButton", List)
        Btn.Size = UDim2.new(1,-10,0,40)
        Btn.Position = UDim2.new(0,5,0,y)
        Btn.Text = obj.Name
        Btn.BackgroundColor3 = Color3.fromRGB(70,70,70)
        Btn.TextColor3 = Color3.new(1,1,1)
        Btn.Font = Enum.Font.SourceSansBold
        Btn.TextSize = 16
        Btn.MouseButton1Click:Connect(function()
            local clone = obj:Clone()
            clone.Parent = workspace
            if clone:IsA("Model") and clone:FindFirstChild("PrimaryPart") then
                clone:SetPrimaryPartCFrame(plr.Character.HumanoidRootPart.CFrame * CFrame.new(0,5,0))
            elseif clone:IsA("Part") then
                clone.CFrame = plr.Character.HumanoidRootPart.CFrame * CFrame.new(0,5,0)
            end
            print("Spawned: "..obj.Name)
        end)
        y = y + 45
    end
end

-- Botón verde acción
SearchBtn.MouseButton1Click:Connect(function()
    print("Buscando objetos...")
    local objects = scanGame()
    print("Encontrados: "..#objects)
    showObjects(objects)
end)
