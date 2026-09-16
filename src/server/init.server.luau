local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Nevaeh")
local Config = require(Shared:WaitForChild("Config"))
local Questions = require(Shared:WaitForChild("Questions"))

local remotes = Instance.new("Folder")
remotes.Name = "Remotes"
remotes.Parent = ReplicatedStorage

local function remote(name)
	local r = Instance.new("RemoteEvent")
	r.Name = name
	r.Parent = remotes
	return r
end

local JoinGame = remote("JoinGame")
local LeaveGame = remote("LeaveGame")
local BoardMove = remote("BoardMove")
local CombatInput = remote("CombatInput")
local PushState = remote("PushState")

local ARENA = {
	sphalerizer = Vector3.new(0, 80, -220),
	warrior = Vector3.new(220, 8, 0),
	civil = Vector3.new(-220, 8, 0),
	xo = Vector3.new(140, 8, 140),
	sixseven = Vector3.new(-140, 8, 140),
	guess = Vector3.new(140, 8, -140),
	quiz = Vector3.new(-140, 8, -140),
}

local sessions = {} -- player -> session table

local function part(props)
	local p = Instance.new("Part")
	p.Anchored = true
	p.CanCollide = props.CanCollide ~= false
	p.Material = props.Material or Enum.Material.SmoothPlastic
	p.Color = props.Color or Config.Ink
	p.Size = props.Size or Vector3.new(4, 1, 4)
	p.CFrame = props.CFrame or CFrame.new()
	p.Name = props.Name or "Part"
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	if props.Transparency then
		p.Transparency = props.Transparency
	end
	p.Parent = props.Parent or Workspace
	return p
end

local function glow(p, color)
	local l = Instance.new("PointLight")
	l.Color = color
	l.Brightness = 1.6
	l.Range = 18
	l.Parent = p
end

local function label(adornee, text, color, height)
	local gui = Instance.new("BillboardGui")
	gui.Name = "Label"
	gui.Size = UDim2.fromOffset(240, 48)
	gui.StudsOffset = Vector3.new(0, height or 4, 0)
	gui.AlwaysOnTop = true
	gui.Parent = adornee
	local t = Instance.new("TextLabel")
	t.BackgroundTransparency = 1
	t.Size = UDim2.fromScale(1, 1)
	t.Font = Enum.Font.GothamBold
	t.TextScaled = true
	t.TextColor3 = color or Config.Cyan
	t.TextStrokeTransparency = 0.2
	t.Text = text
	t.Parent = gui
	return t
end

local world = Instance.new("Folder")
world.Name = "NevaehWorld"
world.Parent = Workspace

-- Lobby floor
part({
	Name = "LobbyFloor",
	Size = Vector3.new(160, 2, 160),
	CFrame = CFrame.new(0, 0, 0),
	Color = Color3.fromRGB(12, 10, 22),
	Material = Enum.Material.Slate,
	Parent = world,
})

-- Neon ring
for i = 0, 35 do
	local a = (i / 36) * math.pi * 2
	local r = 72
	local p = part({
		Name = "Ring",
		Size = Vector3.new(6, 0.4, 2),
		CFrame = CFrame.new(math.cos(a) * r, 1.2, math.sin(a) * r) * CFrame.Angles(0, -a, 0),
		Color = (i % 2 == 0) and Config.Pink or Config.Cyan,
		Material = Enum.Material.Neon,
		CanCollide = false,
		Parent = world,
	})
	glow(p, p.Color)
end

local spawn = Instance.new("SpawnLocation")
spawn.Name = "HubSpawn"
spawn.Size = Vector3.new(12, 1, 12)
spawn.CFrame = CFrame.new(0, 2, 8)
spawn.Anchored = true
spawn.Neutral = true
spawn.Duration = 0
spawn.Color = Config.Ink
spawn.Material = Enum.Material.SmoothPlastic
spawn.Parent = world

