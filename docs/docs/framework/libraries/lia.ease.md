# lia.ease

---

The `lia.ease` library provides a comprehensive set of easing functions to facilitate smooth and visually appealing animations within the Lilia Framework. These functions interpolate values over time, allowing for various animation effects such as bouncing, elastic movements, and backtracking motions. By leveraging these easing functions, developers can create more dynamic and engaging user experiences in their games or applications.

**NOTE:** Always ensure that the time (`t`) and duration (`tMax`) parameters are correctly managed to achieve the desired animation effects without causing unexpected behavior.

---

### **lia.ease.easeIn**

**Description:**  
Eases in the value over time using a cubic easing function. The animation starts slowly and accelerates towards the end.

**Realm:**  
`Client`

**Parameters:**  

- `t` (`float`): Time elapsed.
- `tMax` (`float`): The total duration of the animation.
- `start` (`float`): The starting value of the animation.
- `delta` (`float`): The total change in value to be applied.

**Returns:**  
`number` - The eased value at the given time.

**Example Usage:**
```lua
local currentTime = 0
local duration = 2 -- seconds
local startValue = 0
local changeInValue = 100

-- In a loop or timed callback
currentTime = currentTime + FrameTime()
if currentTime <= duration then
    local easedValue = lia.ease.easeIn(currentTime, duration, startValue, changeInValue)
    print("Eased Value:", easedValue)
end
```

---

### **lia.ease.easeOut**

**Description:**  
Eases out the value over time using a cubic easing function. The animation starts quickly and decelerates towards the end.

**Realm:**  
`Client`

**Parameters:**  

- `t` (`float`): Time elapsed.
- `tMax` (`float`): The total duration of the animation.
- `start` (`float`): The starting value of the animation.
- `delta` (`float`): The total change in value to be applied.

**Returns:**  
`number` - The eased value at the given time.

**Example Usage:**
```lua
local currentTime = 0
local duration = 2 -- seconds
local startValue = 0
local changeInValue = 100

-- In a loop or timed callback
currentTime = currentTime + FrameTime()
if currentTime <= duration then
    local easedValue = lia.ease.easeOut(currentTime, duration, startValue, changeInValue)
    print("Eased Value:", easedValue)
end
```

---

### **lia.ease.easeInOut**

**Description:**  
Eases in and out the value over time using a cubic easing function. The animation starts slowly, accelerates in the middle, and slows down towards the end.

**Realm:**  
`Client`

**Parameters:**  

- `t` (`float`): Time elapsed.
- `tMax` (`float`): The total duration of the animation.
- `start` (`float`): The starting value of the animation.
- `delta` (`float`): The total change in value to be applied.

**Returns:**  
`number` - The eased value at the given time.

**Example Usage:**
```lua
local currentTime = 0
local duration = 2 -- seconds
local startValue = 0
local changeInValue = 100

-- In a loop or timed callback
currentTime = currentTime + FrameTime()
if currentTime <= duration then
    local easedValue = lia.ease.easeInOut(currentTime, duration, startValue, changeInValue)
    print("Eased Value:", easedValue)
end
```

---

### **lia.ease.easeOutIn**

**Description:**  
Eases out and then in the value over time using a cubic easing function. The animation starts quickly, slows down in the middle, and speeds up towards the end.

**Realm:**  
`Client`

**Parameters:**  

- `t` (`float`): Time elapsed.
- `tMax` (`float`): The total duration of the animation.
- `start` (`float`): The starting value of the animation.
- `delta` (`float`): The total change in value to be applied.

**Returns:**  
`number` - The eased value at the given time.

**Example Usage:**
```lua
local currentTime = 0
local duration = 2 -- seconds
local startValue = 0
local changeInValue = 100

-- In a loop or timed callback
currentTime = currentTime + FrameTime()
if currentTime <= duration then
    local easedValue = lia.ease.easeOutIn(currentTime, duration, startValue, changeInValue)
    print("Eased Value:", easedValue)
end
```

---

### **lia.ease.easeInBack**

**Description:**  
Eases in the value with a back effect. The animation overshoots the starting point slightly before moving towards the target value, creating a "pull-back" motion.

**Realm:**  
`Client`

**Parameters:**  

- `t` (`float`): Time elapsed.
- `tMax` (`float`): The total duration of the animation.
- `start` (`float`): The starting value of the animation.
- `delta` (`float`): The total change in value to be applied.

**Returns:**  
`number` - The eased value at the given time.

**Example Usage:**
```lua
local currentTime = 0
local duration = 2 -- seconds
local startValue = 0
local changeInValue = 100

-- In a loop or timed callback
currentTime = currentTime + FrameTime()
if currentTime <= duration then
    local easedValue = lia.ease.easeInBack(currentTime, duration, startValue, changeInValue)
    print("Eased Value with Back Effect:", easedValue)
end
```

---

### **lia.ease.easeOutBack**

**Description:**  
Eases out the value with a back effect. The animation overshoots the target value slightly before settling back, creating a "push-forward" motion.

**Realm:**  
`Client`

**Parameters:**  

