local players = game:GetService('Players')
local workspace = game:GetService('Workspace')
local RunService = game:GetService('RunService')
local TeleportService = game:GetService('TeleportService')
local plr = players.LocalPlayer

--[[ Preload ]] do
    game:GetService("LogService").MessageOut:Connect(function(Message)
        if string.find(Message, "Server Kick Message:") then
            TeleportService:Teleport(game.PlaceId)
        end
    end)

    local old; old = hookmetamethod(game, '__namecall', function(self, ...) 
        local args = {...}

        if (getnamecallmethod() == "Kick" or getnamecallmethod() == "kick") then
            return
        end

        if getnamecallmethod() == 'InvokeServer' and self.Name == 'check' then
            return
        end

        if (getnamecallmethod() == 'FireServer' and args[1] == 'SprintBurst' or args[1] == 'KickBack') then 
            return 
        end

        return old(self, ...)
    end)

    plr.DevCameraOcclusionMode = "Invisicam"
    if plr and plr.PlayerScripts and plr.PlayerScripts:FindFirstChild('Effects') then
        plr.PlayerScripts.Effects.Disabled = true
        plr.PlayerScripts.Effects:Destroy()
    end
end

local moveto, click_button, get_quest, closest_npc, gotomob, attack, antifall, nocooldown, kill_fiends; do
    moveto = function(pos, offset)
        if plr.Character and plr.Character:FindFirstChild('HumanoidRootPart') then
            local offset = offset or CFrame.new(0, 0, 0);

            local path = game:GetService("PathfindingService"):CreatePath()
            path:ComputeAsync(plr.Character.HumanoidRootPart.Position, (((typeof(pos) == 'CFrame' and pos) or (typeof(pos) == 'Vector3' and CFrame.new(pos)) or pos.CFrame) * offset))
            local points = path:GetWaypoints()
            local count = 1
            local counterpoints = #points
            local countvalue = 1
            for i = 1, counterpoints do
                local ts = game:GetService("TweenService")
                local tweenInfo = TweenInfo.new(0.03)
                local t = ts:Create(plr.Character.HumanoidRootPart, tweenInfo, {
                    CFrame = CFrame.new(points[i].Position + Vector3.new(0,3,0))
                })
                t:Play()
                countvalue = countvalue + 1
                task.wait(0.06)
            end
        end
    end;

    click_button = function(button)
        game:GetService("VirtualInputManager"):SendMouseButtonEvent(button.AbsolutePosition.X + button.AbsoluteSize.X / 2, button.AbsolutePosition.Y + 50, 0, true, button, 1);
        game:GetService("VirtualInputManager"):SendMouseButtonEvent(button.AbsolutePosition.X + button.AbsoluteSize.X / 2, button.AbsolutePosition.Y + 50, 0, false, button, 1)
    end

    get_quest = function()
        if not plr.PlayerGui:FindFirstChild('Quest') then
            repeat task.wait()
                repeat task.wait()
                    moveto(game:GetService("Workspace").DialogNPCs["grown up boy"].HumanoidRootPart, CFrame.new(0,0,2))
                    fireproximityprompt(game:GetService("Workspace").DialogNPCs["grown up boy"].ProximityPrompt)
                until plr:FindFirstChild('PlayerGui') and plr.PlayerGui:FindFirstChild('ProximityPrompts') and plr.PlayerGui.ProximityPrompts:FindFirstChild('Prompt') and plr.PlayerGui.ProximityPrompts.Prompt:FindFirstChild('TextButton') or plr.PlayerGui:FindFirstChild('Quest')
                
                if plr:FindFirstChild('PlayerGui') and plr.PlayerGui:FindFirstChild('dialogGUI') then
                    click_button(plr.PlayerGui.dialogGUI.f.sf.option.text)
                end
            until plr and plr.PlayerGui:FindFirstChild('Quest')
        elseif plr.PlayerGui.Quest.Completed.Visible == true then
            click_button(plr.PlayerGui.Quest.Completed.Yes)
        end
    end

    closest_npc = function()
        local dist = math.huge
        for i,v in pairs(game:GetService("Workspace").Living:GetChildren()) do
            if not (string.find(v.Name, 'Fiend') and v.Humanoid.Health > 0 and plr.Character:FindFirstChild('HumanoidRootPart') and (v.PrimaryPart.Position - plr.Character.HumanoidRootPart.Position).Magnitude < dist) then continue end
            
            return v
        end
    end

    gotomob = function(mob)
        if (not mob) then return end
        moveto(CFrame.new(mob.PrimaryPart.Position + Vector3.new(0, 0, 5), mob.PrimaryPart.Position))
        if (isnetworkowner(mob.PrimaryPart)) then
            for i,v in pairs(mob:GetChildren()) do
                if not v:IsA('BasePart') then continue end
                
                v.Size = Vector3.new(25, 25, 25)
                v.CanCollide = false
                v.Transparency = 1
                
                if v.Name == 'Head' then
                    for i,v2 in pairs(v:GetChildren()) do
                        v2:Destroy()
                    end
                end
            end
        end
    end

    attack = function(mob)
        if plr.Character and plr.Character:FindFirstChild('HumanoidRootPart') and mob and mob.PrimaryPart and (mob.PrimaryPart.Position - plr.Character.HumanoidRootPart.Position).Magnitude < 30 then
            game:GetService("ReplicatedStorage").events.remote:FireServer("NormalAttack");
            game:GetService("ReplicatedStorage").events.remote:FireServer("StrongAttack");
        end
    end

    antifall = function()
        if plr.Character and plr.Character:FindFirstChild('HumanoidRootPart') then
            plr.Character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
        end
    end

    nocooldown = function()
        if plr and plr.Character and plr.Character:FindFirstChild('Weapon') and plr.Character.Weapon.weapon.Handle.Enabled == true then
            plr.Character.Weapon.weapon.Handle.Enabled = false
        end
    end

    kill_fiends = function()
        local closest_npc = closest_npc()
        repeat task.wait()
            antifall()
            nocooldown()
            get_quest()
            gotomob(closest_npc)
            attack(closest_npc)
        until not closest_npc or not closest_npc.PrimaryPart or (closest_npc:FindFirstChild('Humanoid') and closest_npc.Humanoid.Health == 0)
    end
end

--[[ Main ]] do
    noclip = function()
        Clip = false
        local function Nocl()
            if Clip == false and game.Players.LocalPlayer.Character ~= nil then
                for _,v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                    if v:IsA('BasePart') and v.CanCollide and v.Name ~= floatName then
                        v.CanCollide = false
                    end
                end
            end
            wait(0.21)
        end
        Noclip = RunService.Stepped:Connect(Nocl)
    end

    noclip()

    while task.wait() do
        kill_fiends()
    end
end
