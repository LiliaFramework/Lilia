tween = {}

local isfunction = isfunction
local math_fmod = math.fmod
local math_pow = math.pow
local Vector_0 = Vector(0, 0, 0)

TWEEN_EASE_LINEAR = function(n) return n end
TWEEN_EASE_IN_OUT = math.EaseInOut
TWEEN_EASE_SINE_IN = math.ease.InSine
TWEEN_EASE_SINE_OUT = math.ease.OutSine
TWEEN_EASE_SINE_IN_OUT = math.ease.InOutSine
TWEEN_EASE_QUAD_IN = math.ease.InQuad
TWEEN_EASE_QUAD_OUT = math.ease.OutQuad
TWEEN_EASE_QUAD_IN_OUT = math.ease.InOutQuad
TWEEN_EASE_CUBIC_IN = math.ease.InCubic
TWEEN_EASE_CUBIC_OUT = math.ease.OutCubic
TWEEN_EASE_CUBIC_IN_OUT = math.ease.InOutCubic
TWEEN_EASE_QUART_IN = math.ease.InQuart
TWEEN_EASE_QUART_OUT = math.ease.OutQuart
TWEEN_EASE_QUART_IN_OUT = math.ease.InOutQuart
TWEEN_EASE_QUINT_IN = math.ease.InQuint
TWEEN_EASE_QUINT_OUT = math.ease.OutQuint
TWEEN_EASE_QUINT_IN_OUT = math.ease.InOutQuint
TWEEN_EASE_EXPO_IN = math.ease.InExpo
TWEEN_EASE_EXPO_OUT = math.ease.OutExpo
TWEEN_EASE_EXPO_IN_OUT = math.ease.InOutExpo
TWEEN_EASE_CIRC_IN = math.ease.InCirc
TWEEN_EASE_CIRC_OUT = math.ease.OutCirc
TWEEN_EASE_CIRC_IN_OUT = math.ease.InOutCirc
TWEEN_EASE_BACK_IN = math.ease.InBack
TWEEN_EASE_BACK_OUT = math.ease.OutBack
TWEEN_EASE_BACK_IN_OUT = math.ease.InOutBack
TWEEN_EASE_ELASTIC_IN = math.ease.InElastic
TWEEN_EASE_ELASTIC_OUT = math.ease.OutElastic
TWEEN_EASE_ELASTIC_IN_OUT = math.ease.InOutElastic
TWEEN_EASE_BOUNCE_IN = math.ease.InBounce
TWEEN_EASE_BOUNCE_OUT = math.ease.OutBounce
TWEEN_EASE_BOUNCE_IN_OUT = math.ease.InOutBounce

local function table_Inherit(target, base)
	for k, v in next, base do
		if target[k] then continue end
		
		target[k] = v
	end
	
	return target
end

local metaTable_Vector2 = {
	__add = function(self, other)
		return Vector2(self.x + other.x, self.y + other.y)
	end,
	
	__sub = function(self, other)
		return Vector2(self.x - other.x, self.y - other.y)
	end,
	
	__mul = function(self, other)
		if isnumber(other) then
			return Vector2(self.x * other, self.y * other)
		elseif isnumber(self) then
			return Vector2(self * other.x, self * other.y)
		end
		
		return Vector2(self.x * other.x, self.y * other.y)
	end,
	
	__div = function(self, other)
		if isnumber(other) then
			return Vector2(self.x / other, self.y / other)
		end
		
		return Vector2(self.x / other.x, self.y / other.y)
	end,
	
	__tostring = function(self)
		return string.format("%.6f %.6f", self.x, self.y)
	end,
	
	SetUnpacked = function(self, x, y)
		self.x = x
		self.y = y
	end,
	
	GetPos = function(self)
		return Vector2(self.x, self.y)
	end
}

metaTable_Vector2.__index = metaTable_Vector2

function isvector2(v)
	return getmetatable(v) == metaTable_Vector2
end

function Vector2(x, y)
	local Vector2 = {
		x = x,
		y = y
	}
	
	return setmetatable(Vector2, metaTable_Vector2)
end

function tween.Lerp(from, to, t)
	return (1 - t) * from + t * to
end

local Lerp = tween.Lerp

local function CalcAng(from, to)
	local diff = math_fmod(to - from, 360)
	
	return math_fmod(2 * diff, 360) - diff
end

local function LerpDeg(from, to, t)
	return from + CalcAng(from, to) * t
end

function tween.LerpAngle(from, to, t)
	return Angle(
		LerpDeg(from.p, to.p, t),
		LerpDeg(from.y, to.y, t),
		LerpDeg(from.r, to.r, t)
	)
end

local LerpAngle = tween.LerpAngle

