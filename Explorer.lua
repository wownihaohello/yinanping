local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Module = {}
local Window = nil
local SelectedObj = nil
local ExpandedState = {}

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
    Frame.Position = UDim2.new(0, 1020, 0, 50)
    Frame.Size = UDim2.new(0, 560, 0, 480)
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
    TitleText.Text = "📁 资源管理器"
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
    RefreshBtn.Size = UDim2.new(0, 80, 0, 30)
    RefreshBtn.Position = UDim2.new(0, 15, 0, 15)
    RefreshBtn.Font = Enum.Font.Gotham
    RefreshBtn.Text = "🔄 刷新"
    RefreshBtn.TextColor3 = Color3.fromRGB(210, 230, 250)
    RefreshBtn.TextSize = 11
    RefreshBtn.AutoButtonColor = false
    
    local SelectedLabel = Instance.new("TextLabel")
    SelectedLabel.Name = randomName()
    SelectedLabel.Parent = parent
    SelectedLabel.BackgroundTransparency = 1
    SelectedLabel.Size = UDim2.new(1, -110, 0, 30)
    SelectedLabel.Position = UDim2.new(0, 100, 0, 15)
    SelectedLabel.Font = Enum.Font.Gotham
    SelectedLabel.Text = "选择: (无)"
    SelectedLabel.TextColor3 = Color3.fromRGB(145, 175, 205)
    SelectedLabel.TextSize = 10
    SelectedLabel.TextXAlignment = Enum.TextXAlignment.Left
    SelectedLabel.ClipsDescendants = true
    
    local TreeScroll = Instance.new("ScrollingFrame")
    TreeScroll.Name = randomName()
    TreeScroll.Parent = parent
    TreeScroll.BackgroundColor3 = Color3.fromRGB(10, 14, 20)
    TreeScroll.BorderColor3 = Color3.fromRGB(40, 55, 75)
    TreeScroll.BorderSizePixel = 1
    TreeScroll.Position = UDim2.new(0, 15, 0, 55)
    TreeScroll.Size = UDim2.new(1, -30, 1, -70)
    TreeScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    TreeScroll.ScrollBarThickness = 10
    TreeScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    
    local TreeLayout = Instance.new("UIListLayout")
    TreeLayout.Name = randomName()
    TreeLayout.Parent = TreeScroll
    TreeLayout.Padding = UDim.new(0, 2)
    TreeLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local selectedObj = nil
    local expandedState = {}
    
    local function AddTreeItem(obj, depth)
        if not obj or not obj.Parent then
            return
        end
        
        local isFolder = obj:IsA("Folder") or obj:IsA("Model") or obj:IsA("Workspace") or
                      obj:IsA("ReplicatedStorage") or obj:IsA("Players") or
                      obj:IsA("StarterPlayer") or obj:IsA("ReplicatedFirst")
        
        local isImportant = obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") or
                          obj.Name:lower():find("remote") or obj.Name:lower():find("event") or
                          obj.Name:lower():find("attack") or obj.Name:lower():find("damage")
        
        local item = Instance.new("Frame")
        item.Name = randomName()
        item.Parent = TreeScroll
        item.BackgroundColor3 = isImportant and Color3.fromRGB(20, 32, 48) or Color3.fromRGB(14, 20, 32)
        item.BorderColor3 = isImportant and Color3.fromRGB(50, 75, 105) or Color3.fromRGB(38, 52, 72)
        item.BorderSizePixel = 1
        item.Size = UDim2.new(1, 0, 0, 26)
        item.LayoutOrder = depth * 100000 + math.random(1, 99999)
        
        local indent = depth * 20
        
        local expandBtn = nil
        local childContainer = nil
        
        if isFolder then
            expandBtn = Instance.new("TextButton")
            expandBtn.Name = randomName()
            expandBtn.Parent = item
            expandBtn.BackgroundTransparency = 1
            expandBtn.Size = UDim2.new(0, 24, 1, 0)
            expandBtn.Position = UDim2.new(0, indent + 3, 0, 0)
            expandBtn.Font = Enum.Font.GothamBold
            expandBtn.Text = "+"
            expandBtn.TextColor3 = Color3.fromRGB(110, 175, 235)
            expandBtn.TextSize = 15
            expandBtn.AutoButtonColor = false
            
            childContainer = Instance.new("Frame")
            childContainer.Name = randomName()
            childContainer.Parent = TreeScroll
            childContainer.BackgroundTransparency = 1
            childContainer.Size = UDim2.new(1, 0, 0, 0)
            childContainer.Visible = false
            childContainer.LayoutOrder = item.LayoutOrder + 1
        end
        
        local nameBtn = Instance.new("TextButton")
        nameBtn.Name = randomName()
        nameBtn.Parent = item
        nameBtn.BackgroundTransparency = 1
        nameBtn.Size = UDim2.new(1, -indent - (isFolder and 30 or 4) - 6, 1, 0)
        nameBtn.Position = UDim2.new(0, indent + (isFolder and 30 or 4), 0, 0)
        nameBtn.Font = Enum.Font.Code
        nameBtn.Text = (isImportant and "⭐ " or "") .. obj.Name .. " [" .. obj.ClassName .. "]"
        nameBtn.TextColor3 = isImportant and Color3.fromRGB(105, 185, 240) or Color3.fromRGB(150, 180, 210)
        nameBtn.TextSize = 10
        nameBtn.TextXAlignment = Enum.TextXAlignment.Left
        nameBtn.ClipsDescendants = true
        nameBtn.AutoButtonColor = false
        
        nameBtn.MouseButton1Click:Connect(function()
            selectedObj = obj
            SelectedLabel.Text = "选择: " .. obj:GetFullName()
        end)
        
        if expandBtn and childContainer then
            expandBtn.MouseButton1Click:Connect(function()
                local wasExpanded = expandedState[obj]
                expandedState[obj] = not wasExpanded
                expandBtn.Text = expandedState[obj] and "-" or "+"
                
                if expandedState[obj] then
                    childContainer:ClearAllChildren()
                    local children = obj:GetChildren()
                    table.sort(children, function(a, b)
                        local aF = a:IsA("Folder") or a:IsA("Model")
                        local bF = b:IsA("Folder") or b:IsA("Model")
                        if aF and not bF then
                            return true
                        end
                        if not aF and bF then
                            return false
                        end
                        return a.Name < b.Name
                    end)
                    
                    local totalH = 0
                    for _, child in ipairs(children) do
                        if not (child.Name:lower():find("terrain") or child.Name:lower():find("camera")) then
                            local success, result = pcall(function()
                                local oldCount = #childContainer:GetChildren()
                                
                                local temp = Instance.new("Frame")
                                temp.Parent = childContainer
                                
                                AddTreeItem(child, depth + 1)
                                
                                temp:Destroy()
                                
                                for i = oldCount + 1, #childContainer:GetChildren() do
                                    local c = childContainer:GetChildren()[i]
                                    if c and c:IsA("Frame") then
                                        totalH = totalH + c.Size.Y.Offset + 2
                                    end
                                end
                            end)
                        end
                    end
                    childContainer.Size = UDim2.new(1, 0, 0, totalH)
                end
                
                childContainer.Visible = expandedState[obj]
            end)
        end
    end
    
    local function RefreshTree()
        selectedObj = nil
        expandedState = {}
        SelectedLabel.Text = "选择: (无)"
        
        for _, child in pairs(TreeScroll:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
        
        local roots = {
            {name = "Workspace", obj = workspace},
            {name = "ReplicatedStorage", obj = game:GetService("ReplicatedStorage")},
            {name = "Players", obj = game:GetService("Players")},
            {name = "StarterPlayer", obj = game:GetService("StarterPlayer")},
            {name = "ReplicatedFirst", obj = game:GetService("ReplicatedFirst")}
        }
        
        for _, root in ipairs(roots) do
            AddTreeItem(root.obj, 0)
        end
    end
    
    RefreshBtn.MouseButton1Click:Connect(RefreshTree)
    RefreshTree()
end

return Module