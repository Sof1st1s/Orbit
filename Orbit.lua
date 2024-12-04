-- Variables for player and services
local player = game.Players.LocalPlayer
local runService = game:GetService("RunService")

-- Create GUI elements
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
local frame = Instance.new("Frame")
local inputBox = Instance.new("TextBox")
local orbitButton = Instance.new("TextButton")
local uiCornerFrame = Instance.new("UICorner")
local uiCornerInput = Instance.new("UICorner")
local uiCornerButton = Instance.new("UICorner")
local uiStrokeFrame = Instance.new("UIStroke")

-- Configure ScreenGui
screenGui.Name = "OrbitGUI"

-- Configure Frame
frame.Name = "MainFrame"
frame.Parent = screenGui
frame.Size = UDim2.new(0, 250, 0, 150)
frame.Position = UDim2.new(0.5, -125, 0.5, -75)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
uiCornerFrame.Parent = frame
uiStrokeFrame.Parent = frame
uiStrokeFrame.Color = Color3.fromRGB(255, 255, 255)
uiStrokeFrame.Thickness = 2

-- Configure Input Box
inputBox.Name = "InputBox"
inputBox.Parent = frame
inputBox.Size = UDim2.new(0, 200, 0, 50)
inputBox.Position = UDim2.new(0.5, -100, 0.1, 0)
inputBox.PlaceholderText = "Enter Player Name"
inputBox.Text = ""
inputBox.TextSize = 20
inputBox.Font = Enum.Font.Gotham
inputBox.TextColor3 = Color3.fromRGB(0, 0, 0)
inputBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
uiCornerInput.Parent = inputBox

-- Configure Orbit Button
orbitButton.Name = "OrbitButton"
orbitButton.Parent = frame
orbitButton.Size = UDim2.new(0, 200, 0, 50)
orbitButton.Position = UDim2.new(0.5, -100, 0.6, 0)
orbitButton.Text = "Start Orbit"
orbitButton.TextSize = 20
orbitButton.Font = Enum.Font.GothamBold
orbitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
orbitButton.BackgroundColor3 = Color3.fromRGB(30, 144, 255)
uiCornerButton.Parent = orbitButton

-- Drag functionality for Frame
local isDragging = false
local dragStart, startPos

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = true
        dragStart = input.Position
        startPos = frame.Position
    end
end)

frame.InputChanged:Connect(function(input)
    if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

frame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = false
    end
end)

-- Variables for orbit
local orbiting = false
local orbitConnection

-- Function to start orbiting
local function startOrbit(targetName)
    local targetPlayer = game.Players:FindFirstChild(targetName)
    if not targetPlayer or not targetPlayer.Character then
        orbitButton.Text = "Player Not Found!"
        wait(2)
        orbitButton.Text = "Start Orbit"
        return
    end

    local targetHead = targetPlayer.Character:FindFirstChild("Head")
    if not targetHead then
        orbitButton.Text = "No Head Found!"
        wait(2)
        orbitButton.Text = "Start Orbit"
        return
    end

    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:FindFirstChild("Humanoid")
    local rootPart = character:WaitForChild("HumanoidRootPart")
    local radius = 4
    local speed = 10
    local angle = 0

    if humanoid then humanoid.Sit = true end

    orbiting = true
    orbitConnection = runService.Heartbeat:Connect(function(deltaTime)
        if not orbiting then
            orbitConnection:Disconnect()
            rootPart.Velocity = Vector3.zero
            rootPart.RotVelocity = Vector3.zero
            humanoid.PlatformStand = true

            wait(1) -- Freeze for 1 second
            humanoid.PlatformStand = false
            humanoid.Sit = false
            return
        end

        angle = angle + speed * deltaTime
        local offsetX = math.cos(angle) * radius
        local offsetZ = math.sin(angle) * radius
        rootPart.CFrame = CFrame.new(targetHead.Position + Vector3.new(offsetX, 3, offsetZ))
    end)
end

-- Button click event
orbitButton.MouseButton1Click:Connect(function()
    if orbiting then
        orbiting = false
        orbitButton.Text = "Start Orbit"
    else
        local targetName = inputBox.Text
        if targetName ~= "" then
            orbitButton.Text = "Orbiting..."
            startOrbit(targetName)
        end
    end
end)