local function LerpVector2Unpacked(vector2, from, to, t)
	local lerped_vector2 = Lerp(from, to, t)
	
	vector2:SetUnpacked(lerped_vector2.x, lerped_vector2.y)
end

local function LerpVectorUnpacked(vector, from, to, t)
	local lerped_vector = Lerp(from, to, t)
	
	vector:SetUnpacked(lerped_vector.x, lerped_vector.y, lerped_vector.z)
end

local function LerpColor(from, to, t)
	return Color(
		Lerp(from.r, to.r, t),
		Lerp(from.g, to.g, t),
		Lerp(from.b, to.b, t),
		Lerp(from.a, to.a, t)
	)
end

local function LerpColorUnpacked(color, from, to, t)
	color:SetUnpacked(
		Lerp(from.r, to.r, t),
		Lerp(from.g, to.g, t),
		Lerp(from.b, to.b, t),
		Lerp(from.a, to.a, t)
	)
end

local function LerpAngleUnpacked(angle, from, to, t)
	angle:SetUnpacked(
		LerpDeg(from.p, to.p, t),
		LerpDeg(from.y, to.y, t),
		LerpDeg(from.r, to.r, t)
	)
end

local function BinomialCoefficient(n, k)
	local result = 1
	
	for i = 1, k do
		result = result * (n - i + 1) / i
	end
	
	return result
end

function tween.BSpline(points, t)
	local n = #points
	local result = Vector_0
	
	for i = 1, n do
		local weight = BinomialCoefficient(n - 1, i - 1) * math_pow(1 - t, n - i) * math_pow(t, i - 1)
		
		result = result + weight * points[i]
	end
	
	return result
end

local BSpline = tween.BSpline

local all_tweens = {}
local running_tweens = {}
local paused_tweens = {}
local stopped_tweens = {}

local type_to_function = {
	["number"] = Lerp,
	["vector2"] = Lerp,
	["vector"] = Lerp,
	["color"] = LerpColor,
	["angle"] = LerpAngle
}

local type_to_function_unpacked = {
	["number"] = Lerp,
	["vector2"] = LerpVector2Unpacked,
	["vector"] = LerpVectorUnpacked,
	["color"] = LerpColorUnpacked,
	["angle"] = LerpAngleUnpacked
}

local function tween_type(object)
	return isvector2(object) and "vector2"
		or IsColor(object) and "color"
		or type(object):lower()
end

local metaTable_Tween = {
	__newindex = function(self, key, value)
		rawset(self, key, value)
	end,
	
	Start = function(self)
		self.running = true
		self.start_time = SysTime()
		self.end_time = self.start_time + self.duration
		self.time_left = self.duration
		self.tween_type = tween_type(self.from)
		self.lerp_type = type_to_function[self.tween_type]
		
		all_tweens[self] = true
		running_tweens[self] = true
	end,
	
	SetPermanent = function(self, bool)
		self.permanent = bool
	end,
	
	SetFrom = function(self, from)
		self.from = from
	end,
	
	SetTo = function(self, to)
		self.to = to
	end,
	
	SetWaypoints = function(self, from, to)
		self.from = from
		self.to = to
	end,
	
	SetDuration = function(self, duration)
		self.duration = duration
	end,
	
	SetEaseType = function(self, ease_type)
		self.ease_type = ease_type
	end,
	
	Restart = function(self)
		if !all_tweens[self] then
			self:Start()
			
			return
		end
		
		self.running = true
		self.start_time = SysTime()
		self.end_time = self.start_time + self.duration
		self.time_left = self.duration
		
		if !running_tweens[self] then
			running_tweens[self] = true
		end
		
		if paused_tweens[self] then
			paused_tweens[self] = nil
		elseif stopped_tweens[self] then
			stopped_tweens[self] = nil
		end
	end,
	
	Pause = function(self)
		if stopped_tweens[self] then return end
		
		self.running = false
		
		if running_tweens[self] then
			running_tweens[self] = nil
			paused_tweens[self] = true
		end
	end,
	
	Resume = function(self)
		if stopped_tweens[self] then
			self:Restart()
			
			return
		end
		
		self.start_time = SysTime() - (self.duration - self.time_left)
		self.end_time = self.start_time + self.duration
		self.running = true
		
		if paused_tweens[self] then
			paused_tweens[self] = nil
			running_tweens[self] = true
		end
	end,
	
	Stop = function(self)
		self.running = false
		
		if running_tweens[self] then
			running_tweens[self] = nil
		elseif paused_tweens[self] then
			paused_tweens[self] = nil
		end
		
		stopped_tweens[self] = true
	end,
	
	Update = function(self)
		if self.running then
			local time = SysTime()
			self.time_left = self.end_time - time
			
			if time >= self.end_time then
				self.running = false
				self.value = self.to
				
				if !self.permanent then
					all_tweens[self] = nil
					running_tweens[self] = nil
				end
				
				if self.callback != nil then
					self.callback(self)
				end
				
				return
			end
			
			local alpha = (time - self.start_time) / self.duration
			
			self.value = self.lerp_type(self.from, self.to, self.ease_type(alpha))
			
			local OnUpdate = self.OnUpdate
			
			if OnUpdate and isfunction(OnUpdate) then
				self:OnUpdate()
			end
		end
	end,
	
	TimeLeft = function(self)
		return self.time_left
	end,
	
	GetValue = function(self)
		return self.value
	end,
	
	Destroy = function(self)
		all_tweens[self] = nil
		
		if running_tweens[self] then
			running_tweens[self] = nil
		elseif paused_tweens[self] then
			paused_tweens[self] = nil
		elseif stopped_tweens[self] then
			stopped_tweens[self] = nil
		end
	end,
	
	SetCallback = function(self, callback)
		self.callback = callback
	end
}