- `t` (`float`): Time elapsed.
- `tMax` (`float`): The total duration of the animation.
- `start` (`float`): The starting value of the animation.
- `delta` (`float`): The total change in value to be applied.

**Returns:**  
`number` - The eased value at the given time.

**Example Usage:**
```lua
local currentTime = 0
local duration = 2 -- seconds
local startValue = 0
local changeInValue = 100

-- In a loop or timed callback
currentTime = currentTime + FrameTime()
if currentTime <= duration then
    local easedValue = lia.ease.easeOutBack(currentTime, duration, startValue, changeInValue)
    print("Eased Value with Back Effect:", easedValue)
end
```

---

### **lia.ease.easeInOutBack**

**Description:**  
Eases in and out the value with a back effect. The animation overshoots both the starting and target values, creating a dynamic "pull-back and push-forward" motion.

**Realm:**  
`Client`

**Parameters:**  

- `t` (`float`): Time elapsed.
- `tMax` (`float`): The total duration of the animation.
- `start` (`float`): The starting value of the animation.
- `delta` (`float`): The total change in value to be applied.

**Returns:**  
`number` - The eased value at the given time.

**Example Usage:**
```lua
local currentTime = 0
local duration = 2 -- seconds
local startValue = 0
local changeInValue = 100

-- In a loop or timed callback
currentTime = currentTime + FrameTime()
if currentTime <= duration then
    local easedValue = lia.ease.easeInOutBack(currentTime, duration, startValue, changeInValue)
    print("Eased Value with Back Effect:", easedValue)
end
```

---

### **lia.ease.easeOutInBack**

**Description:**  
Eases out and then in the value with a back effect. The animation first overshoots the target value before pulling back towards it, creating a "push-forward and pull-back" motion.

**Realm:**  
`Client`

**Parameters:**  

- `t` (`float`): Time elapsed.
- `tMax` (`float`): The total duration of the animation.
- `start` (`float`): The starting value of the animation.
- `delta` (`float`): The total change in value to be applied.

**Returns:**  
`number` - The eased value at the given time.

**Example Usage:**
```lua
local currentTime = 0
local duration = 2 -- seconds
local startValue = 0
local changeInValue = 100

-- In a loop or timed callback
currentTime = currentTime + FrameTime()
if currentTime <= duration then
    local easedValue = lia.ease.easeOutInBack(currentTime, duration, startValue, changeInValue)
    print("Eased Value with Back Effect:", easedValue)
end
```

---

### **lia.ease.easeInElastic**

**Description:**  
Eases in the value with an elastic effect. The animation starts with a spring-like motion, overshooting the target and oscillating before settling.

**Realm:**  
`Client`

**Parameters:**  

- `t` (`float`): Time elapsed.
- `tMax` (`float`): The total duration of the animation.
- `start` (`float`): The starting value of the animation.
- `delta` (`float`): The total change in value to be applied.

**Returns:**  
`number` - The eased value at the given time.

**Example Usage:**
```lua
local currentTime = 0
local duration = 2 -- seconds
local startValue = 0
local changeInValue = 100

-- In a loop or timed callback
currentTime = currentTime + FrameTime()
if currentTime <= duration then
    local easedValue = lia.ease.easeInElastic(currentTime, duration, startValue, changeInValue)
    print("Eased Value with Elastic Effect:", easedValue)
end
```

---

### **lia.ease.easeOutElastic**

**Description:**  
Eases out the value with an elastic effect. The animation overshoots the target value and oscillates before settling, creating a spring-like motion at the end.

**Realm:**  
`Client`

**Parameters:**  

- `t` (`float`): Time elapsed.
- `tMax` (`float`): The total duration of the animation.
- `start` (`float`): The starting value of the animation.
- `delta` (`float`): The total change in value to be applied.

**Returns:**  
`number` - The eased value at the given time.

**Example Usage:**
```lua
local currentTime = 0
local duration = 2 -- seconds
local startValue = 0
local changeInValue = 100

-- In a loop or timed callback
currentTime = currentTime + FrameTime()
if currentTime <= duration then
    local easedValue = lia.ease.easeOutElastic(currentTime, duration, startValue, changeInValue)
    print("Eased Value with Elastic Effect:", easedValue)
end
```

---

### **lia.ease.easeInOutElastic**

**Description:**  
Eases in and out the value with an elastic effect. The animation starts and ends with spring-like motions, providing a dynamic and bouncy transition.

**Realm:**  
`Client`

**Parameters:**  

- `t` (`float`): Time elapsed.
- `tMax` (`float`): The total duration of the animation.
- `start` (`float`): The starting value of the animation.
- `delta` (`float`): The total change in value to be applied.

**Returns:**  
`number` - The eased value at the given time.

**Example Usage:**
```lua
local currentTime = 0
local duration = 2 -- seconds
local startValue = 0
local changeInValue = 100

-- In a loop or timed callback
currentTime = currentTime + FrameTime()
if currentTime <= duration then
    local easedValue = lia.ease.easeInOutElastic(currentTime, duration, startValue, changeInValue)
    print("Eased Value with Elastic Effect:", easedValue)
end
```

