local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Module = {}
local Window = nil
local LogList = nil
local LogCountLabel = nil

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
    Frame.Position = UDim2.new(0, 400, 0, 50)
    Frame.Size = UDim2.new(0, 600, 0, 460)
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
    TitleText.Text = "📡 拦截日志"
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
    local TopBar = Instance.new("Frame")
    TopBar.Name = randomName()
    TopBar.Parent = parent
    TopBar.BackgroundColor3 = Color3.fromRGB(16, 24, 36)
    TopBar.BorderColor3 = Color3.fromRGB(40, 55, 75)
    TopBar.BorderSizePixel = 1
    TopBar.Size = UDim2.new(1, 0, 0, 42)
    
    local ClearBtn = Instance.new("TextButton")
    ClearBtn.Name = randomName()
    ClearBtn.Parent = TopBar
    ClearBtn.BackgroundColor3 = Color3.fromRGB(95, 55, 55)
    ClearBtn.BorderColor3 = Color3.fromRGB(125, 75, 75)
    ClearBtn.BorderSizePixel = 1
    ClearBtn.Size = UDim2.new(0, 75, 0, 28)
    ClearBtn.Position = UDim2.new(0, 12, 0, 7)
    ClearBtn.Font = Enum.Font.Gotham
    ClearBtn.Text = "🗑️ 清除"
    ClearBtn.TextColor3 = Color3.fromRGB(240, 230, 230)
    ClearBtn.TextSize = 10
    ClearBtn.AutoButtonColor = false
    
    LogCountLabel = Instance.new("TextLabel")
    LogCountLabel.Name = randomName()
    LogCountLabel.Parent = TopBar
    LogCountLabel.BackgroundTransparency = 1
    LogCountLabel.Size = UDim2.new(0, 110, 0, 28)
    LogCountLabel.Position = UDim2.new(1, -120, 0, 7)
    LogCountLabel.Font = Enum.Font.Gotham
    LogCountLabel.Text = "0 条"
    LogCountLabel.TextColor3 = Color3.fromRGB(100, 175, 235)
    LogCountLabel.TextSize = 11
    LogCountLabel.TextXAlignment = Enum.TextXAlignment.Right
    
    LogList = Instance.new("ScrollingFrame")
    LogList.Name = randomName()
    LogList.Parent = parent
    LogList.BackgroundColor3 = Color3.fromRGB(12, 16, 24)
    LogList.BorderColor3 = Color3.fromRGB(40, 55, 75)
    LogList.BorderSizePixel = 1
    LogList.Position = UDim2.new(0, 12, 0, 54)
    LogList.Size = UDim2.new(1, -24, 1, -66)
    LogList.CanvasSize = UDim2.new(0, 0, 0, 0)
    LogList.ScrollBarThickness = 10
    LogList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    
    local Layout = Instance.new("UIListLayout")
    Layout.Name = randomName()
    Layout.Parent = LogList
    Layout.Padding = UDim.new(0, 4)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    
    ClearBtn.MouseButton1Click:Connect(function()
        if _G.GameAnalyzer then
            _G.GameAnalyzer.LogData = {}
        end
        for _, child in pairs(LogList:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
        if LogCountLabel then
            LogCountLabel.Text = "0 条"
        end
    end)
    
    Module.Refresh()
end

function Module.AddLogItem(data, index)
    if not LogList then
        return
    end
    
    local timeStr = data.time
    local name = data.name
    local path = data.path
    local args = data.args
    
    local source = "-- " .. timeStr .. " | FireServer | " .. name .. "\n"
    source = source .. "-- 路径: " .. path .. "\n\n"
    
    if args and #args > 0 then
        source = source .. "local args = {\n"
        for i, arg in ipairs(args) do
            local t = typeof(arg)
            local s = tostring(arg)
            
            if t == "string" then
                s = "\"" .. s:gsub("\\", "\\\\"):gsub("\"", "\\\""):gsub("\n", "\\n"):gsub("\t", "\\t") .. "\""
            elseif t == "number" then
                s = s
            elseif t == "boolean" then
                s = tostring(s)
            elseif t == "Instance" then
                local ok, n = pcall(function() return arg:GetFullName() end)
                s = ok and ("game." .. n) or "[Instance]"
            elseif t == "Vector3" then
                s = tostring(s)
            elseif t == "CFrame" then
                s = tostring(s)
            elseif t == "table" then
                s = "{ ... }"
            else
                s = "-- [" .. t .. "] " .. s
            end
            
            source = source .. "    [" .. i .. "] = " .. s .. ",\n"
        end
        source = source .. "}\n\n"
        
        source = source .. "local remote = game." .. path .. "\n"
        source = source .. "remote:FireServer("
        for i = 1, #args do
            if i > 1 then
                source = source .. ", "
            end
            source = source .. "args[" .. i .. "]"
        end
        source = source .. ")"
    else
        source = source .. "local remote = game." .. path .. "\n"
        source = source .. "remote:FireServer()"
    end
    
    local item = Instance.new("Frame")
    item.Name = randomName()
    item.Parent = LogList
    item.BackgroundColor3 = Color3.fromRGB(18, 24, 34)
    item.BorderColor3 = Color3.fromRGB(40, 55, 75)
    item.BorderSizePixel = 1
    item.Size = UDim2.new(1, 0, 0, 32)
    item.LayoutOrder = index * 10000 + math.random(1, 9999)
    
    local expandBtn = Instance.new("TextButton")
    expandBtn.Name = randomName()
    expandBtn.Parent = item
    expandBtn.BackgroundTransparency = 1
    expandBtn.Size = UDim2.new(0, 28, 1, 0)
    expandBtn.Position = UDim2.new(0, 5, 0, 0)
    expandBtn.Font = Enum.Font.GothamBold
    expandBtn.Text = "+"
    expandBtn.TextColor3 = Color3.fromRGB(115, 185, 245)
    expandBtn.TextSize = 16
    expandBtn.AutoButtonColor = false
    
    local title = Instance.new("TextLabel")
    title.Name = randomName()
    title.Parent = item
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, -130, 1, 0)
    title.Position = UDim2.new(0, 36, 0, 0)
    title.Font = Enum.Font.Code
    title.Text = "[" .. timeStr .. "] " .. name
    title.TextColor3 = Color3.fromRGB(130, 195, 255)
    title.TextSize = 11
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ClipsDescendants = true
    
    local argCount = Instance.new("TextLabel")
    argCount.Name = randomName()
    argCount.Parent = item
    argCount.BackgroundTransparency = 1
    argCount.Size = UDim2.new(0, 85, 1, 0)
    argCount.Position = UDim2.new(1, -90, 0, 0)
    argCount.Font = Enum.Font.Code
    argCount.Text = "[" .. (args and #args or 0) .. "]"
    argCount.TextColor3 = Color3.fromRGB(100, 165, 220)
    argCount.TextSize = 10
    argCount.TextXAlignment = Enum.TextXAlignment.Right
    
    local sourceContainer = Instance.new("Frame")
    sourceContainer.Name = randomName()
    sourceContainer.Parent = LogList
    sourceContainer.BackgroundTransparency = 1
    sourceContainer.Size = UDim2.new(1, 0, 0, 0)
    sourceContainer.Visible = false
    sourceContainer.LayoutOrder = item.LayoutOrder + 1
    
    local sourceTop = Instance.new("Frame")
    sourceTop.Name = randomName()
    sourceTop.Parent = sourceContainer
    sourceTop.BackgroundColor3 = Color3.fromRGB(14, 20, 32)
    sourceTop.BorderColor3 = Color3.fromRGB(40, 55, 75)
    sourceTop.BorderSizePixel = 1
    sourceTop.Size = UDim2.new(1, 0, 0, 28)
    
    local sourceTitle = Instance.new("TextLabel")
    sourceTitle.Name = randomName()
    sourceTitle.Parent = sourceTop
    sourceTitle.BackgroundTransparency = 1
    sourceTitle.Size = UDim2.new(1, -108, 1, 0)
    sourceTitle.Position = UDim2.new(0, 12, 0, 0)
    sourceTitle.Font = Enum.Font.GothamBold
    sourceTitle.Text = "📜 源码（可复制）"
    sourceTitle.TextColor3 = Color3.fromRGB(100, 175, 235)
    sourceTitle.TextSize = 11
    sourceTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    local copyBtn = Instance.new("TextButton")
    copyBtn.Name = randomName()
    copyBtn.Parent = sourceTop
    copyBtn.BackgroundColor3 = Color3.fromRGB(40, 75, 120)
    copyBtn.BorderColor3 = Color3.fromRGB(60, 105, 160)
    copyBtn.BorderSizePixel = 1
    copyBtn.Size = UDim2.new(0, 95, 0, 22)
    copyBtn.Position = UDim2.new(1, -100, 0, 3)
    copyBtn.Font = Enum.Font.Gotham
    copyBtn.Text = "📋 复制"
    copyBtn.TextColor3 = Color3.fromRGB(210, 230, 250)
    copyBtn.TextSize = 10
    copyBtn.AutoButtonColor = false
    
    local sourceBox = Instance.new("TextBox")
    sourceBox.Name = randomName()
    sourceBox.Parent = sourceContainer
    sourceBox.BackgroundColor3 = Color3.fromRGB(8, 12, 18)
    sourceBox.BorderColor3 = Color3.fromRGB(40, 55, 75)
    sourceBox.BorderSizePixel = 1
    sourceBox.Position = UDim2.new(0, 0, 0, 28)
    sourceBox.Size = UDim2.new(1, 0, 0, 170)
    sourceBox.Font = Enum.Font.Code
    sourceBox.MultiLine = true
    sourceBox.Text = source
    sourceBox.TextColor3 = Color3.fromRGB(135, 185, 230)
    sourceBox.TextSize = 10
    sourceBox.TextXAlignment = Enum.TextXAlignment.Left
    sourceBox.TextYAlignment = Enum.TextYAlignment.Top
    sourceBox.ClearTextOnFocus = false
    
    sourceContainer.Size = UDim2.new(1, 0, 0, 198)
    
    local isExpanded = false
    expandBtn.MouseButton1Click:Connect(function()
        isExpanded = not isExpanded
        expandBtn.Text = isExpanded and "-" or "+"
        sourceContainer.Visible = isExpanded
    end)
    
    copyBtn.MouseButton1Click:Connect(function()
        print("\n" .. source .. "\n")
    end)
end

function Module.Refresh()
    if not LogList or not _G.GameAnalyzer then
        return
    end
    
    for _, child in pairs(LogList:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    local logData = _G.GameAnalyzer.LogData or {}
    for i, data in ipairs(logData) do
        Module.AddLogItem(data, i)
    end
    
    if LogCountLabel then
        LogCountLabel.Text = tostring(#logData) .. " 条"
    end
end

return Module