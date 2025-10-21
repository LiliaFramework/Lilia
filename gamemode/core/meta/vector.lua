--[[
    Vector Meta Table

    This file extends the base Vector metatable in Garry's Mod with additional mathematical
    and geometric operations. It provides enhanced functionality for 3D vector calculations
    including distance measurements, rotational transformations around arbitrary axes, and
    directional vector calculations for right and up vectors. These meta methods are essential
    for advanced 3D mathematics, camera systems, movement calculations, and spatial
    transformations in the Lilia framework. The meta table operates on both server and client
    sides, providing consistent vector operations across the entire gamemode.
]]
local vectorMeta = FindMetaTable("Vector")
--[[
    Purpose: Calculate the Euclidean distance between two 3D vectors
    When Called: When you need to measure the straight-line distance between two points in 3D space
    Parameters:
        vec2 - Vector: The second vector to calculate distance to
    Returns: number - The distance between the two vectors
    Realm: Both client and server
    Example Usage:
        Low Complexity:
        ```lua
        local vec1 = Vector(0, 0, 0)
        local vec2 = Vector(5, 0, 0)
        local distance = vec1:distance(vec2) -- Returns 5
        ```

        Medium Complexity:
        ```lua
        local playerPos = player:GetPos()
        local targetPos = target:GetPos()
        local dist = playerPos:distance(targetPos)
        if dist < 100 then
            player:ChatPrint("Target is close!")
        end
        ```

        High Complexity:
        ```lua
        local positions = {Vector(0, 0, 0), Vector(10, 0, 0), Vector(0, 10, 0), Vector(10, 10, 0)}
        local totalDistance = 0
        for i = 2, #positions do
            totalDistance = totalDistance + positions[i-1]:distance(positions[i])
        end
        print("Total path length: " .. totalDistance)
        ```
]]
function vectorMeta:distance(vec2)
    local x, y, z = self.x, self.y, self.z
    local x2, y2, z2 = vec2.x, vec2.y, vec2.z
    return math.sqrt((x - x2) ^ 2 + (y - y2) ^ 2 + (z - z2) ^ 2)
end

--[[
    Purpose: Rotate the vector around an arbitrary axis by a specified number of degrees
    When Called: When you need to rotate a direction vector or position around a custom axis for camera movement, object rotation, or 3D transformations
    Parameters:
        axis - Vector: The axis to rotate around (should be normalized for predictable results)
        degrees - number: The rotation angle in degrees (positive for clockwise, negative for counter-clockwise)
    Returns: Vector - A new vector representing the rotated position/direction
    Realm: Both client and server
    Example Usage:
        Low Complexity:
        ```lua
        local vec = Vector(1, 0, 0)
        local axis = Vector(0, 0, 1) -- Z-axis
        local rotated = vec:rotateAroundAxis(axis, 90) -- Returns Vector(0, 1, 0)
        ```

        Medium Complexity:
        ```lua
        local cameraPos = Vector(10, 0, 5)
        local lookAt = Vector(0, 0, 0)
        local direction = (lookAt - cameraPos):GetNormalized()
        local upAxis = Vector(0, 0, 1)
        local rotatedDirection = direction:rotateAroundAxis(upAxis, 45)
        ```

        High Complexity:
        ```lua
        -- Rotate multiple points around a custom axis
        local axis = Vector(1, 1, 0):GetNormalized()
        local points = {Vector(5, 0, 0), Vector(0, 5, 0), Vector(0, 0, 5)}
        local rotatedPoints = {}

        for i, point in ipairs(points) do
            local rotated = point:rotateAroundAxis(axis, 90)
            table.insert(rotatedPoints, rotated)
        end

        -- Use rotated points for complex 3D transformations
        ```
]]
function vectorMeta:rotateAroundAxis(axis, degrees)
    local rad = math.rad(degrees)
    local cosTheta = math.cos(rad)
    local sinTheta = math.sin(rad)
    return Vector(cosTheta * self.x + sinTheta * (axis.y * self.z - axis.z * self.y), cosTheta * self.y + sinTheta * (axis.z * self.x - axis.x * self.z), cosTheta * self.z + sinTheta * (axis.x * self.y - axis.y * self.x))
