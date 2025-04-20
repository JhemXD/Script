-- Create the main instance (big box)
local mainInstance = Instance.new("Frame")
mainInstance.Size = UDim2.new(0, 400, 0, 300)
mainInstance.Position = UDim2.new(0.5, -200, 0.5, -150)
mainInstance.BackgroundColor3 = Color3.new(0.9, 0.9, 0.9) -- Light gray
mainInstance.Visible = true -- Initially visible
mainInstance.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Add a tab container for page switching
local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, 0, 0, 30)
tabContainer.BackgroundColor3 = Color3.new(0, 0, 0) -- Black
tabContainer.Parent = mainInstance

-- Create a container for pages
local pageContainer = Instance.new("Frame")
pageContainer.Size = UDim2.new(1, 0, 1, -30)
pageContainer.Position = UDim2.new(0, 0, 0, 30)
pageContainer.BackgroundTransparency = 1
pageContainer.Parent = mainInstance

-- Add the controller instance (button with "J")
local controllerInstance = Instance.new("TextButton")
controllerInstance.Size = UDim2.new(0, 50, 0, 50)
controllerInstance.Position = UDim2.new(0, 20, 0, 20) -- Initial position
controllerInstance.BackgroundColor3 = Color3.new(0, 0, 0) -- Black
controllerInstance.Text = "J"
controllerInstance.TextColor3 = Color3.new(1, 1, 1) -- White
controllerInstance.Font = Enum.Font.SourceSansBold
controllerInstance.TextSize = 24
controllerInstance.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Toggle the visibility of the main instance when the controller is clicked
controllerInstance.MouseButton1Click:Connect(function()
    mainInstance.Visible = not mainInstance.Visible
end)

-- Make the controller draggable
local dragging = false
local dragStartPos, startPos

controllerInstance.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStartPos = input.Position
        startPos = controllerInstance.Position
    end
end)

controllerInstance.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStartPos
        controllerInstance.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

controllerInstance.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Configuration for pages and buttons
local pagesConfig = {
    {
        name = "Character",
        elements = {
            {
                type = "slider",
                caption = "Speed boost",
                default = 0,
                min = 0,
                max = 100,
                step = 1,
                callback = function(value)
                    vals.SpeedBoost = value
                end,
                displayFunction = function(value)
                    return value .. "%"
                end
            },
            {
                type = "slider",
                caption = "Jump height",
                default = 7.2,
                min = 0,
                max = 12.5,
                step = 0.1,
                callback = function(value)
                    vals.JumpBoost = value
                end,
                displayFunction = function(value)
                    return value .. " studs"
                end
            },
            {
                type = "toggle",
                caption = "Noclip",
                default = false,
                callback = function(state)
                    vals.Noclip = state
                end
            },
            {
                type = "separator"
            },
            {
                type = "toggle",
                caption = "No void (fix death when falling under map)",
                default = false,
                callback = function(state)
                    vals.NoVoid = state
                end
            },
            {
                type = "separator"
            },
            {
                type = "button",
                caption = "Teleport to train [No TP = click that button again]",
                callback = function()
                    if workspace:FindFirstChild("Train") and workspace.Train.TrainControls.ConductorSeat:FindFirstChild("VehicleSeat") then
                        local oldPos = workspace.Train.TrainControls.ConductorSeat.VehicleSeat:GetPivot()

                        repeat
                            sit(workspace.Train.TrainControls.ConductorSeat.VehicleSeat)
                            task.wait(0.01)
                        until workspace.Train.TrainControls.ConductorSeat.VehicleSeat:FindFirstChild("SeatWeld")

                        workspace.Train.TrainControls.ConductorSeat.VehicleSeat:PivotTo(oldPos)
                    else
                        lib.Notifications:Notification({
                            Title = "Uh-oh!",
                            Text = "Looks like the train is way too far away"
                        })
                    end
                end
            },
            {
                type = "button",
                caption = "Teleport to end [No TP = click that button again]",
                callback = tpEnd
            },
            {
                type = "toggle",
                caption = "Auto complete game",
                default = false,
                callback = function(state)
                    vals.AutoComplete = state
                end
            }
        }
    }
}

-- Function to create a page
local function createPage(config)
    local page = Instance.new("Frame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Name = config.name
    page.Parent = pageContainer

    -- Create elements dynamically
    for _, element in ipairs(config.elements) do
        if element.type == "slider" then
            local slider = Instance.new("TextButton") -- Placeholder for slider
            slider.Size = UDim2.new(0, 150, 0, 30)
            slider.Position = UDim2.new(0, 10, 0, 10)
            slider.Text = element.caption .. ": " .. (element.displayFunction and element.displayFunction(element.default) or tostring(element.default))
            slider.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2) -- Dark gray
            slider.TextColor3 = Color3.new(1, 1, 1) -- White
            slider.Parent = page

            slider.MouseButton1Click:Connect(function()
                element.callback(element.default)
                slider.Text = element.caption .. ": " .. (element.displayFunction and element.displayFunction(element.default) or tostring(element.default))
            end)
        elseif element.type == "toggle" then
            local toggle = Instance.new("TextButton")
            toggle.Size = UDim2.new(0, 150, 0, 30)
            toggle.Position = UDim2.new(0, 10, 0, 50)
            toggle.Text = element.caption .. (element.default and " [ON]" or " [OFF]")
            toggle.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2) -- Dark gray
            toggle.TextColor3 = Color3.new(1, 1, 1) -- White
            toggle.Parent = page

            local state = element.default
            toggle.MouseButton1Click:Connect(function()
                state = not state
                element.callback(state)
                toggle.Text = element.caption .. (state and " [ON]" or " [OFF]")
            end)
        elseif element.type == "button" then
            local button = Instance.new("TextButton")
            button.Size = UDim2.new(0, 150, 0, 30)
            button.Position = UDim2.new(0, 10, 0, 90)
            button.Text = element.caption
            button.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2) -- Dark gray
            button.TextColor3 = Color3.new(1, 1, 1) -- White
            button.Parent = page

            button.MouseButton1Click:Connect(function()
                element.callback()
            end)
        elseif element.type == "separator" then
            local separator = Instance.new("Frame")
            separator.Size = UDim2.new(1, 0, 0, 1)
            separator.Position = UDim2.new(0, 0, 0, 70)
            separator.BackgroundColor3 = Color3.new(0.5, 0.5, 0.5) -- Gray
            separator.BorderSizePixel = 0
            separator.Parent = page
        end
    end

    return page
end

-- Create tabs and pages dynamically
local pages = {}
for i, pageConfig in ipairs(pagesConfig) do
    -- Create the page
    local page = createPage(pageConfig)
    table.insert(pages, page)

    -- Create the tab button
    local tabButton = Instance.new("TextButton")
    tabButton.Size = UDim2.new(0, 70, 1, 0)
    tabButton.Position = UDim2.new(0, (i - 1) * 80, 0, 0)
    tabButton.Text = pageConfig.name
    tabButton.TextColor3 = Color3.new(1, 1, 1) -- White
    tabButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2) -- Dark gray
    tabButton.Parent = tabContainer

    -- Connect tab button to show the corresponding page
    tabButton.MouseButton1Click:Connect(function()
        for _, p in ipairs(pages) do
            p.Visible = false
        end
        page.Visible = true
    end)
end

-- Show the first page by default
if #pages > 0 then
    pages[1].Visible = true
end
