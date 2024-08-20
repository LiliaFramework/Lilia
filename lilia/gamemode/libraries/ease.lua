--- Helper library for creating and managing easing functions used in animations.
-- @library lia.ease

lia.ease = lia.ease or {}
local pow = math.pow
local sin = math.sin
local pi = math.pi
local easeIn, easeOut, easeInOut, easeOutIn
local easeInBack, easeOutBack, easeInOutBack, easeOutInBack
local easeInElastic, easeOutElastic, easeInOutElastic, easeOutInElastic
local easeInBounce, easeOutBounce, easeInOutBounce, easeOutInBounce

--- Performs an ease-in interpolation for smooth animation.
-- This function applies an ease-in cubic function to the input time `t`, resulting in a gradual acceleration from the starting value.
-- The transition starts slowly and then speeds up as it progresses.
-- @realm client
-- @float t The current time (or progress) of the animation.
-- @float tMax The maximum time for the animation to complete.
-- @float start The starting value of the animation.
-- @float delta The total change in value by the end of the animation.
-- @return number The interpolated value at the current time `t`.
function lia.ease.easeIn(t, tMax, start, delta)
    return start + (delta * easeIn(t / tMax))
end

--- Performs an ease-out interpolation for smooth animation.
-- This function applies an ease-out cubic function to the input time `t`, creating a deceleration effect where the animation starts quickly and then slows down towards the end.
-- @realm client
-- @float t The current time (or progress) of the animation.
-- @float tMax The maximum time for the animation to complete.
-- @float start The starting value of the animation.
-- @float delta The total change in value by the end of the animation.
-- @return number The interpolated value at the current time `t`.
function lia.ease.easeOut(t, tMax, start, delta)
    return start + (delta * easeOut(t / tMax))
end

--- Performs an ease-in-out interpolation for smooth animation.
-- This function combines ease-in and ease-out cubic functions to create a smooth transition where the animation starts slowly, accelerates in the middle, and then decelerates towards the end.
-- @realm client
-- @float t The current time (or progress) of the animation.
-- @float tMax The maximum time for the animation to complete.
-- @float start The starting value of the animation.
-- @float delta The total change in value by the end of the animation.
-- @return number The interpolated value at the current time `t`.
function lia.ease.easeInOut(t, tMax, start, delta)
    return start + (delta * easeInOut(t / tMax))
end

--- Performs an ease-out-in interpolation for smooth animation.
-- This function starts with an ease-out effect (decelerating) and then transitions into an ease-in effect (accelerating), providing a smooth animation where the middle part is the fastest.
-- @realm client
-- @float t The current time (or progress) of the animation.
-- @float tMax The maximum time for the animation to complete.
-- @float start The starting value of the animation.
-- @float delta The total change in value by the end of the animation.
-- @return number The interpolated value at the current time `t`.
function lia.ease.easeOutIn(t, tMax, start, delta)
    return start + (delta * easeOutIn(t / tMax))
end

--- Performs an ease-in-back interpolation with an overshoot effect.
-- This function starts the animation with a backward motion before moving forward, creating a "pull back" effect. It accelerates after the initial backward movement.
-- @realm client
-- @float t The current time (or progress) of the animation.
-- @float tMax The maximum time for the animation to complete.
-- @float start The starting value of the animation.
-- @float delta The total change in value by the end of the animation.
-- @return number The interpolated value at the current time `t`.
function lia.ease.easeInBack(t, tMax, start, delta)
    return start + (delta * easeInBack(t / tMax))
end

--- Performs an ease-out-back interpolation with an overshoot effect.
-- This function ends the animation with a forward overshoot before settling back to the final value, creating a bounce-like effect at the end.
-- @realm client
-- @float t The current time (or progress) of the animation.
-- @float tMax The maximum time for the animation to complete.
-- @float start The starting value of the animation.
-- @float delta The total change in value by the end of the animation.
-- @return number The interpolated value at the current time `t`.
function lia.ease.easeOutBack(t, tMax, start, delta)
    return start + (delta * easeOutBack(t / tMax))
end

--- Performs an ease-in-out-back interpolation with overshoot effects at both ends.
-- This function combines ease-in-back and ease-out-back effects, starting with a backward motion and ending with a forward overshoot, creating a dynamic and elastic transition.
-- @realm client
-- @float t The current time (or progress) of the animation.
-- @float tMax The maximum time for the animation to complete.
-- @float start The starting value of the animation.
-- @float delta The total change in value by the end of the animation.
-- @return number The interpolated value at the current time `t`.
function lia.ease.easeInOutBack(t, tMax, start, delta)
    return start + (delta * easeInOutBack(t / tMax))
