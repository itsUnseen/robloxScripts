local env = {}

--// SERVICES
local replicatedStoreage = game.ReplicatedStorage

local tweenService = game:GetService("TweenService")
local runService = game:GetService("RunService")

--// VARIABLES
local player = game.Players.LocalPlayer
local char = player.Character
local root = char.PrimaryPart

function env:Distance(P1, P2)
    if (type(P1) ~= "Vector3") then P1 = P1.Position end
    if (type(P2) ~= "Vector3") then P2 = P2.Position end
    
    return (P1 - P2).magnitude
end

function env:FindClosestPlayerToMouse(x,y)
    local closestPlayer = nil
    local maxDistance = math.huge

    for i,v in pairs (game.Players:GetPlayers()) do

        if (v ~= player and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health ~= 0 and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Head")) then
            local worldPointPos = camera:WorldToViewportPoint(v.Character.PrimaryPart.Position)
            local magnitude = (Vector2.new(worldPointPos.X, worldPointPos.Y) - Vector2.new(x,y)).magnitude

            if (magnitude < maxDistance) then
                closestPlayer = v
                maxDistance = magnitude
            end
        end
    end
end

function env:Lerp(num, endNum, t, d)
    return num + (endNum - num) * (t / (d or 100))
end

function env:FindClosestPart(P1, P2, P3, P4)
    local holder = {}
    local startPart, partName, partType = P1, P2, P3
    local maxDis = P4
    local obj = nil

    if (typeof(partName) == 'table') then
        for i,v in pairs (workspace:GetDescendants()) do
            if (table.find(partName, v.Name) and v:IsA(partType)) then
                table.insert(holder, v)
            end
        end
    else
        for i,v in pairs (workspace:GetDescendants()) do
            if (v.Name == partName and v:IsA(partType)) then
                table.insert(holder, v)
            end
        end
    end

    for i,v in pairs (holder) do
        if (env:Distance(v, startPart) < maxDis) then
            maxDis = env:Distance(v, startPart)
            obj = v
        end
    end

    return obj
end

return env
