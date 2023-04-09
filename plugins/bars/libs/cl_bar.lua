lia.bar = lia.bar or {}
lia.bar.list = {}
lia.bar.delta = lia.bar.delta or {}
lia.bar.actionText = ""
lia.bar.actionStart = 0
lia.bar.actionEnd = 0

function lia.bar.get(identifier)
	for i = 1, #lia.bar.list do
		local bar = lia.bar.list[i]

		if (bar and bar.identifier == identifier) then
			return bar
		end
	end
end

function lia.bar.add(getValue, color, priority, identifier)
	if (identifier) then
		local oldBar = lia.bar.get(identifier)

		if (oldBar) then
			table.remove(lia.bar.list, oldBar.priority)
		end
	end

	priority = priority or table.Count(lia.bar.list) + 1

	local info = lia.bar.list[priority]

	lia.bar.list[priority] = {
		getValue = getValue,
		color = color or info.color or Color(math.random(150, 255), math.random(150, 255), math.random(150, 255)),
		priority = priority,
		lifeTime = 0,
		identifier = identifier
	}

	return priority
end

function lia.bar.remove(identifier)
	local bar
	for k, v in ipairs(lia.bar.list) do
		if v.identifier == identifier then
			bar = v

			break
		end
	end

	if (bar) then
		table.remove(lia.bar.list, bar.priority)
	end
end

local color_dark = Color(0, 0, 0, 225)
local gradient = lia.util.getMaterial("vgui/gradient-u")
local gradient2 = lia.util.getMaterial("vgui/gradient-d")
local surface = surface

function lia.bar.draw(x, y, w, h, value, color)
	lia.util.drawBlurAt(x, y, w, h)

	surface.SetDrawColor(255, 255, 255, 15)
	surface.DrawRect(x, y, w, h)
	surface.DrawOutlinedRect(x, y, w, h)

	x, y, w, h = x + 2, y + 2, (w - 4) * math.min(value, 1), h - 4

	surface.SetDrawColor(color.r, color.g, color.b, 250)
	surface.DrawRect(x, y, w, h)

	surface.SetDrawColor(255, 255, 255, 8)
	surface.SetMaterial(gradient)
	surface.DrawTexturedRect(x, y, w, h)
end

local TEXT_COLOR = Color(240, 240, 240)
local SHADOW_COLOR = Color(20, 20, 20)

function lia.bar.drawAction()
	local start, finish = lia.bar.actionStart, lia.bar.actionEnd
	local curTime = CurTime()
	local scrW, scrH = ScrW(), ScrH()

	if (finish > curTime) then
		local fraction = 1 - math.TimeFraction(start, finish, curTime)
		local alpha = fraction * 255

		if (alpha > 0) then
			local w, h = scrW * 0.35, 28
			local x, y = (scrW * 0.5) - (w * 0.5), (scrH * 0.725) - (h * 0.5)

			lia.util.drawBlurAt(x, y, w, h)

			surface.SetDrawColor(35, 35, 35, 100)
			surface.DrawRect(x, y, w, h)

			surface.SetDrawColor(0, 0, 0, 120)
			surface.DrawOutlinedRect(x, y, w, h)

			surface.SetDrawColor(lia.config.get("color"))
			surface.DrawRect(x + 4, y + 4, (w * fraction) - 8, h - 8)

			surface.SetDrawColor(200, 200, 200, 20)
			surface.SetMaterial(gradient2)
			surface.DrawTexturedRect(x + 4, y + 4, (w * fraction) - 8, h - 8)

			draw.SimpleText(lia.bar.actionText, "liaMediumFont", x + 2, y - 22, SHADOW_COLOR)
			draw.SimpleText(lia.bar.actionText, "liaMediumFont", x, y - 24, TEXT_COLOR)
		end
	end
end

local Approach = math.Approach

BAR_HEIGHT = 10

function lia.bar.drawAll()
	lia.bar.drawAction()

	if (hook.Run("ShouldHideBars")) then
		return
	end

	local w, h = ScrW() * 0.35, BAR_HEIGHT
	local x, y = 4, 4
	local deltas = lia.bar.delta
	local frameTime = FrameTime()
	local curTime = CurTime()
	local updateValue = frameTime * 0.6

	for i = 1, #lia.bar.list do
		local bar = lia.bar.list[i]

		if (bar) then
			local realValue = bar.getValue()
			local value = Approach(deltas[i] or 0, realValue, updateValue)

			deltas[i] = value

			if (deltas[i] ~= realValue) then
				bar.lifeTime = curTime + 5
			end

			if (bar.lifeTime >= curTime or bar.visible or hook.Run("ShouldBarDraw", bar)) then
				lia.bar.draw(x, y, w, h, value, bar.color, bar)
				y = y + h + 2
			end
		end
	end
end

do
	lia.bar.add(function()
		return LocalPlayer():Health() / LocalPlayer():GetMaxHealth()
	end, Color(200, 50, 40), nil, "health")

	lia.bar.add(function()
		return math.min(LocalPlayer():Armor() / 100, 1)
	end, Color(30, 70, 180), nil, "armor")
end

netstream.Hook("actBar", function(start, finish, text)
	if (!text) then
		lia.bar.actionStart = 0
		lia.bar.actionEnd = 0
	else
		if (text:sub(1, 1) == "@") then
			text = L(text:sub(2))
		end

		lia.bar.actionStart = start
		lia.bar.actionEnd = finish
		lia.bar.actionText = text:upper()
	end
end)
