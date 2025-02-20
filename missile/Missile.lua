local Gui = script.Parent.Parent
local Events = Gui.Events

local Ts = game:GetService("TweenService")
local Waiting = false
local Destruction = false

local Missile
local Tween_body
local Tween_goal_up
local Tween_Missile
local Tween_Missile_2
local Primary

Events.Coordinates.OnServerEvent:Connect(function(Player,Coordinates)
	for i,v in ipairs(workspace:GetChildren()) do
		if v.Name == "Missile_launcher" then
			local Distance = (Player.Character.HumanoidRootPart.Position - v.Body.PrimaryPart.Position).Magnitude
			local Distance_2 = (v.PrimaryPart.Position - Coordinates).Magnitude
			Primary = v.Body.PrimaryPart
			local Primary_Missile = v.Gun.PrimaryPart

			if Distance <= 10 and Distance_2 > 300 and not Waiting and v.Config.Ammos.Value >= 1 then
				Waiting = true
				v.Config.Ammos.Value -= 1
				v.Body.PrimaryPart.Move:Play()

				local Goal_Body = {
					CFrame = CFrame.new(Primary.Position, Vector3.new(Coordinates.X,math.rad(Coordinates.Y),Coordinates.Z))
				}

				local Goal_Missile = {
					CFrame = CFrame.new(Primary_Missile.Position, Vector3.new(Coordinates.X,math.rad(Coordinates.Y),Coordinates.Z))
				}

				local Goal_Missile_2 = {
					CFrame = CFrame.new(Primary_Missile.Position, Vector3.new(Coordinates.X,math.rad(Coordinates.Y),Coordinates.Z)) * CFrame.Angles(math.rad(45),0,0)
				}

				Tween_body = Ts:Create(Primary, TweenInfo.new(v.Body.PrimaryPart.Move.TimeLength - 1.5), Goal_Body)
				Tween_Missile = Ts:Create(Primary_Missile,TweenInfo.new(v.Body.PrimaryPart.Move.TimeLength - 1.5), Goal_Missile)
				Tween_Missile_2 = Ts:Create(Primary_Missile,TweenInfo.new(v.Body.PrimaryPart.Move.TimeLength -1), Goal_Missile_2)



				Tween_body:Play()
				Tween_Missile:Play()

				Tween_body.Completed:Connect(function()
					Tween_Missile_2:Play()
					v.Body.PrimaryPart.Move:Play()
				end)

				Tween_Missile_2.Completed:Connect(function()
					task.wait(2)

					local Missile_clone = v.Gun.Missile:Clone()
					Missile_clone.Parent = workspace
					Missile_clone.Anchored = true
					Missile_clone.CanCollide = false
					Missile_clone.Attachment.Effect.Enabled = true
					Missile_clone.Attachment.Smoke_1.Enabled = true
					Missile_clone.Attachment.Smoke_2.Enabled = true
					Missile_clone.Attachment.Smoke_3.Enabled = true
					Missile_clone.Fire:Play()
					Missile_clone.Stage_1:Play()
					Missile_clone.Flying:Play()
					v.Gun.Missile.Transparency = 1

					Missile = Missile_clone
					local Goal_Up = {
						Position = Vector3.new(Coordinates.X, Coordinates.Y + (Missile_clone.Position - Coordinates).Magnitude - 10, Coordinates.Z)
					}

					local Goal_Down = {
						Position = Vector3.new(Coordinates.X, Coordinates.Y, Coordinates.Z),
					}

					task.wait(0.1)
					local Meth = (Missile_clone.Position - Coordinates).Magnitude

					Tween_goal_up = Ts:Create(Missile_clone,TweenInfo.new(Meth / 200,Enum.EasingStyle.Linear),Goal_Up)
					local Tween_goal_down = Ts:Create(Missile_clone,TweenInfo.new(Meth / 200,Enum.EasingStyle.Linear), Goal_Down)
					Tween_goal_up:Play()

					Tween_goal_up.Completed:Connect(function()
						Missile_clone.Orientation = Vector3.new(-90,0,0)
						task.wait(0)

						Tween_goal_down:Play()
					end)
					
					game:GetService("Debris"):AddItem(Missile_clone,30)
					
					Tween_goal_down.Completed:Connect(function()
						Missile_clone.Fire:Stop()
						Missile_clone.Stage_1:Stop()
						Missile_clone.Flying:Stop()

						Missile_clone.Explosion:Play()
						Missile_clone.Transparency = 1

						Missile_clone.Att_explosion.dp.Enabled = true
						Missile_clone.Attachment.Effect.Enabled = false
						Missile_clone.Attachment.Smoke_1.Enabled = false
						Missile_clone.Attachment.Smoke_2.Enabled = false
						Missile_clone.Attachment.Smoke_3.Enabled = false

						task.wait(0.25)

						Missile_clone.Att_explosion.dp.Enabled = false
						
					end)
					
					task.wait(5)
					Waiting = false
					
					if not Destruction and v.Config.Ammos.Value > 0 then
						v.Gun.Missile.Transparency = 0
					else
						v.Gun.Missile.Transparency = 1
						v.Gun.Missile.CanCollide = false
					end
				end)
			end
		end
		
		if v:FindFirstChild("Body_welds") and not Destruction then
			if Tween_body and Tween_Missile and Tween_Missile_2 and #v.Body_welds:GetChildren() < 1 then
				Destruction = true
								
				Tween_body:Destroy()
				Tween_Missile:Destroy()
				Tween_Missile_2:Destroy()

				if Tween_goal_up then
					Tween_goal_up:Pause()

					if v.Body.Primary.CFrame == CFrame.new(Primary.Position, Vector3.new(Coordinates.X,math.rad(Coordinates.Y),Coordinates.Z)) then
						Tween_goal_up:Play()
					end
				end
			end
			
			if v then
				v.Body_welds.ChildRemoved:Connect(function()
					v.Body.Primary.Move.Volume = 0

					task.wait(5)

					v:Destroy()
				end)
			end
		end
	end
end)

Gui.Frame.Close.MouseButton1Click:Connect(function()
	Gui.Enabled = false
end)