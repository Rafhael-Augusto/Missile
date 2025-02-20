local Gui = script.Parent.Parent
local Events = Gui.Events

local Coordinates_button = Gui.Frame.Coordinates
local Launch_button = Gui.Frame.Launch

Launch_button.MouseButton1Click:Connect(function()
	local Split = string.split(Coordinates_button.Text)
	local Vector =  Vector3.new(Split[1],Split[2],Split[3])
	
	Events.Coordinates:FireServer(Vector)
end)