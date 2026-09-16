local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local Shared = ReplicatedStorage:WaitForChild("Nevaeh")
local Config = require(Shared:WaitForChild("Config"))
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local JoinGame = remotes:WaitForChild("JoinGame")
local LeaveGame = remotes:WaitForChild("LeaveGame")
local BoardMove = remotes:WaitForChild("BoardMove")
local CombatInput = remotes:WaitForChild("CombatInput")
local PushState = remotes:WaitForChild("PushState")

local gui = Instance.new("ScreenGui")
gui.Name = "NevaehHud"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

local function mk(class, props, parent)
	local o = Instance.new(class)
	for k, v in pairs(props) do
		o[k] = v
	end
	o.Parent = parent
	return o
end

local banner = mk("TextLabel", {
	BackgroundTransparency = 1,
	Position = UDim2.new(0.1, 0, 0.04, 0),
	Size = UDim2.new(0.8, 0, 0.07, 0),
	Font = Enum.Font.GothamBold,
	TextScaled = true,
	TextColor3 = Config.Cyan,
	TextStrokeTransparency = 0.3,
	Text = "Girl of NevaeH  ·  step on a neon pad",
}, gui)

local hint = mk("TextLabel", {
	BackgroundTransparency = 1,
	Position = UDim2.new(0.1, 0, 0.11, 0),
	Size = UDim2.new(0.8, 0, 0.04, 0),
	Font = Enum.Font.Gotham,
	TextScaled = true,
	TextColor3 = Config.Pink,
	Text = "WASD move · pads start a game · H returns to the hub",
}, gui)

local boardFrame = mk("Frame", {
	AnchorPoint = Vector2.new(0.5, 1),
	Position = UDim2.new(0.5, 0, 1, -24),
	Size = UDim2.new(0, 360, 0, 360),
	BackgroundColor3 = Color3.fromRGB(12, 10, 22),
	BorderSizePixel = 0,
	Visible = false,
}, gui)
mk("UICorner", { CornerRadius = UDim.new(0, 16) }, boardFrame)
mk("UIStroke", { Color = Config.Cyan, Thickness = 2 }, boardFrame)

local cells = {}

local function clearBoard()
	for _, child in ipairs(boardFrame:GetChildren()) do
		child:Destroy()
	end
	table.clear(cells)
end

local function cellButton(parent, text, onClick)
	local b = mk("TextButton", {
		BackgroundColor3 = Color3.fromRGB(22, 18, 36),
		TextColor3 = Color3.new(1, 1, 1),
		Font = Enum.Font.GothamBold,
		TextScaled = true,
		Text = text or "",
		AutoButtonColor = true,
	}, parent)
	mk("UICorner", { CornerRadius = UDim.new(0, 8) }, b)
	b.MouseButton1Click:Connect(onClick)
	table.insert(cells, b)
	return b
end

local state = { id = "hub" }

local function showHub()
	boardFrame.Visible = false
	clearBoard()
	banner.Text = "Girl of NevaeH  ·  step on a neon pad"
	hint.Text = "WASD move · pads start a game · H returns to the hub"
end

local function renderXO()
	boardFrame.Visible = true
	clearBoard()
	mk("UIGridLayout", { CellSize = UDim2.fromOffset(108, 108), CellPadding = UDim2.fromOffset(8, 8), FillDirectionMaxCells = 3 }, boardFrame)
	for i = 1, 9 do
		local v = state.board[i]
		local mark = (v == 1 and "X") or (v == 2 and "O") or ""
		local b = cellButton(boardFrame, mark, function()
			if not state.over and v == 0 then
				BoardMove:FireServer({ i = i })
			end
		end)
		b.TextColor3 = v == 1 and Config.Pink or Config.Cyan
	end
end

local function renderSix()
	boardFrame.Visible = true
	clearBoard()
	mk("UIGridLayout", { CellSize = UDim2.fromOffset(44, 44), CellPadding = UDim2.fromOffset(4, 4), FillDirectionMaxCells = 7 }, boardFrame)
	for r = 1, 6 do
		for c = 1, 7 do
			local i = (r - 1) * 7 + c
			local v = state.board[i]
			local b = cellButton(boardFrame, "", function()
				if not state.over then
					BoardMove:FireServer({ col = c })
				end
			end)
			if v == 1 then
				b.BackgroundColor3 = Config.Pink
			elseif v == 2 then
				b.BackgroundColor3 = Config.Cyan
			end
		end
	end
end