end

--- Performs an ease-out-in-back interpolation with overshoot effects.
-- This function starts with an ease-out-back effect, creating a forward overshoot, and then transitions into an ease-in-back effect with a backward motion, providing a complex and lively animation.
-- @realm client
-- @float t The current time (or progress) of the animation.
-- @float tMax The maximum time for the animation to complete.
-- @float start The starting value of the animation.
-- @float delta The total change in value by the end of the animation.
-- @return number The interpolated value at the current time `t`.
function lia.ease.easeOutInBack(t, tMax, start, delta)
    return start + (delta * easeOutInBack(t / tMax))
end

--- Performs an ease-in-elastic interpolation for a bouncy effect.
-- This function creates an elastic effect where the animation starts with a backward motion, then springs forward with increasing speed, resembling the motion of a spring being released.
-- @realm client
-- @float t The current time (or progress) of the animation.
-- @float tMax The maximum time for the animation to complete.
-- @float start The starting value of the animation.
-- @float delta The total change in value by the end of the animation.
-- @return number The interpolated value at the current time `t`.
function lia.ease.easeInElastic(t, tMax, start, delta)
    return start + (delta * easeInElastic(t / tMax))
end

--- Performs an ease-out-elastic interpolation for a bouncy effect.
-- This function creates an elastic effect where the animation slows down with a spring-like motion towards the end, providing a bouncy and lively finish.
-- @realm client
-- @float t The current time (or progress) of the animation.
-- @float tMax The maximum time for the animation to complete.
-- @float start The starting value of the animation.
-- @float delta The total change in value by the end of the animation.
-- @return number The interpolated value at the current time `t`.
function lia.ease.easeOutElastic(t, tMax, start, delta)
    return start + (delta * easeOutElastic(t / tMax))
end

--- Performs an ease-in-out-elastic interpolation for a bouncy effect.
-- This function combines ease-in-elastic and ease-out-elastic effects, where the animation starts and ends with a spring-like motion, providing a dynamic and elastic transition.
-- @realm client
-- @float t The current time (or progress) of the animation.
-- @float tMax The maximum time for the animation to complete.
-- @float start The starting value of the animation.
-- @float delta The total change in value by the end of the animation.
-- @return number The interpolated value at the current time `t`.
function lia.ease.easeInOutElastic(t, tMax, start, delta)
    return start + (delta * easeInOutElastic(t / tMax))
end

--- Performs an ease-out-in-elastic interpolation for a bouncy effect.
-- This function starts with an ease-out-elastic effect, providing a spring-like motion that transitions into an ease-in-elastic effect, where the animation springs back and forth, creating a lively and dynamic animation.
-- @realm client
-- @float t The current time (or progress) of the animation.
-- @float tMax The maximum time for the animation to complete.
-- @float start The starting value of the animation.
-- @float delta The total change in value by the end of the animation.
-- @return number The interpolated value at the current time `t`.
function lia.ease.easeOutInElastic(t, tMax, start, delta)
    return start + (delta * easeOutInElastic(t / tMax))
end

--- Performs an ease-in-bounce interpolation for a bounce effect.
-- This function creates a bounce effect where the animation starts with a rapid drop and then bounces upward, slowing down as it reaches the final value.
-- @realm client
-- @float t The current time (or progress) of the animation.
-- @float tMax The maximum time for the animation to complete.
-- @float start The starting value of the animation.
-- @float delta The total change in value by the end of the animation.
-- @return number The interpolated value at the current time `t`.
function lia.ease.easeInBounce(t, tMax, start, delta)
    return start + (delta * easeInBounce(t / tMax))
end

--- Performs an ease-out-bounce interpolation for a bounce effect.
-- This function creates a bounce effect where the animation starts quickly and then bounces towards the final value, providing a playful and dynamic finish.
-- @realm client
-- @float t The current time (or progress) of the animation.
-- @float tMax The maximum time for the animation to complete.
-- @float start The starting value of the animation.
-- @float delta The total change in value by the end of the animation.
-- @return number The interpolated value at the current time `t`.
function lia.ease.easeOutBounce(t, tMax, start, delta)
    return start + (delta * easeOutBounce(t / tMax))
end

--- Performs an ease-in-out-bounce interpolation for a bounce effect.
-- This function combines ease-in-bounce and ease-out-bounce effects, creating an animation that starts and ends with a bounce, providing a dynamic and playful transition.
-- @realm client
-- @float t The current time (or progress) of the animation.
-- @float tMax The maximum time for the animation to complete.
-- @float start The starting value of the animation.
-- @float delta The total change in value by the end of the animation.
-- @return number The interpolated value at the current time `t`.
function lia.ease.easeInOutBounce(t, tMax, start, delta)
    return start + (delta * easeInOutBounce(t / tMax))
