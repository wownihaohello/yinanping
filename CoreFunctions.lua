local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Module = {}
Module.LogData = {}
Module.IsIntercepting = false
Module.Connections = {}

local function randomName()
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local name = ""
    for i = 1, math.random(20, 30) do
        name = name .. string.sub(chars, math.random(1, #chars), math.random(1, #chars))
    end
    return name
end

local function AddToLog(name, path, args)
    table.insert(Module.LogData, {
        time = os.date("%H:%M:%S"),
        name = name,
        path = path,
        args = args
    })
    
    if _G.GameAnalyzer then
        _G.GameAnalyzer.LogData = Module.LogData
    end
end

function Module.StartIntercept()
    if Module.IsIntercepting then
        return
    end
    Module.IsIntercepting = true
    
    local methodsTried = 0
    local methodsWorked = 0
    
    if hookmetamethod and getnamecallmethod then
        methodsTried = methodsTried + 1
        local success, err = pcall(function()
            local oldNamecall
            oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
                local method = getnamecallmethod()
                
                if method == "FireServer" and self:IsA("RemoteEvent") then
                    local args = {...}
                    AddToLog(self.Name, self:GetFullName(), args)
                end
                
                if method == "InvokeServer" and self:IsA("RemoteFunction") then
                    local args = {...}
                    AddToLog("[Invoke] " .. self.Name, self:GetFullName(), args)
                end
                
                return oldNamecall(self, ...)
            end)
            methodsWorked = methodsWorked + 1
        end)
    end
    
    if hookfunction then
        methodsTried = methodsTried + 1
        local success, err = pcall(function()
            local originalFires = {}
            for _, obj in pairs(game:GetDescendants()) do
                if obj:IsA("RemoteEvent") then
                    originalFires[obj] = obj.FireServer
                    obj.FireServer = function(self, ...)
                        local args = {...}
                        AddToLog(self.Name, self:GetFullName(), args)
                        return originalFires[obj](self, ...)
                    end
                end
            end
            methodsWorked = methodsWorked + 1
        end)
    end
    
    methodsTried = methodsTried + 1
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            local success, conn = pcall(function()
                return obj.OnClientEvent:Connect(function(...)
                    local args = {...}
                    AddToLog("[C->S] " .. obj.Name, obj:GetFullName(), args)
                end)
            end)
            if success and conn then
                table.insert(Module.Connections, conn)
            end
        end
    end
    
    if #Module.Connections > 0 then
        methodsWorked = methodsWorked + 1
    end
end

function Module.StopIntercept()
    if not Module.IsIntercepting then
        return
    end
    Module.IsIntercepting = false
    
    for _, conn in ipairs(Module.Connections) do
        pcall(function()
            conn:Disconnect()
        end)
    end
    Module.Connections = {}
end

function Module.GetLogData()
    return Module.LogData
end

function Module.ClearLog()
    Module.LogData = {}
end

return Module