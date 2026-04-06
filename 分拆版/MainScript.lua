local success, err = pcall(function()
    task.wait(0.8)
    
    local Players = game:GetService("Players")
    local Player = Players.LocalPlayer
    local UIS = game:GetService("UserInputService")
    local RS = game:GetService("RunService")
    local Http = game:GetService("HttpService")
    
    local Config = {
        GitHubUser = "wownihaohello",
        GitHubRepo = "yinanping",
        Branch = "main",
        UseGitHub = true,
        FallbackToBuiltin = true
    }
    
    local function randomName()
        local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        local name = ""
        for i = 1, math.random(20, 30) do
            name = name .. string.sub(chars, math.random(1, #chars), math.random(1, #chars))
        end
        return name
    end
    
    _G.GameAnalyzer = {
        LogData = {},
        IsIntercepting = false,
        LoadedModules = {}
    }
    
    local allWindows = {}
    local visible = true
    
    local function CreateWindow(title, width, height, x, y)
        local guiName = randomName()
        local MainGui = Instance.new("ScreenGui")
        MainGui.Name = guiName
        MainGui.Parent = game:GetService("CoreGui")
        MainGui.ResetOnSpawn = false
        MainGui.DisplayOrder = math.random(6000, 9000)
        
        local MainFrame = Instance.new("Frame")
        MainFrame.Name = randomName()
        MainFrame.Parent = MainGui
        MainFrame.BackgroundColor3 = Color3.fromRGB(12, 16, 24)
        MainFrame.BorderColor3 = Color3.fromRGB(45, 58, 80)
        MainFrame.BorderSizePixel = 2
        MainFrame.Position = UDim2.new(0, x, 0, y)
        MainFrame.Size = UDim2.new(0, width, 0, height)
        MainFrame.Active = true
        MainFrame.Draggable = true
        
        local TitleBar = Instance.new("Frame")
        TitleBar.Name = randomName()
        TitleBar.Parent = MainFrame
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
        TitleText.Text = title
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
        ContentFrame.Parent = MainFrame
        ContentFrame.BackgroundColor3 = Color3.fromRGB(10, 14, 20)
        ContentFrame.Position = UDim2.new(0, 0, 0, 34)
        ContentFrame.Size = UDim2.new(1, 0, 1, -34)
        
        CloseBtn.MouseButton1Click:Connect(function()
            MainGui:Destroy()
        end)
        
        local winObj = {
            Gui = MainGui,
            Frame = MainFrame,
            Content = ContentFrame,
            Title = TitleText
        }
        table.insert(allWindows, winObj)
        return winObj
    end
    
    local function CreateButton(parent, text, x, y, w, h, callback, color)
        local btn = Instance.new("TextButton")
        btn.Name = randomName()
        btn.Parent = parent
        btn.BackgroundColor3 = color or Color3.fromRGB(35, 55, 80)
        btn.BorderColor3 = Color3.fromRGB(55, 80, 110)
        btn.BorderSizePixel = 1
        btn.Position = UDim2.new(0, x, 0, y)
        btn.Size = UDim2.new(0, w, 0, h)
        btn.Font = Enum.Font.Gotham
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(205, 225, 245)
        btn.TextSize = 12
        btn.AutoButtonColor = false
        btn.MouseButton1Click:Connect(callback)
        return btn
    end
    
    local function CreateLabel(parent, text, x, y, w, h, size, color)
        local lbl = Instance.new("TextLabel")
        lbl.Name = randomName()
        lbl.Parent = parent
        lbl.BackgroundTransparency = 1
        lbl.Position = UDim2.new(0, x, 0, y)
        lbl.Size = UDim2.new(0, w, 0, h)
        lbl.Font = Enum.Font.Gotham
        lbl.Text = text
        lbl.TextColor3 = color or Color3.fromRGB(155, 185, 215)
        lbl.TextSize = size or 11
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextWrapped = true
        return lbl
    end
    
    local function GetGitHubUrl(fileName)
        return string.format("https://raw.githubusercontent.com/%s/%s/%s/%s", Config.GitHubUser, Config.GitHubRepo, Config.Branch, fileName)
    end
    
    local function FetchFromGitHub(fileName)
        if not Config.UseGitHub then
            return nil
        end
        local success, result = pcall(function()
            return Http:GetAsync(GetGitHubUrl(fileName), true)
        end)
        return success and result or nil
    end
    
    local Builtin_Core = [[local Players=game:GetService("Players")local Player=Players.LocalPlayer;local Module={};Module.LogData={};Module.IsIntercepting=false;Module.Connections={};local function randomName()local chars="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"local name=""for i=1,math.random(18,28)do name=name..string.sub(chars,math.random(1,#chars))end;return name end;local function AddToLog(name,path,args)table.insert(Module.LogData,{time=os.date("%H:%M:%S"),name=name,path=path,args=args});if _G.GameAnalyzer then _G.GameAnalyzer.LogData=Module.LogData end end;function Module.StartIntercept()if Module.IsIntercepting then return end;Module.IsIntercepting=true;if hookmetamethod and getnamecallmethod then pcall(function()local oldNamecall=hookmetamethod(game,"__namecall",function(self,...)local method=getnamecallmethod();if method=="FireServer"and self:IsA("RemoteEvent")then AddToLog(self.Name,self:GetFullName(),{...})end;if method=="InvokeServer"and self:IsA("RemoteFunction")then AddToLog("[Invoke] "..self.Name,self:GetFullName(),{...})end;return oldNamecall(self,...)end)end)end;return Module end]]
    
    local Builtin_Explorer = [[local Players=game:GetService("Players")local Player=Players.LocalPlayer;local Module={};local Window=nil;local function randomName()local chars="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"local name=""for i=1,math.random(18,28)do name=name..string.sub(chars,math.random(1,#chars))end;return name end;function Module.Open()if Window and Window.Frame and Window.Frame.Parent then return end;local Gui=Instance.new("ScreenGui")Gui.Name=randomName()Gui.Parent=game:GetService("CoreGui")Gui.ResetOnSpawn=false;local Frame=Instance.new("Frame")Frame.Name=randomName()Frame.Parent=Gui;Frame.BackgroundColor3=Color3.fromRGB(12,16,24);Frame.Size=UDim2.new(0,400,0,300);Frame.Position=UDim2.new(0,400,0,100);Frame.Active=true;Frame.Draggable=true;local Title=Instance.new("TextLabel")Title.Name=randomName()Title.Parent=Frame;Title.BackgroundColor3=Color3.fromRGB(18,26,38);Title.Size=UDim2.new(1,0,0,30);Title.Text="📁 资源管理器";Title.TextColor3=Color3.fromRGB(100,175,235);Title.TextSize=14;local Close=Instance.new("TextButton")Close.Name=randomName()Close.Parent=Frame;Close.Size=UDim2.new(0,50,0,24);Close.Position=UDim2.new(1,-55,0,3);Close.Text="关闭";Close.TextSize=10;Close.MouseButton1Click:Connect(function()Gui:Destroy()end);Window={Gui=Gui,Frame=Frame}end;return Module end]]
    
    local Builtin_PlayerData = [[local Players=game:GetService("Players")local Player=Players.LocalPlayer;local Module={};local Window=nil;local function randomName()local chars="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"local name=""for i=1,math.random(18,28)do name=name..string.sub(chars,math.random(1,#chars))end;return name end;function Module.Open()if Window and Window.Frame and Window.Frame.Parent then return end;local Gui=Instance.new("ScreenGui")Gui.Name=randomName()Gui.Parent=game:GetService("CoreGui")Gui.ResetOnSpawn=false;local Frame=Instance.new("Frame")Frame.Name=randomName()Frame.Parent=Gui;Frame.BackgroundColor3=Color3.fromRGB(12,16,24);Frame.Size=UDim2.new(0,400,0,300);Frame.Position=UDim2.new(0,50,0,400);Frame.Active=true;Frame.Draggable=true;local Title=Instance.new("TextLabel")Title.Name=randomName()Title.Parent=Frame;Title.BackgroundColor3=Color3.fromRGB(18,26,38);Title.Size=UDim2.new(1,0,0,30);Title.Text="👤 玩家数据";Title.TextColor3=Color3.fromRGB(100,175,235);Title.TextSize=14;local Close=Instance.new("TextButton")Close.Name=randomName()Close.Parent=Frame;Close.Size=UDim2.new(0,50,0,24);Close.Position=UDim2.new(1,-55,0,3);Close.Text="关闭";Close.TextSize=10;Close.MouseButton1Click:Connect(function()Gui:Destroy()end);Window={Gui=Gui,Frame=Frame}end;return Module end]]
    
    local Builtin_Logger = [[local Players=game:GetService("Players")local Player=Players.LocalPlayer;local Module={};local Window=nil;local function randomName()local chars="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"local name=""for i=1,math.random(18,28)do name=name..string.sub(chars,math.random(1,#chars))end;return name end;function Module.Open()if Window and Window.Frame and Window.Frame.Parent then return end;local Gui=Instance.new("ScreenGui")Gui.Name=randomName()Gui.Parent=game:GetService("CoreGui")Gui.ResetOnSpawn=false;local Frame=Instance.new("Frame")Frame.Name=randomName()Frame.Parent=Gui;Frame.BackgroundColor3=Color3.fromRGB(12,16,24);Frame.Size=UDim2.new(0,500,0,350);Frame.Position=UDim2.new(0,400,0,50);Frame.Active=true;Frame.Draggable=true;local Title=Instance.new("TextLabel")Title.Name=randomName()Title.Parent=Frame;Title.BackgroundColor3=Color3.fromRGB(18,26,38);Title.Size=UDim2.new(1,0,0,30);Title.Text="📡 拦截日志";Title.TextColor3=Color3.fromRGB(100,175,235);Title.TextSize=14;local Close=Instance.new("TextButton")Close.Name=randomName()Close.Parent=Frame;Close.Size=UDim2.new(0,50,0,24);Close.Position=UDim2.new(1,-55,0,3);Close.Text="关闭";Close.TextSize=10;Close.MouseButton1Click:Connect(function()Gui:Destroy()end);Window={Gui=Gui,Frame=Frame}end;function Module.Refresh()end;return Module end]]
    
    local function LoadScript(name, fileName, builtinCode)
        if _G.GameAnalyzer.LoadedModules[name] then
            return _G.GameAnalyzer.LoadedModules[name]
        end
        
        local code = nil
        
        if Config.UseGitHub then
            code = FetchFromGitHub(fileName)
        end
        
        if not code and Config.FallbackToBuiltin and builtinCode then
            code = builtinCode
        end
        
        if not code then
            return nil
        end
        
        local success, result = pcall(function()
            return loadstring(code)()
        end)
        
        if success then
            _G.GameAnalyzer.LoadedModules[name] = result
            return result
        else
            return nil
        end
    end
    
    local mainWin = CreateWindow("🎮 主脚本", 340, 360, 30, 50)
    
    CreateLabel(mainWin.Content, "📋 功能按钮", 18, 18, 300, 30, 15, Color3.fromRGB(100, 175, 235))
    CreateLabel(mainWin.Content, "⌨️ 快捷键: F4 显示/隐藏", 18, 50, 300, 20, 10)
    
    local InterceptBtn = CreateButton(mainWin.Content, "🎯 开启拦截", 18, 80, 304, 40, function() end, Color3.fromRGB(45, 90, 65))
    
    local CoreModule = LoadScript("Core", "CoreFunctions.lua", Builtin_Core)
    local ExplorerModule = LoadScript("Explorer", "Explorer.lua", Builtin_Explorer)
    local PlayerDataModule = LoadScript("PlayerData", "PlayerData.lua", Builtin_PlayerData)
    local LoggerModule = LoadScript("Logger", "Logger.lua", Builtin_Logger)
    
    CreateButton(mainWin.Content, "👤 玩家数据", 18, 130, 304, 38, function()
        if PlayerDataModule and PlayerDataModule.Open then
            PlayerDataModule.Open()
        end
    end)
    
    CreateButton(mainWin.Content, "📁 资源管理器", 18, 176, 304, 38, function()
        if ExplorerModule and ExplorerModule.Open then
            ExplorerModule.Open()
        end
    end)
    
    CreateButton(mainWin.Content, "📡 查看日志", 18, 222, 304, 38, function()
        if LoggerModule and LoggerModule.Open then
            LoggerModule.Open()
        end
        if LoggerModule and LoggerModule.Refresh then
            LoggerModule.Refresh()
        end
    end)
    
    CreateLabel(mainWin.Content, "📊 说明:\n- 先点「开启拦截」\n- 在游戏里操作\n- 点「查看日志」看源码", 18, 275, 300, 70, 10)
    
    local isIntercepting = false
    
    InterceptBtn.MouseButton1Click:Connect(function()
        if isIntercepting then
            isIntercepting = false
            InterceptBtn.BackgroundColor3 = Color3.fromRGB(45, 90, 65)
            InterceptBtn.Text = "🎯 开启拦截"
            if CoreModule and CoreModule.StopIntercept then
                CoreModule.StopIntercept()
            end
        else
            isIntercepting = true
            InterceptBtn.BackgroundColor3 = Color3.fromRGB(105, 50, 50)
            InterceptBtn.Text = "⏹ 停止拦截"
            if CoreModule and CoreModule.StartIntercept then
                CoreModule.StartIntercept()
            end
        end
    end)
    
    RS.Heartbeat:Connect(function()
        if LoggerModule and LoggerModule.Refresh and isIntercepting then
            if math.random() < 0.1 then
                LoggerModule.Refresh()
            end
        end
    end)
    
    UIS.InputBegan:Connect(function(input, gp)
        if gp then
            return
        end
        if input.KeyCode == Enum.KeyCode.F4 then
            visible = not visible
            for _, win in ipairs(allWindows) do
                if win and win.Frame then
                    win.Frame.Visible = visible
                end
            end
        end
    end)
    
end)

if not success then
    warn(err)
end