metaTable_Tween.__index = metaTable_Tween

function Tween(from, to, duration, ease_type, callback)
	local Tween = {
		from = from,
		to = to,
		duration = duration,
		ease_type = ease_type,
		callback = callback,
		value = from,
		time_left = duration,
		permanent = false,
		running = false
	}
	
	return setmetatable(Tween, metaTable_Tween)
end

local metaTable_TweenUnpacked = {
	Start = function(self)
		self.running = true
		self.start_time = SysTime()
		self.end_time = self.start_time + self.duration
		self.time_left = self.duration
		self.tween_type = tween_type(self.base_object)
		self.lerp_type_unpacked = type_to_function_unpacked[self.tween_type]
		
		all_tweens[self] = true
		running_tweens[self] = true
	end,
	
	Update = function(self)
		if self.running then
			local to = self.to
			local time = SysTime()
			self.time_left = self.end_time - time
			
			if time >= self.end_time then
				self.running = false
				self.value = to
				self.base_object = to
				
				if !self.permanent then
					all_tweens[self] = nil
					running_tweens[self] = nil
				end
				
				if self.callback != nil then
					self.callback()
				end
				
				return
			end
			
			local alpha = (time - self.start_time) / self.duration
			
			if self.tween_type == "number" then
				self.value = Lerp(self.from, to, self.ease_type(alpha))
			else
				local base_object = self.base_object
				self.lerp_type_unpacked(base_object, self.from, to, self.ease_type(alpha))
				self.value = base_object
			end
			
			local OnUpdate = self.OnUpdate
			
			if OnUpdate and isfunction(OnUpdate) then
				self:OnUpdate()
			end
		end
	end
}

table_Inherit(metaTable_TweenUnpacked, metaTable_Tween)

metaTable_TweenUnpacked.__index = metaTable_TweenUnpacked

function TweenUnpacked(base_object, from, to, duration, ease_type, callback)
	local Tween = {
		base_object = base_object,
		from = from,
		to = to,
		duration = duration,
		ease_type = ease_type,
		callback = callback,
		value = from,
		time_left = duration,
		permanent = false,
		running = false
	}
	
	return setmetatable(Tween, metaTable_TweenUnpacked)
end

local metaTable_BezierTween = {
	Start = function(self)
		self.running = true
		self.start_time = SysTime()
		self.end_time = self.start_time + self.duration
		self.time_left = self.duration
		self.value = self.points[1]
		
		all_tweens[self] = true
		running_tweens[self] = true
	end,
	
	Update = function(self)
		if self.running then
			local points = self.points
			local time = SysTime()
			self.time_left = self.end_time - time
			
			if time >= self.end_time then
				self.running = false
				self.value = points[#points]
				
				if !self.permanent then
					all_tweens[self] = nil
					running_tweens[self] = nil
				end
				
				if self.callback != nil then
					self.callback(self)
				end
				
				return
			end
			
			local alpha = (time - self.start_time) / self.duration
			
			self.value = BSpline(points, self.ease_type(alpha))
			
			local OnUpdate = self.OnUpdate
			
			if OnUpdate and isfunction(OnUpdate) then
				self:OnUpdate()
			end
		end
	end,
}

table_Inherit(metaTable_BezierTween, metaTable_Tween)

metaTable_BezierTween.__index = metaTable_BezierTween

function BezierTween(points, duration, ease_type, callback)
	local Tween = {
		points = points,
		duration = duration,
		ease_type = ease_type,
		callback = callback,
		value = points[1],
		time_left = duration,
		permanent = false,
		running = false,
	}
	
	return setmetatable(Tween, metaTable_BezierTween)
end

hook.Add("Think", "process_tweens", function()
	if table.IsEmpty(running_tweens) then return end
	
	for tween in next, running_tweens do
		if tween == nil then continue end
		
		tween:Update()
	end
end)