end

local right = Vector(0, -1, 0)
--[[
    Purpose: Calculate the right vector relative to this vector and an up vector using the cross product
    When Called: When you need to determine the right direction in a 3D coordinate system, commonly used for camera control, movement systems, and 3D transformations
    Parameters:
        vUp - Vector (optional): The up vector to use for the cross product calculation. Defaults to vector_up if not provided
    Returns: Vector - A normalized vector pointing to the right relative to the current vector and up vector
    Realm: Both client and server
    Example Usage:
        Low Complexity:
        ```lua
        local forward = Vector(1, 0, 0)
        local right = forward:right() -- Returns Vector(0, -1, 0) assuming default up vector
        ```

        Medium Complexity:
        ```lua
        local playerForward = player:GetAimVector()
        local rightVector = playerForward:right()
        local strafeInput = input.GetAnalogValue("strafe_right") or 0
        local movement = rightVector * strafeInput * speed
        ```

        High Complexity:
        ```lua
        -- Calculate a full 3D coordinate system
        local forward = Vector(1, 0, 0)
        local up = Vector(0, 0, 1)
        local right = forward:right(up)

        -- Create transformation matrix for complex 3D operations
        local transformMatrix = Matrix()
        transformMatrix:SetForward(forward)
        transformMatrix:SetRight(right)
        transformMatrix:SetUp(up)

        -- Apply transformation to multiple objects
        for _, obj in ipairs(objects) do
            obj:SetPos(obj:GetPos() + movementVector)
        end
        ```
]]
function vectorMeta:right(vUp)
    if self[1] == 0 and self[2] == 0 then return right end
    if not vUp then vUp = vector_up end
    local vRet = self:Cross(self, vUp)
    vRet:Normalize()
    return vRet
end

--[[
    Purpose: Calculate the up vector relative to this vector and a reference up vector using double cross product
    When Called: When you need to determine the up direction in a 3D coordinate system, essential for camera orientation, movement systems, and maintaining consistent coordinate frames
    Parameters:
        vUp - Vector (optional): The reference up vector to use for the cross product calculations. Defaults to vector_up if not provided
    Returns: Vector - A normalized vector pointing upward relative to the current vector and reference up vector
    Realm: Both client and server
    Example Usage:
        Low Complexity:
        ```lua
        local forward = Vector(1, 0, 0)
        local up = forward:up() -- Returns Vector(0, 0, -1) assuming default up vector
        ```

        Medium Complexity:
        ```lua
        local playerForward = player:GetAimVector()
        local upVector = playerForward:up()
        local verticalInput = input.GetAnalogValue("move_up") or 0
        local verticalMovement = upVector * verticalInput * speed
        ```

        High Complexity:
        ```lua
        -- Create a stable coordinate system for complex camera movement
        local lookDirection = (targetPos - cameraPos):GetNormalized()
        local worldUp = Vector(0, 0, 1)

        -- Calculate orthogonal basis vectors
        local rightVector = lookDirection:right(worldUp)
        local upVector = lookDirection:up(worldUp)

        -- Smooth camera transitions with proper orientation
        local targetMatrix = Matrix()
        targetMatrix:SetForward(lookDirection)
        targetMatrix:SetRight(rightVector)
        targetMatrix:SetUp(upVector)

        -- Interpolate camera matrices for smooth movement
        local currentMatrix = camera:GetMatrix()
        local smoothMatrix = LerpMatrix(smoothFactor, currentMatrix, targetMatrix)
        camera:SetMatrix(smoothMatrix)
        ```
]]
function vectorMeta:up(vUp)
    if self[1] == 0 and self[2] == 0 then return Vector(-self[3], 0, 0) end
    if not vUp then vUp = vector_up end
    local vRet = self:Cross(self, vUp)
    vRet = self:Cross(vRet, self)
    vRet:Normalize()
    return vRet
end