local function renderGuess()
	boardFrame.Visible = true
	clearBoard()
	local layout = mk("UIListLayout", { Padding = UDim.new(0, 6), FillDirection = Enum.FillDirection.Vertical, HorizontalAlignment = Enum.HorizontalAlignment.Center }, boardFrame)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	local row = mk("Frame", { Size = UDim2.new(1, -16, 0, 64), BackgroundTransparency = 1, LayoutOrder = 1 }, boardFrame)
	table.insert(cells, row)
	mk("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8), HorizontalAlignment = Enum.HorizontalAlignment.Center }, row)
	for place = 1, 2 do
		local shown = state.slots and state.slots[place]
		local lock = state.lock and state.lock[place]
		local b = mk("TextLabel", {
			Size = UDim2.fromOffset(64, 64),
			BackgroundColor3 = lock and Config.Cyan or Color3.fromRGB(22, 18, 36),
			TextColor3 = Color3.new(1, 1, 1),
			Font = Enum.Font.GothamBold,
			TextScaled = true,
			Text = shown ~= nil and tostring(shown) or "·",
		}, row)
		mk("UICorner", { CornerRadius = UDim.new(0, 8) }, b)
		table.insert(cells, b)
	end
	local keys = mk("Frame", { Size = UDim2.new(1, -16, 0, 160), BackgroundTransparency = 1, LayoutOrder = 2 }, boardFrame)
	table.insert(cells, keys)
	mk("UIGridLayout", { CellSize = UDim2.fromOffset(56, 44), CellPadding = UDim2.fromOffset(6, 6), FillDirectionMaxCells = 5 }, keys)
	for d = 0, 9 do
		cellButton(keys, tostring(d), function()
			local place = (state.slots and state.slots[1] == nil) and 1 or 2
			BoardMove:FireServer({ place = place, digit = d })
		end)
	end
	cellButton(boardFrame, "Guess", function()
		BoardMove:FireServer({ submit = true })
	end).LayoutOrder = 3
end

local function renderQuiz()
	boardFrame.Visible = true
	clearBoard()
	mk("UIListLayout", { Padding = UDim.new(0, 8), HorizontalAlignment = Enum.HorizontalAlignment.Center }, boardFrame)
	local q = mk("TextLabel", {
		Size = UDim2.new(1, -16, 0, 80),
		BackgroundTransparency = 1,
		TextWrapped = true,
		Font = Enum.Font.GothamBold,
		TextColor3 = Color3.new(1, 1, 1),
		TextScaled = true,
		Text = state.prompt or "",
	}, boardFrame)
	table.insert(cells, q)
	for i, opt in ipairs(state.opts or {}) do
		cellButton(boardFrame, opt, function()
			if not state.over then
				BoardMove:FireServer({ opt = i })
			end
		end).Size = UDim2.new(1, -16, 0, 48)
	end
end

local function renderCombat()
	boardFrame.Visible = true
	clearBoard()
	mk("UIListLayout", { Padding = UDim.new(0, 8), HorizontalAlignment = Enum.HorizontalAlignment.Center }, boardFrame)
	local hp = mk("TextLabel", {
		Size = UDim2.new(1, -16, 0, 40),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		TextColor3 = Config.Pink,
		TextScaled = true,
		Text = "You  " .. tostring(state.hp or 100) .. "   ·   Foe  " .. tostring(state.foeHp or "-"),
	}, boardFrame)
	table.insert(cells, hp)
	for _, spec in ipairs({
		{ "Punch", "punch" },
		{ "Kick", "kick" },
		{ state.id == "sphalerizer" and "Fire" or "Special", state.id == "sphalerizer" and "fire" or "special" },
	}) do
		cellButton(boardFrame, spec[1], function()
			CombatInput:FireServer(spec[2])
		end).Size = UDim2.new(0.8, 0, 0, 52)
	end
end

local function render()
	banner.Text = state.banner or Config.Title
	if state.id == "hub" or not state.id then
		showHub()
		return
	end
	if state.id == "xo" then
		renderXO()
	elseif state.id == "sixseven" then
		renderSix()
	elseif state.id == "guess" then
		renderGuess()
	elseif state.id == "quiz" then
		renderQuiz()
	else
		renderCombat()
	end
	if state.over then
		hint.Text = "H  ·  back to the hub"
	end
end

PushState.OnClientEvent:Connect(function(nextState)
	state = nextState or { id = "hub" }
	render()
end)

local debounce = {}
local pads = Workspace:WaitForChild("NevaehWorld"):WaitForChild("Pads")

local function onTouched(hit, pad)
	local char = player.Character
	if not char or not hit:IsDescendantOf(char) then
		return
	end
	local now = os.clock()
	if (debounce[pad] or 0) > now then
		return
	end
	debounce[pad] = now + 1.2
	if string.sub(pad.Name, 1, 5) == "home_" then
		LeaveGame:FireServer()
		return
	end
	local id = pad:GetAttribute("GameId")
	if id then
		JoinGame:FireServer(id)
	end
end

for _, pad in ipairs(pads:GetChildren()) do
	pad.Touched:Connect(function(hit)
		onTouched(hit, pad)
	end)
end

ContextActionService:BindAction("NevaehHome", function(_, kind)
	if kind == Enum.UserInputState.Begin then
		LeaveGame:FireServer()
	end
end, false, Enum.KeyCode.H)

UserInputService.InputBegan:Connect(function(input, gp)
	if gp then
		return
	end
	if state.id == "warrior" or state.id == "civil" then
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.KeyCode == Enum.KeyCode.J then
			CombatInput:FireServer("punch")
		elseif input.KeyCode == Enum.KeyCode.K then
			CombatInput:FireServer("kick")
		elseif input.KeyCode == Enum.KeyCode.L or input.KeyCode == Enum.KeyCode.Q then
			CombatInput:FireServer("special")
		end
	elseif state.id == "sphalerizer" then
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.KeyCode == Enum.KeyCode.Space then
			CombatInput:FireServer("fire")
		end
	end
end)

render()