end

--- Performs an ease-out-in-bounce interpolation for a bounce effect.
-- This function starts with an ease-out-bounce effect, where the animation quickly drops and then bounces towards the middle, transitioning into an ease-in-bounce effect, creating a lively and playful animation throughout.
-- @realm client
-- @float t The current time (or progress) of the animation.
-- @float tMax The maximum time for the animation to complete.
-- @float start The starting value of the animation.
-- @float delta The total change in value by the end of the animation.
-- @return number The interpolated value at the current time `t`.
function lia.ease.easeOutInBounce(t, tMax, start, delta)
    return start + (delta * easeOutInBounce(t / tMax))
end

easeInBounce = function(ratio) return 1.0 - easeOutBounce(1.0 - ratio) end
easeOutBounce = function(ratio)
    local s = 7.5625
    local p = 2.75
    local l
    if ratio < (1.0 / p) then
        l = s * pow(ratio, 2.0)
    else
        if ratio < (2.0 / p) then
            ratio = ratio - (1.5 / p)
            l = s * pow(ratio, 2.0) + 0.75
        else
            if ratio < (2.5 / p) then
                ratio = ratio - (2.25 / p)
                l = s * pow(ratio, 2.0) + 0.9375
            else
                ratio = ratio - (2.65 / p)
                l = s * pow(ratio, 2.0) + 0.984375
            end
        end
    end
    return l
end

easeInOutBounce = function(ratio)
    if ratio < 0.5 then
        return 0.5 * easeInBounce(ratio * 2.0)
    else
        return 0.5 * easeOutBounce((ratio - 0.5) * 2.0) + 0.5
    end
end

easeOutInBounce = function(ratio)
    if ratio < 0.5 then
        return 0.5 * easeOutBounce(ratio * 2.0)
    else
        return 0.5 * easeInBounce((ratio - 0.5) * 2.0) + 0.5
    end
end

easeInElastic = function(ratio)
    if ratio == 0 or ratio == 1.0 then return ratio end
    local p = 0.3
    local s = p / 4.0
    local invRatio = ratio - 1.0
    return -1 * pow(2.0, 10.0 * invRatio) * sin((invRatio - s) * 2 * pi / p)
end

easeOutElastic = function(ratio)
    if ratio == 0 or ratio == 1.0 then return ratio end
    local p = 0.3
    local s = p / 4.0
    return -1 * pow(2.0, -10.0 * ratio) * sin((ratio + s) * 2 * pi / p) + 1.0
end

easeInOutElastic = function(ratio)
    if ratio < 0.5 then
        return 0.5 * easeInElastic(ratio * 2.0)
    else
        return 0.5 * easeOutElastic((ratio - 0.5) * 2.0) + 0.5
    end
end

easeOutInElastic = function(ratio)
    if ratio < 0.5 then
        return 0.5 * easeOutElastic(ratio * 2.0)
    else
        return 0.5 * easeInElastic((ratio - 0.5) * 2.0) + 0.5
    end
end

easeIn = function(ratio) return ratio * ratio * ratio end
easeOut = function(ratio)
    local invRatio = ratio - 1.0
    return (invRatio * invRatio * invRatio) + 1.0
end

easeInOut = function(ratio)
    if ratio < 0.5 then
        return 0.5 * easeIn(ratio * 2.0)
    else
        return 0.5 * easeOut((ratio - 0.5) * 2.0) + 0.5
    end
end

easeOutIn = function(ratio)
    if ratio < 0.5 then
        return 0.5 * easeOut(ratio * 2.0)
    else
        return 0.5 * easeIn((ratio - 0.5) * 2.0) + 0.5
    end
end

easeInBack = function(ratio)
    local s = 1.70158
    return pow(ratio, 2.0) * ((s + 1.0) * ratio - s)
end

easeOutBack = function(ratio)
    local invRatio = ratio - 1.0
    local s = 1.70158
    return pow(invRatio, 2.0) * ((s + 1.0) * invRatio + s) + 1.0
end

easeInOutBack = function(ratio)
    if ratio < 0.5 then
        return 0.5 * easeInBack(ratio * 2.0)
    else
        return 0.5 * easeOutBack((ratio - 0.5) * 2.0) + 0.5
    end
end

easeOutInBack = function(ratio)
    if ratio < 0.5 then
        return 0.5 * easeOutBack(ratio * 2.0)
    else
        return 0.5 * easeInBack((ratio - 0.5) * 2.0) + 0.5
    end
end