---

### **lia.ease.easeOutInElastic**

**Description:**  
Eases out and then in the value with an elastic effect. The animation first overshoots the target with a spring-like motion and then pulls back towards it.

**Realm:**  
`Client`

**Parameters:**  

- `t` (`float`): Time elapsed.
- `tMax` (`float`): The total duration of the animation.
- `start` (`float`): The starting value of the animation.
- `delta` (`float`): The total change in value to be applied.

**Returns:**  
`number` - The eased value at the given time.

**Example Usage:**
```lua
local currentTime = 0
local duration = 2 -- seconds
local startValue = 0
local changeInValue = 100

-- In a loop or timed callback
currentTime = currentTime + FrameTime()
if currentTime <= duration then
    local easedValue = lia.ease.easeOutInElastic(currentTime, duration, startValue, changeInValue)
    print("Eased Value with Elastic Effect:", easedValue)
end
```

---

### **lia.ease.easeInBounce**

**Description:**  
Eases in the value with a bounce effect. The animation starts by bouncing into the target value, creating a playful and dynamic motion.

**Realm:**  
`Client`

**Parameters:**  

- `t` (`float`): Time elapsed.
- `tMax` (`float`): The total duration of the animation.
- `start` (`float`): The starting value of the animation.
- `delta` (`float`): The total change in value to be applied.

**Returns:**  
`number` - The eased value at the given time.

**Example Usage:**
```lua
local currentTime = 0
local duration = 2 -- seconds
local startValue = 0
local changeInValue = 100

-- In a loop or timed callback
currentTime = currentTime + FrameTime()
if currentTime <= duration then
    local easedValue = lia.ease.easeInBounce(currentTime, duration, startValue, changeInValue)
    print("Eased Value with Bounce Effect:", easedValue)
end
```

---

### **lia.ease.easeOutBounce**

**Description:**  
Eases out the value with a bounce effect. The animation overshoots the target and bounces back, providing a lively and engaging transition.

**Realm:**  
`Client`

**Parameters:**  

- `t` (`float`): Time elapsed.
- `tMax` (`float`): The total duration of the animation.
- `start` (`float`): The starting value of the animation.
- `delta` (`float`): The total change in value to be applied.

**Returns:**  
`number` - The eased value at the given time.

**Example Usage:**
```lua
local currentTime = 0
local duration = 2 -- seconds
local startValue = 0
local changeInValue = 100

-- In a loop or timed callback
currentTime = currentTime + FrameTime()
if currentTime <= duration then
    local easedValue = lia.ease.easeOutBounce(currentTime, duration, startValue, changeInValue)
    print("Eased Value with Bounce Effect:", easedValue)
end
```

---

### **lia.ease.easeInOutBounce**

**Description:**  
Eases in and out the value with a bounce effect. The animation starts with a bounce into the target and ends with a bounce out, creating a dynamic and playful motion.

**Realm:**  
`Client`

**Parameters:**  

- `t` (`float`): Time elapsed.
- `tMax` (`float`): The total duration of the animation.
- `start` (`float`): The starting value of the animation.
- `delta` (`float`): The total change in value to be applied.

**Returns:**  
`number` - The eased value at the given time.

**Example Usage:**
```lua
local currentTime = 0
local duration = 2 -- seconds
local startValue = 0
local changeInValue = 100

-- In a loop or timed callback
currentTime = currentTime + FrameTime()
if currentTime <= duration then
    local easedValue = lia.ease.easeInOutBounce(currentTime, duration, startValue, changeInValue)
    print("Eased Value with Bounce Effect:", easedValue)
end
```

---

### **lia.ease.easeOutInBounce**

**Description:**  
Eases out and then in the value with a bounce effect. The animation first bounces out of the target and then bounces back in, creating a lively transition.

**Realm:**  
`Client`

**Parameters:**  

- `t` (`float`): Time elapsed.
- `tMax` (`float`): The total duration of the animation.
- `start` (`float`): The starting value of the animation.
- `delta` (`float`): The total change in value to be applied.

**Returns:**  
`number` - The eased value at the given time.

**Example Usage:**
```lua
local currentTime = 0
local duration = 2 -- seconds
local startValue = 0
local changeInValue = 100

-- In a loop or timed callback
currentTime = currentTime + FrameTime()
if currentTime <= duration then
    local easedValue = lia.ease.easeOutInBounce(currentTime, duration, startValue, changeInValue)
    print("Eased Value with Bounce Effect:", easedValue)
end
```

---

### **lia.ease.InOutCirc**

**Description:**  
Eases in and out a value over time using a circular easing function. The animation follows a circular motion pattern, providing a smooth and natural transition.

**Realm:**  
`Client`

**Parameters:**  

- `t` (`float`): The current time elapsed, normalized between 0 and 1.

**Returns:**  
`number` - The eased value based on the circular easing function.

**Example Usage:**
```lua
local normalizedTime = 0.5 -- halfway through the animation
local easedValue = lia.ease.InOutCirc(normalizedTime)
print("Eased Value with Circular Effect:", easedValue)
```

---