local titleBlock = part({
	Name = "TitleBlock",
	Size = Vector3.new(28, 16, 1.2),
	CFrame = CFrame.new(0, 14, -28),
	Color = Color3.fromRGB(8, 6, 16),
	Parent = world,
})
label(titleBlock, "Girl of NevaeH", Config.Cyan, 10)
local sub = label(titleBlock, "R A Simpson", Config.Pink, 8)
sub.TextSize = 18

-- Cover frame (import GameIcon.png as a Decal in Studio and parent it here)
local cover = part({
	Name = "CoverFrame",
	Size = Vector3.new(18, 18, 1),
	CFrame = CFrame.new(0, 14, -26.4),
	Color = Color3.fromRGB(20, 12, 32),
	Parent = world,
})
cover:SetAttribute("DecalSlot", "GameIcon")
label(cover, "Place GameIcon.png on this frame", Config.Gold, -10)

local pads = Instance.new("Folder")
pads.Name = "Pads"
pads.Parent = world

for i, g in ipairs(Config.Games) do
	local a = ((i - 1) / #Config.Games) * math.pi * 2 - math.pi / 2
	local pos = Vector3.new(math.cos(a) * 48, 2.2, math.sin(a) * 48)
	local p = part({
		Name = g.id,
		Size = Vector3.new(10, 1.4, 10),
		CFrame = CFrame.new(pos),
		Color = g.color,
		Material = Enum.Material.Neon,
		Parent = pads,
	})
	p:SetAttribute("GameId", g.id)
	glow(p, g.color)
	label(p, g.name, Color3.new(1, 1, 1), 5)
	-- Arena floors
	local origin = ARENA[g.id]
	part({
		Name = g.id .. "Floor",
		Size = Vector3.new(90, 2, 90),
		CFrame = CFrame.new(origin.X, origin.Y - 1, origin.Z),
		Color = Color3.fromRGB(14, 12, 24),
		Material = Enum.Material.Slate,
		Parent = world,
	})
	part({
		Name = g.id .. "Home",
		Size = Vector3.new(8, 1.2, 8),
		CFrame = CFrame.new(origin + Vector3.new(0, 1, 32)),
		Color = Config.Gold,
		Material = Enum.Material.Neon,
		Parent = pads,
	}).Name = "home_" .. g.id
end

-- Civil street extras
for z = -30, 30, 12 do
	part({
		Name = "Curb",
		Size = Vector3.new(18, 4, 8),
		CFrame = CFrame.new(ARENA.civil.X - 22, ARENA.civil.Y + 1, ARENA.civil.Z + z),
		Color = Color3.fromRGB(28, 18, 36),
		Parent = world,
	})
	part({
		Name = "Curb",
		Size = Vector3.new(18, 4, 8),
		CFrame = CFrame.new(ARENA.civil.X + 22, ARENA.civil.Y + 1, ARENA.civil.Z + z),
		Color = Color3.fromRGB(18, 28, 40),
		Parent = world,
	})
end

-- Warrior ring
part({
	Name = "Ring",
	Size = Vector3.new(36, 0.6, 36),
	CFrame = CFrame.new(ARENA.warrior),
	Color = Config.Pink,
	Material = Enum.Material.Neon,
	CanCollide = false,
	Parent = world,
})

-- Sphalerizer lane walls
part({
	Name = "Lane",
	Size = Vector3.new(40, 1, 120),
	CFrame = CFrame.new(ARENA.sphalerizer + Vector3.new(0, -2, 0)),
	Color = Color3.fromRGB(8, 16, 28),
	Parent = world,
})

local function send(player, state)
	PushState:FireClient(player, state)
end

local function publicState(s)
	if not s then
		return { id = "hub" }
	end
	local out = {}
	for k, v in pairs(s) do
		if k ~= "folder" and k ~= "foe" and k ~= "foes" and k ~= "conn" and k ~= "secret" and k ~= "deck" then
			out[k] = v
		end
	end
	if s.id == "quiz" and s.deck and s.deck[s.i] then
		local q = s.deck[s.i]
		out.prompt = q.q
		out.opts = q.opts
	end
	if s.foeHp then
		out.foeHp = s.foeHp
	end
	if s.hp then
		out.hp = s.hp
	end
	return out
end

local function clearSession(player)
	local s = sessions[player]
	if not s then
		return
	end
	if s.conn then
		s.conn:Disconnect()
	end
	if s.folder then
		s.folder:Destroy()
	end
	sessions[player] = nil
end

local function teleport(player, pos)
	local char = player.Character
	if not char then
		return
	end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if hrp then
		hrp.CFrame = CFrame.new(pos + Vector3.new(0, 4, 0))
	end
end

local function shuffle(list)
	local copy = table.clone(list)
	for i = #copy, 2, -1 do
		local j = math.random(i)
		copy[i], copy[j] = copy[j], copy[i]
	end
	return copy
end

-- Board helpers
local XO_LINES = {
	{ 1, 2, 3 },
	{ 4, 5, 6 },
	{ 7, 8, 9 },
	{ 1, 4, 7 },
	{ 2, 5, 8 },
	{ 3, 6, 9 },
	{ 1, 5, 9 },
	{ 3, 5, 7 },
}

local function xoWinner(board)
	for _, line in ipairs(XO_LINES) do
		local a, b, c = board[line[1]], board[line[2]], board[line[3]]
		if a ~= 0 and a == b and b == c then
			return a
		end
	end
	for i = 1, 9 do
		if board[i] == 0 then
			return nil
		end
	end
	return 0
end

local function xoCpu(board)
	for i = 1, 9 do
		if board[i] == 0 then
			board[i] = 2
			if xoWinner(board) == 2 then
				board[i] = 0
				return i
			end
			board[i] = 0
		end
	end
	for i = 1, 9 do
		if board[i] == 0 then
			board[i] = 1
			if xoWinner(board) == 1 then
				board[i] = 0
				return i
			end
			board[i] = 0
		end
	end
	if board[5] == 0 then
		return 5
	end
	local corners = { 1, 3, 7, 9 }
	for _, i in ipairs(shuffle(corners)) do
		if board[i] == 0 then
			return i
		end
	end
	for i = 1, 9 do
		if board[i] == 0 then
			return i
		end
	end
	return nil
end

local COLS, ROWS = 7, 6

local function drop(board, col, side)
	for r = ROWS, 1, -1 do
		local i = (r - 1) * COLS + col
		if board[i] == 0 then
			board[i] = side
			return i
		end
	end
	return nil
end

local function four(board, side)
	local dirs = { { 1, 0 }, { 0, 1 }, { 1, 1 }, { 1, -1 } }
	for r = 1, ROWS do
		for c = 1, COLS do
			if board[(r - 1) * COLS + c] == side then
				for _, d in ipairs(dirs) do
					local n = 0
					for k = 0, 3 do
						local cc, rr = c + d[1] * k, r + d[2] * k
						if cc < 1 or cc > COLS or rr < 1 or rr > ROWS then
							break
						end
						if board[(rr - 1) * COLS + cc] ~= side then
							break
						end
						n += 1
					end
					if n == 4 then
						return true
					end
				end
			end
		end
	end
	return false
end

local function startXO(player)
	sessions[player] = {
		id = "xo",
		board = { 0, 0, 0, 0, 0, 0, 0, 0, 0 },
		turn = 1,
		over = false,
		banner = "Your move — you are X",
	}
	send(player, publicState(sessions[player]))
end

local function startSix(player)
	local board = table.create(COLS * ROWS, 0)
	sessions[player] = {
		id = "sixseven",
		board = board,
		turn = 1,
		over = false,
		banner = "Drop a disc — you are pink",
	}
	send(player, publicState(sessions[player]))
end

local function startGuess(player, diff)
	diff = diff or "normal"
	local range = (diff == "easy" and 20) or (diff == "hard" and 99) or 50
	sessions[player] = {
		id = "guess",
		diff = diff,
		secret = math.random(1, range),
		guesses = 0,
		max = 10,
		lock = { false, false },
		slots = { nil, nil },
		over = false,
		banner = "Pick two digits (01–" .. string.format("%02d", range) .. ")",
		log = {},
	}
	send(player, publicState(sessions[player]))
end

local function startQuiz(player)
	local deck = shuffle(Questions)
	local round = {}
	for i = 1, math.min(8, #deck) do
		table.insert(round, deck[i])
	end
	sessions[player] = {
		id = "quiz",
		deck = round,
		i = 1,
		score = 0,
		over = false,
		banner = "Question 1 of " .. #round,
	}
	send(player, publicState(sessions[player]))
end

local function enemyPart(folder, pos, color, name, hp)
	local p = part({
		Name = name or "Foe",
		Size = Vector3.new(4, 7, 3),
		CFrame = CFrame.new(pos),
		Color = color,
		Material = Enum.Material.Neon,
		Anchored = false,
		CanCollide = true,
		Parent = folder,
	})
	p.Anchored = true
	p:SetAttribute("HP", hp)
	p:SetAttribute("MaxHP", hp)
	label(p, name or "Foe", Color3.new(1, 1, 1), 5)
	return p
end

local function startWarrior(player)
	local folder = Instance.new("Folder")
	folder.Name = "Warrior_" .. player.UserId
	folder.Parent = world
	local foe = enemyPart(folder, ARENA.warrior + Vector3.new(0, 4, -10), Color3.fromRGB(160, 40, 40), "Samael", 70)
	sessions[player] = {
		id = "warrior",
		folder = folder,
		foe = foe,
		hp = 100,
		foeHp = 70,
		youRounds = 0,
		foeRounds = 0,
		cool = 0,
		over = false,
		banner = "Punch / Kick / Special — best of three",
	}
	teleport(player, ARENA.warrior + Vector3.new(0, 2, 10))
	send(player, publicState(sessions[player]))
end

local function startCivil(player)
	local folder = Instance.new("Folder")
	folder.Name = "Civil_" .. player.UserId
	folder.Parent = world
	local foes = {}
	for i = 1, 3 do
		table.insert(
			foes,
			enemyPart(
				folder,
				ARENA.civil + Vector3.new((i - 2) * 8, 4, -18 - i * 6),
				Color3.fromRGB(40, 160, 200),
				"Thug",
				18
			)
		)
	end
	sessions[player] = {
		id = "civil",
		folder = folder,
		foes = foes,
		hp = 100,
		boss = false,
		over = false,
		banner = "Clear the street, then The Karen",
		cool = 0,
	}
	teleport(player, ARENA.civil + Vector3.new(0, 2, 20))
	send(player, publicState(sessions[player]))
end

local function startSphal(player)
	local folder = Instance.new("Folder")
	folder.Name = "Sphal_" .. player.UserId
	folder.Parent = world
	local foes = {}
	for i = 1, 6 do
		local f = enemyPart(
			folder,
			ARENA.sphalerizer + Vector3.new((i % 3 - 1) * 10, 4, -20 - math.floor((i - 1) / 3) * 14),
			Config.Pink,
			"Drone",
			8
		)
		f.Size = Vector3.new(5, 2, 6)
		table.insert(foes, f)
	end
	sessions[player] = {
		id = "sphalerizer",
		folder = folder,
		foes = foes,
		hp = 3,
		score = 0,
		boss = false,
		over = false,
		banner = "Fly the lane. Click to fire.",
		cool = 0,
	}
	teleport(player, ARENA.sphalerizer + Vector3.new(0, 6, 40))
	send(player, publicState(sessions[player]))
end

local starters = {
	xo = startXO,
	sixseven = startSix,
	guess = startGuess,
	quiz = startQuiz,
	warrior = startWarrior,
	civil = startCivil,
	sphalerizer = startSphal,
}

JoinGame.OnServerEvent:Connect(function(player, gameId)
	if typeof(gameId) ~= "string" or not starters[gameId] then
		return
	end
	clearSession(player)
	teleport(player, ARENA[gameId] + Vector3.new(0, 2, 24))
	starters[gameId](player)
end)

LeaveGame.OnServerEvent:Connect(function(player)
	clearSession(player)
	teleport(player, Vector3.new(0, 4, 8))
	send(player, { id = "hub" })
end)

BoardMove.OnServerEvent:Connect(function(player, payload)
	local s = sessions[player]
	if not s or s.over or typeof(payload) ~= "table" then
		return
	end
	if s.id == "xo" then
		local i = payload.i
		if typeof(i) ~= "number" or s.board[i] ~= 0 then
			return
		end
		s.board[i] = 1
		local w = xoWinner(s.board)
		if w == 1 then
			s.over = true
			s.banner = "You win"
		elseif w == 0 then
			s.over = true
			s.banner = "Draw"
		else
			local m = xoCpu(s.board)
			if m then
				s.board[m] = 2
				w = xoWinner(s.board)
				if w == 2 then
					s.over = true
					s.banner = "CPU wins"
				elseif w == 0 then
					s.over = true
					s.banner = "Draw"
				end
			end
		end
	elseif s.id == "sixseven" then
		local col = payload.col
		if typeof(col) ~= "number" then
			return
		end
		if not drop(s.board, col, 1) then
			return
		end
		if four(s.board, 1) then
			s.over = true
			s.banner = "You win"
		else
			local legal = {}
			for c = 1, COLS do
				if s.board[c] == 0 then
					table.insert(legal, c)
				end
			end
			if #legal == 0 then
				s.over = true
				s.banner = "Draw"
			else
				drop(s.board, legal[math.random(#legal)], 2)
				if four(s.board, 2) then
					s.over = true
					s.banner = "CPU wins"
				end
			end
		end
	elseif s.id == "guess" then
		if payload.diff then
			startGuess(player, payload.diff)
			return
		end
		if payload.place and payload.digit then
			local place = payload.place
			local digit = payload.digit
			if place ~= 1 and place ~= 2 then
				return
			end
			if typeof(digit) ~= "number" or digit < 0 or digit > 9 then
				return
			end
			s.slots[place] = digit
		elseif payload.submit then
			if s.slots[1] == nil or s.slots[2] == nil then
				s.banner = "Pick two digits"
			else
				local n = s.slots[1] * 10 + s.slots[2]
				s.guesses += 1
				local pad = string.format("%02d", s.secret)
				local g = string.format("%02d", n)
				s.lock[1] = s.lock[1] or (pad:sub(1, 1) == g:sub(1, 1))
				s.lock[2] = s.lock[2] or (pad:sub(2, 2) == g:sub(2, 2))
				table.insert(s.log, g)
				if n == s.secret then
					s.over = true
					s.banner = "Yes — " .. pad
				elseif s.guesses >= s.max then
					s.over = true
					s.banner = "The number was " .. pad
				else
					s.banner = (n < s.secret and "Higher") or "Lower"
					s.slots = { nil, nil }
				end
			end
		end
	elseif s.id == "quiz" then
		local pick = payload.opt
		local q = s.deck[s.i]
		if not q or typeof(pick) ~= "number" then
			return
		end
		if q.opts[pick] == q.a then
			s.score += 1
			s.banner = "Correct"
		else
			s.banner = "It was " .. q.a
		end
		s.i += 1
		if s.i > #s.deck then
			s.over = true
			s.banner = "Score " .. s.score .. " / " .. #s.deck
		else
			s.banner = "Question " .. s.i .. " of " .. #s.deck
		end
	end
	send(player, publicState(s))
end)

local function hitFoe(player, s, dmg)
	local char = player.Character
	if not char then
		return
	end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then
		return
	end
	local function apply(f)
		if not f or not f.Parent then
			return
		end
		if (f.Position - hrp.Position).Magnitude > 14 then
			return
		end
		local hp = (f:GetAttribute("HP") or 1) - dmg
		f:SetAttribute("HP", hp)
		if hp <= 0 then
			f:Destroy()
			return true
		end
	end
	if s.foe then
		if apply(s.foe) then
			s.youRounds += 1
			s.banner = "Round " .. s.youRounds
			if s.youRounds >= 2 then
				s.over = true
				s.banner = "You win the battle"
			else
				s.foe = enemyPart(s.folder, ARENA.warrior + Vector3.new(0, 4, -10), Color3.fromRGB(160, 40, 40), "Samael", 70)
				s.foeHp = 70
				s.hp = 100
			end
		else
			s.foeHp = s.foe:GetAttribute("HP")
		end
	end
	if s.foes then
		for i = #s.foes, 1, -1 do
			if apply(s.foes[i]) then
				table.remove(s.foes, i)
				s.score = (s.score or 0) + 10
			end
		end
		if s.id == "civil" and #s.foes == 0 and not s.boss then
			s.boss = true
			local karen = enemyPart(s.folder, ARENA.civil + Vector3.new(0, 4, -24), Config.Pink, "The Karen", 38)
			karen.Size = Vector3.new(5, 8, 3)
			table.insert(s.foes, karen)
			s.banner = "THE KAREN"
		elseif s.id == "sphalerizer" and #s.foes == 0 and not s.boss then
			s.boss = true
			local boss = enemyPart(s.folder, ARENA.sphalerizer + Vector3.new(0, 6, -40), Color3.fromRGB(220, 40, 40), "Zorath", 40)
			boss.Size = Vector3.new(10, 4, 12)
			table.insert(s.foes, boss)
			s.banner = "BOSS — Zorath"
		elseif #s.foes == 0 then
			s.over = true
			s.banner = "Clear"
		end
	end
end

CombatInput.OnServerEvent:Connect(function(player, action)
	local s = sessions[player]
	if not s or s.over then
		return
	end
	if s.id ~= "warrior" and s.id ~= "civil" and s.id ~= "sphalerizer" then
		return
	end
	if typeof(action) ~= "string" then
		return
	end
	local now = os.clock()
	if now < (s.cool or 0) then
		return
	end
	if action == "punch" then
		s.cool = now + 0.28
		hitFoe(player, s, 6)
	elseif action == "kick" then
		s.cool = now + 0.4
		hitFoe(player, s, 9)
	elseif action == "special" then
		s.cool = now + 0.8
		hitFoe(player, s, 14)
	elseif action == "fire" and s.id == "sphalerizer" then
		s.cool = now + 0.18
		hitFoe(player, s, 8)
	end
	send(player, publicState(s))
end)

-- Foes slowly close; chip the player if they linger
RunService.Heartbeat:Connect(function(dt)
	for player, s in pairs(sessions) do
		if s.over then
			continue
		end
		local char = player.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if not hrp then
			continue
		end
		local function chase(f, speed, dmg, range)
			if not f or not f.Parent then
				return
			end
			local dir = (hrp.Position - f.Position)
			if dir.Magnitude > 4 then
				f.CFrame = f.CFrame:Lerp(CFrame.new(f.Position + dir.Unit * speed * dt, hrp.Position), 0.2)
			end
			if dir.Magnitude < range then
				s.hp = math.max(0, (s.hp or 100) - dmg * dt)
				if s.hp <= 0 then
					s.over = true
					s.banner = "Down"
					send(player, publicState(s))
				end
			end
		end
		if s.foe then
			chase(s.foe, 8, 8, 7)
			s.foeHp = s.foe:GetAttribute("HP")
		end
		if s.foes then
			for _, f in ipairs(s.foes) do
				chase(f, (s.id == "sphalerizer" and 10) or 7, (s.boss and 10) or 6, (s.id == "sphalerizer" and 8) or 7)
			end
		end
	end
end)

Players.PlayerRemoving:Connect(function(player)
	clearSession(player)
end)

print("[Girl of NevaeH] lobby ready")
