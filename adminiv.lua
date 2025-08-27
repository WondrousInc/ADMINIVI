-- AdminIV Script for Delta Executor

-- Función para abrir la consola
local function openConsole()
    print("Consola abierta. Escribe tus comandos aquí.")
end

-- Función para detectar y activar todos los comandos
local function autoDetectCommands()
    local commands = {}
    local detectedCommands = {}

    -- Función para ejecutar un comando
    local function executeCommand(command)
        print("Ejecutando comando: " .. command)
        game:GetService("RunService"):RunScript(command)
    end

    -- Buscar comandos en el servidor
    for _, script in ipairs(game:GetService("ServerScriptService"):GetChildren()) do
        if script:IsA("Script") or script:IsA("LocalScript") then
            local source = script.Source
            for command in source:gmatch("%;%w+") do
                if not table.find(commands, command) then
                    table.insert(commands, command)
                end
            end
        end
    end

    -- Buscar comandos en el ReplicatedStorage
    for _, module in ipairs(game:GetService("ReplicatedStorage"):GetChildren()) do
        if module:IsA("ModuleScript") then
            local source = module.Source
            for command in source:gmatch("%;%w+") do
                if not table.find(commands, command) then
                    table.insert(commands, command)
                end
            end
        end
    end

    -- Ejecutar cada comando detectado
    for _, command in ipairs(commands) do
        executeCommand(command)
        table.insert(detectedCommands, command)
    end

    return detectedCommands
end

-- Función para mostrar todos los comandos disponibles
local function showAllCommands(detectedCommands)
    print("Comandos disponibles:")
    for _, command in ipairs(detectedCommands) do
        print(command)
    end
end

-- Función para otorgar permisos de administrador
local function grantAdminPermissions()
    local player = game.Players.LocalPlayer
    local adminScript = Instance.new("Script")
    adminScript.Parent = game:GetService("Lighting")
    adminScript.Name = "AdminScript"

    adminScript.Source = [[
        local player = game.Players.LocalPlayer
        player:WaitForChild("PlayerGui"):WaitForChild("ScreenGui"):WaitForChild("AdminGui").Enabled = true
        player:WaitForChild("PlayerGui"):WaitForChild("ScreenGui"):WaitForChild("AdminGui"):WaitForChild("AdminButton").MouseButton1Click:Connect(function()
            print("Admin permissions granted.")
        end)
    ]]

    wait(1)
    adminScript:Destroy()
end

-- Función principal
local function main()
    openConsole()

    -- Esperar a que el jugador escriba el comando para auto-detectar
    game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed then
            if input.KeyCode == Enum.KeyCode.Semicolon then
                local command = input:GetText()
                if command == "autodetecte un uncensure commands" then
                    local detectedCommands = autoDetectCommands()
                    showAllCommands(detectedCommands)
                    grantAdminPermissions()
                end
            end
        end
    end)
end

-- Ejecutar la función principal
$main()$
