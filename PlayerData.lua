local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Module = {}
local Window = nil

local function randomName()
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local name = ""
    for i = 1, math.random(20, 30) do
        name = name .. string.sub(chars, math.random(1, #chars), math.random(1, #chars))
    end
    return name
end

function Module.Open()
    if Window and Window.Frame and Window.Frame.Parent then
        return
    end
    
    local guiName = randomName()
    local Gui = Instance.new("ScreenGui")
    Gui.Name = guiName
    Gui.Parent = game:GetService("CoreGui")
    Gui.ResetOnSpawn = false
    Gui.DisplayOrder = math.random(6000, 9000)
    
    local Frame = Instance.new("Frame")
    Frame.Name = randomName()
    Frame.Parent = Gui
    Frame.BackgroundColor3 = Color3.fromRGB(12, 16, 24)
    Frame.BorderColor3 = Color3.fromRGB(45, 58, 80)
    Frame.BorderSizePixel = 2
    Frame.Position = UDim2.new(0, 30, 0, 430)
    Frame.Size = UDim2.new(0, 480, 0, 500)
    Frame.Active = true
    Frame.Draggable = true
    
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = randomName()
    TitleBar.Parent = Frame
    TitleBar.BackgroundColor3 = Color3.fromRGB(18, 26, 38)
    TitleBar.BorderColor3 = Color3.fromRGB(45, 58, 80)
    TitleBar.BorderSizePixel = 1
    TitleBar.Size = UDim2.new(1, 0, 0, 34)
    
    local TitleText = Instance.new("TextLabel")
    TitleText.Name = randomName()
    TitleText.Parent = TitleBar
    TitleText.BackgroundTransparency = 1
    TitleText.Size = UDim2.new(1, -80, 1, 0)
    TitleText.Position = UDim2.new(0, 15, 0, 0)
    TitleText.Font = Enum.Font.GothamBold
    TitleText.Text = "👤 玩家数据"
    TitleText.TextColor3 = Color3.fromRGB(100, 175, 235)
    TitleText.TextSize = 15
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Name = randomName()
    CloseBtn.Parent = TitleBar
    CloseBtn.BackgroundColor3 = Color3.fromRGB(110, 50, 50)
    CloseBtn.BorderColor3 = Color3.fromRGB(140, 70, 70)
    CloseBtn.BorderSizePixel = 1
    CloseBtn.Size = UDim2.new(0, 65, 0, 24)
    CloseBtn.Position = UDim2.new(1, -72, 0, 5)
    CloseBtn.Font = Enum.Font.Gotham
    CloseBtn.Text = "关闭"
    CloseBtn.TextColor3 = Color3.fromRGB(240, 230, 230)
    CloseBtn.TextSize = 10
    CloseBtn.AutoButtonColor = false
    
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Name = randomName()
    ContentFrame.Parent = Frame
    ContentFrame.BackgroundColor3 = Color3.fromRGB(10, 14, 20)
    ContentFrame.Position = UDim2.new(0, 0, 0, 34)
    ContentFrame.Size = UDim2.new(1, 0, 1, -34)
    
    CloseBtn.MouseButton1Click:Connect(function()
        Gui:Destroy()
    end)
    
    Window = {
        Gui = Gui,
        Frame = Frame,
        Content = ContentFrame
    }
    
    Module.BuildUI(ContentFrame)
end

function Module.BuildUI(parent)
    local RefreshBtn = Instance.new("TextButton")
    RefreshBtn.Name = randomName()
    RefreshBtn.Parent = parent
    RefreshBtn.BackgroundColor3 = Color3.fromRGB(40, 75, 120)
    RefreshBtn.BorderColor3 = Color3.fromRGB(60, 105, 160)
    RefreshBtn.BorderSizePixel = 1
    RefreshBtn.Size = UDim2.new(0, 85, 0, 30)
    RefreshBtn.Position = UDim2.new(0, 15, 0, 15)
    RefreshBtn.Font = Enum.Font.Gotham
    RefreshBtn.Text = "🔄 刷新"
    RefreshBtn.TextColor3 = Color3.fromRGB(210, 230, 250)
    RefreshBtn.TextSize = 11
    RefreshBtn.AutoButtonColor = false
    
    local CodeBox = Instance.new("TextBox")
    CodeBox.Name = randomName()
    CodeBox.Parent = parent
    CodeBox.BackgroundColor3 = Color3.fromRGB(10, 14, 20)
    CodeBox.BorderColor3 = Color3.fromRGB(40, 55, 75)
    CodeBox.BorderSizePixel = 1
    CodeBox.Position = UDim2.new(0, 15, 0, 55)
    CodeBox.Size = UDim2.new(1, -30, 1, -70)
    CodeBox.Font = Enum.Font.Code
    CodeBox.MultiLine = true
    CodeBox.Text = ""
    CodeBox.TextColor3 = Color3.fromRGB(135, 185, 230)
    CodeBox.TextSize = 10
    CodeBox.TextXAlignment = Enum.TextXAlignment.Left
    CodeBox.TextYAlignment = Enum.TextYAlignment.Top
    CodeBox.ClearTextOnFocus = false
    
    local function RefreshPlayerData()
        if not Player then
            return
        end
        
        local code = "-- 玩家数据源码\n"
        code = code .. "-- 生成时间: " .. os.date("%H:%M:%S") .. "\n\n"
        
        code = code .. "-- 基本信息\n"
        code = code .. "local player = game.Players.LocalPlayer\n"
        code = code .. "local playerName = \"" .. Player.Name .. "\"\n"
        code = code .. "local playerId = " .. Player.UserId .. "\n\n"
        
        local char = Player.Character
        if char then
            code = code .. "-- 角色信息\n"
            code = code .. "local character = player.Character\n"
            
            local hum = char:FindFirstChild("Humanoid")
            if hum then
                code = code .. "-- Humanoid\n"
                code = code .. "local humanoid = character:WaitForChild(\"Humanoid\")\n"
                code = code .. "humanoid.Health = " .. hum.Health .. "\n"
                code = code .. "humanoid.MaxHealth = " .. hum.MaxHealth .. "\n"
                code = code .. "humanoid.WalkSpeed = " .. hum.WalkSpeed .. "\n"
                code = code .. "humanoid.JumpPower = " .. hum.JumpPower .. "\n\n"
            end
        end
        
        local leaderstats = Player:FindFirstChild("leaderstats")
        if leaderstats then
            code = code .. "-- Leaderstats\n"
            for _, stat in pairs(leaderstats:GetChildren()) do
                if stat:IsA("ValueBase") then
                    local val = stat.Value
                    if typeof(val) == "string" then
                        val = "\"" .. val .. "\""
                    end
                    code = code .. "local " .. stat.Name .. " = " .. tostring(val) .. "\n"
                end
            end
            code = code .. "\n"
        end
        
        CodeBox.Text = code
    end
    
    RefreshBtn.MouseButton1Click:Connect(RefreshPlayerData)
    RefreshPlayerData()
end

return Module