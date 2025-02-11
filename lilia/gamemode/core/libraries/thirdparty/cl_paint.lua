do
    if not is64Bits() then
        local vec = Vector()
        local vecSetUnpacked = vec.SetUnpacked
        mesh.OldPosition = mesh.OldPosition or mesh.Position
        function mesh.Position(x, y, z)
            if y == nil then
                mesh.OldPosition(x)
                return
            end

            vecSetUnpacked(vec, x, y, z)
            mesh.OldPosition(vec)
        end
    end
end

do
    local paint = {}
    do
        paint.Z = 0
        function paint.resetZ()
            paint.Z = 0
        end

        function paint.incrementZ()
            paint.Z = paint.Z + 1
            if paint.Z > 16384 then paint.resetZ() end
            return paint.getZ()
        end

        function paint.getZ()
            return -1 + paint.Z / 8192
        end
    end

    do
        local tab = {}
        local len = 0
        local setScissorRect = render.SetScissorRect
        local max = math.max
        local min = math.min
        function paint.pushScissorRect(x, y, endX, endY)
            local prev = tab[len]
            if prev then
                x = max(prev[1], x)
                y = max(prev[2], y)
                endX = min(prev[3], endX)
                endY = min(prev[4], endY)
            end

            len = len + 1
            tab[len] = {x, y, endX, endY}
            setScissorRect(x, y, endX, endY, true)
        end

        function paint.popScissorRect()
            tab[len] = nil
            len = max(0, len - 1)
            local newTab = tab[len]
            if newTab then
                setScissorRect(newTab[1], newTab[2], newTab[3], newTab[4], true)
            else
                setScissorRect(0, 0, 0, 0, false)
            end
        end
    end

    do
        local vector = Vector()
        local paintColoredMaterial = CreateMaterial("testMaterial" .. SysTime(), "UnlitGeneric", {
            ["$basetexture"] = "color/white",
            ["$model"] = 1,
            ["$translucent"] = 1,
            ["$vertexalpha"] = 1,
            ["$vertexcolor"] = 1
        })

        local recompute = paintColoredMaterial.Recompute
        local setVector = paintColoredMaterial.SetVector
        local setUnpacked = vector.SetUnpacked
        function paint.getColoredMaterial(color)
            setUnpacked(vector, color.r, color.g, color.b)
            setVector(paintColoredMaterial, '$color', vector)
            recompute(paintColoredMaterial)
            return paintColoredMaterial
        end
    end

    do
        local matrix = Matrix()
        local setField = matrix.SetField
        local pushModelMatrix = cam.PushModelMatrix
        local popModelMatrix = cam.PopModelMatrix
        local panelTab = FindMetaTable('Panel')
        local localToScreen = panelTab.LocalToScreen
        local getSize = panelTab.GetSize
        local pushScissorRect = paint.pushScissorRect
        local popScissorRect = paint.popScissorRect
        function paint.startPanel(panel, pos, boundaries, multiply)
            local x, y = localToScreen(panel, 0, 0)
            if pos or pos == nil then
                setField(matrix, 1, 4, x)
                setField(matrix, 2, 4, y)
                pushModelMatrix(matrix, multiply)
            end

            if boundaries then
                local w, h = getSize(panel)
                pushScissorRect(x, y, x + w, y + h)
            end
        end

        function paint.endPanel(pos, boundaries)
            if pos or pos == nil then popModelMatrix() end
            if boundaries then popScissorRect() end
        end

        do
            paint.beginPanel = paint.startPanel
            paint.stopPanel = paint.endPanel
        end

        function paint.bilinearInterpolation(x, y, leftTop, rightTop, rightBottom, leftBottom)
            if leftTop == rightTop and leftTop == rightBottom and leftTop == leftBottom then return leftTop end
            local top = leftTop == rightTop and leftTop or ((1 - x) * leftTop + x * rightTop)
            local bottom = leftBottom == rightBottom and leftBottom or ((1 - x) * leftBottom + x * rightBottom)
            return (1 - y) * top + y * bottom
        end
    end

    _G.paint = paint
end

do
    local paint = paint
    local batch = {}
    batch.batching = false
    local batchTable = {
        [0] = 0
    }

    function batch.reset()
        batchTable = {
            [0] = 0
        }

        batch.batchTable = batchTable
    end

    function batch.startBatching()
        batch.batching = true
        batch.reset()
    end

    local function getVariables(tab, i)
        return tab[i], tab[i + 1], tab[i + 2], tab[i + 3], tab[i + 4], tab[i + 5], tab[i + 6], tab[i + 7], tab[i + 8], tab[i + 9]
    end

    do
        local meshBegin = mesh.Begin
        local meshEnd = mesh.End
        local meshPosition = mesh.Position
        local meshColor = mesh.Color
        local meshAdvanceVertex = mesh.AdvanceVertex
        local meshConstructor = Mesh
        local PRIMITIVE_TRIANGLES = MATERIAL_TRIANGLES
        function batch.stopBatching()
            local tab = batch.batchTable
            local iMesh = meshConstructor()
            meshBegin(iMesh, PRIMITIVE_TRIANGLES, tab[0] * 0.3)
            for i = 1, tab[0], 10 do
                local x, y, z, color, x1, y1, color1, x2, y2, color2 = getVariables(tab, i)
                meshPosition(x, y, z)
                meshColor(color.r, color.g, color.b, color.a)
                meshAdvanceVertex()
                meshPosition(x1, y1, z)
                meshColor(color1.r, color1.g, color1.b, color1.a)
                meshAdvanceVertex()
                meshPosition(x2, y2, z)
                meshColor(color2.r, color2.g, color2.b, color2.a)
                meshAdvanceVertex()
            end

            meshEnd()
            batch.reset()
            batch.batching = false
            return iMesh
        end
    end

    do
        local startPanel, endPanel = paint.startPanel, paint.endPanel
        local meshDraw = FindMetaTable('IMesh').Draw
        local meshDestroy = FindMetaTable('IMesh').Destroy
        local resetZ = paint.resetZ
        local whiteMat = Material('vgui/white')
        local setMaterial = render.SetMaterial
        local startBatching = batch.startBatching
        local stopBatching = batch.stopBatching
        local panelPaint = function(self, x, y)
            local iMesh = self.iMesh
            if not iMesh then return end
            do
                local beforePaint = self.BeforePaint
                if beforePaint then beforePaint(self, x, y) end
            end

            local disableBoundaries = self.DisableBoundaries
            setMaterial(whiteMat)
            startPanel(self, true, disableBoundaries ~= true)
            meshDraw(iMesh)
            endPanel(true, disableBoundaries ~= true)
            do
                local afterPaint = self.AfterPaint
                if afterPaint then afterPaint(self, x, y) end
            end
        end

        local panelRebuildMesh = function(self, x, y)
            resetZ()
            local iMesh = self.iMesh
            if iMesh then meshDestroy(iMesh) end
            local drawFunc = self.PaintMesh
            if drawFunc then
                startBatching()
                drawFunc(self, x, y)
                self.iMesh = stopBatching()
            end

            resetZ()
        end

        local panelOnSizeChanged = function(self, x, y)
            local rebuildMesh = self.RebuildMesh
            if rebuildMesh then rebuildMesh(self, x, y) end
            local oldOnSizeChanged = self.OldOnSizeChanged
            if oldOnSizeChanged then oldOnSizeChanged(self, x, y) end
        end

        function batch.wrapPanel(panel)
            panel.Paint = panelPaint
            panel.OldOnSizeChanged = panel.OnSizeChanged
            panel.OnSizeChanged = panelOnSizeChanged
            panel.RebuildMesh = panelRebuildMesh
        end
    end

    do
        function batch.addTriangle(z, x1, y1, color1, x2, y2, color2, x3, y3, color3)
            local len = batchTable[0]
            batchTable[len + 1] = x1
            batchTable[len + 2] = y1
            batchTable[len + 3] = z
            batchTable[len + 4] = color1
            batchTable[len + 5] = x2
            batchTable[len + 6] = y2
            batchTable[len + 7] = color2
            batchTable[len + 8] = x3
            batchTable[len + 9] = y3
            batchTable[len + 10] = color3
            batchTable[0] = len + 10
        end
    end

    batch.batchTable = batchTable
    _G.paint.batch = batch
end

do
    local paint = paint
    local lines = {}
    local batch = {
        [0] = 0
    }

    local PRIMITIVE_LINES = MATERIAL_LINES
    local PRIMITIVE_LINE_STRIP = MATERIAL_LINE_STRIP
    local PRIMITIVE_LINE_LOOP = MATERIAL_LINE_LOOP
    do
        local meshBegin = mesh.Begin
        local meshEnd = mesh.End
        local meshPosition = mesh.Position
        local meshColor = mesh.Color
        local meshAdvanceVertex = mesh.AdvanceVertex
        local renderSetColorMaterialIgnoreZ = render.SetColorMaterialIgnoreZ
        function lines.drawSingleLine(startX, startY, endX, endY, startColor, endColor)
            if endColor == nil then endColor = startColor end
            renderSetColorMaterialIgnoreZ()
            meshBegin(PRIMITIVE_LINES, 1)
            meshColor(startColor.r, startColor.g, startColor.b, startColor.a)
            meshPosition(startX, startY, 0)
            meshAdvanceVertex()
            meshColor(endColor.r, endColor.g, endColor.b, endColor.a)
            meshPosition(endX, endY, 0)
            meshAdvanceVertex()
            meshEnd()
        end

        local counts = {
            [PRIMITIVE_LINES] = function(len) return len / 6 end,
            [PRIMITIVE_LINE_STRIP] = function(len) return len / 6 end,
            [PRIMITIVE_LINE_LOOP] = function(len) return len / 6 - 1 end
        }

        function lines.drawBatchedLines(array)
            local primitiveType = array[-1] or PRIMITIVE_LINES
            renderSetColorMaterialIgnoreZ()
            meshBegin(primitiveType, counts[primitiveType](array[0]))
            if primitiveType == PRIMITIVE_LINES then
                for i = 1, array[0], 6 do
                    local startX, startY, endX, endY = array[i], array[i + 1], array[i + 3], array[i + 4]
                    local startColor, endColor = array[i + 2], array[i + 5]
                    meshColor(startColor.r, startColor.g, startColor.b, startColor.a)
                    meshPosition(startX, startY, 0)
                    meshAdvanceVertex()
                    meshColor(endColor.r, endColor.g, endColor.b, endColor.a)
                    meshPosition(endX, endY, 0)
                    meshAdvanceVertex()
                end
            elseif primitiveType == PRIMITIVE_LINE_STRIP then
                meshPosition(array[1], array[2], 0)
                local startColor = array[3]
                meshColor(startColor.r, startColor.g, startColor.b, startColor.a)
                meshAdvanceVertex()
                for i = 4, array[0], 6 do
                    local x, y, color = array[i], array[i + 1], array[i + 2]
                    meshPosition(x, y, 0)
                    meshColor(color.r, color.g, color.b, color.a)
                    meshAdvanceVertex()
                end
            else
                meshPosition(array[1], array[2], 0)
                local startColor = array[3]
                meshColor(startColor.r, startColor.g, startColor.b, startColor.a)
                meshAdvanceVertex()
                for i = 4, array[0] - 3, 6 do
                    local x, y, color = array[i], array[i + 1], array[i + 2]
                    meshPosition(x, y, 0)
                    meshColor(color.r, color.g, color.b, color.a)
                    meshAdvanceVertex()
                end
            end

            meshEnd()
        end
    end

    local batching = false
    do
        function lines.startBatching()
            batching = true
            batch[-1] = PRIMITIVE_LINE_STRIP
            batch[0] = 0
        end

        function lines.stopBatching()
            local len = batch[0]
            if batch[-1] == PRIMITIVE_LINE_STRIP and batch[1] == batch[len - 2] and batch[2] == batch[len - 1] and batch[3] == batch[len] then batch[-1] = PRIMITIVE_LINE_LOOP end
            lines.drawBatchedLines(batch)
            batching = false
            batch = {
                [0] = 0
            }
        end

        function lines.drawBatchedLine(startX, startY, endX, endY, startColor, endColor)
            if endColor == nil then endColor = startColor end
            local len = batch[0]
            if batch[-1] == PRIMITIVE_LINE_STRIP and batch[0] ~= 0 then if startX ~= batch[len - 2] or startY ~= batch[len - 1] or startColor ~= batch[len] then batch[-1] = PRIMITIVE_LINES end end
            batch[len + 1] = startX
            batch[len + 2] = startY
            batch[len + 3] = startColor
            batch[len + 4] = endX
            batch[len + 5] = endY
            batch[len + 6] = endColor
            batch[0] = len + 6
        end
    end

    do
        local drawSingleLine = lines.drawSingleLine
        local drawBatchedLine = lines.drawBatchedLine
        function lines.drawLine(startX, startY, endX, endY, startColor, endColor)
            if batching then
                drawBatchedLine(startX, startY, endX, endY, startColor, endColor)
            else
                drawSingleLine(startX, startY, endX, endY, startColor, endColor)
            end
        end
    end

    paint.lines = lines
end

do
    local paint = paint
    local rects = {}
    do
        local meshBegin = mesh.Begin
        local meshEnd = mesh.End
        local meshPosition = mesh.Position
        local meshColor = mesh.Color
        local meshTexCoord = mesh.TexCoord
        local meshAdvanceVertex = mesh.AdvanceVertex
        local PRIMITIVE_QUADS = MATERIAL_QUADS
        local function unpackColor(color)
            return color.r, color.g, color.b, color.a
        end

        function rects.generateRectMesh(mesh, startX, startY, endX, endY, colors, u1, v1, u2, v2, skew, topSize)
            local startTopX = startX + (skew or 0)
            local endTopX = topSize and topSize > 0 and startTopX + topSize or endX + (skew or 0)
            meshBegin(mesh, PRIMITIVE_QUADS, 1)
            meshPosition(startX, endY, 0)
            meshColor(unpackColor(colors[4]))
            meshTexCoord(0, u1, v2)
            meshAdvanceVertex()
            meshPosition(startTopX, startY, 0)
            meshColor(unpackColor(colors[1]))
            meshTexCoord(0, u1, v1)
            meshAdvanceVertex()
            meshPosition(endTopX, startY, 0)
            meshColor(unpackColor(colors[2]))
            meshTexCoord(0, u2, v1)
            meshAdvanceVertex()
            meshPosition(endX, endY, 0)
            meshColor(unpackColor(colors[3]))
            meshTexCoord(0, u2, v2)
            meshAdvanceVertex()
            meshEnd()
        end

        local mat = Material('vgui/white')
        local renderSetMaterial = render.SetMaterial
        function rects.drawBatchedRects(array)
            renderSetMaterial(mat)
            meshBegin(PRIMITIVE_QUADS, array[0] / 8)
            for i = 1, array[0], 8 do
                local x, y, endX, endY = array[i], array[i + 1], array[i + 2], array[i + 3]
                local color1, color2, color3, color4 = array[i + 4], array[i + 5], array[i + 6], array[i + 7]
                meshPosition(x, endY, 0)
                meshColor(color4.r, color4.g, color4.b, color4.a)
                meshAdvanceVertex()
                meshPosition(x, y, 0)
                meshColor(color1.r, color1.g, color1.b, color1.a)
                meshAdvanceVertex()
                meshPosition(endX, y, 0)
                meshColor(color2.r, color2.g, color2.b, color2.a)
                meshAdvanceVertex()
                meshPosition(endX, endY, 0)
                meshColor(color3.r, color3.g, color3.b, color3.a)
                meshAdvanceVertex()
            end

            meshEnd()
        end
    end

    do
        local incrementZ = paint.incrementZ
        local batch = paint.batch
        function rects.drawBatchedRect(startX, startY, endX, endY, colors)
            local tab = batch.batchTable
            local len = tab[0]
            local z = incrementZ()
            tab[len + 1] = startX
            tab[len + 2] = endY
            tab[len + 3] = z
            tab[len + 4] = colors[4]
            tab[len + 5] = startX
            tab[len + 6] = startY
            tab[len + 7] = colors[1]
            tab[len + 8] = endX
            tab[len + 9] = startY
            tab[len + 10] = colors[2]
            tab[len + 11] = startX
            tab[len + 12] = endY
            tab[len + 13] = z
            tab[len + 14] = colors[4]
            tab[len + 15] = endX
            tab[len + 16] = startY
            tab[len + 17] = colors[2]
            tab[len + 18] = endX
            tab[len + 19] = endY
            tab[len + 20] = colors[3]
            tab[0] = len + 20
        end
    end

    do
        local cachedRectMeshes = {}
        local defaultMat = Material('vgui/white')
        local format = string.format
        local meshConstructor = Mesh
        local meshDraw = FindMetaTable('IMesh').Draw
        local renderSetMaterial = render.SetMaterial
        local generateRectMesh = rects.generateRectMesh
        local function getId(x, y, w, h, color1, color2, color3, color4, u1, v1, u2, v2, skew, topSize)
            return format('%u;%u;%u;%u;%x%x%x%x;%x%x%x%x;%x%x%x%x;%x%x%x%x;%f;%f;%f;%f;%f;%f', x, y, w, h, color1.r, color1.g, color1.b, color1.a, color2.r, color2.g, color2.b, color2.a, color3.r, color3.g, color3.b, color3.a, color4.r, color4.g, color4.b, color4.a, u1, v1, u2, v2, skew, topSize)
        end

        function rects.drawSingleRect(x, y, w, h, colors, material, u1, v1, u2, v2, skew, topSize)
            skew, topSize = skew or 0, topSize or 0
            local id = getId(x, y, w, h, colors[1], colors[2], colors[3], colors[4], u1, v1, u2, v2, skew, topSize)
            local mesh = cachedRectMeshes[id]
            if mesh == nil then
                mesh = meshConstructor()
                generateRectMesh(mesh, x, y, x + w, y + h, colors, u1, v1, u2, v2, skew, topSize)
                cachedRectMeshes[id] = mesh
            end

            renderSetMaterial(material or defaultMat)
            meshDraw(mesh)
        end

        timer.Create('paint.rectMeshGarbageCollector', 60, 0, function()
            for k, v in pairs(cachedRectMeshes) do
                cachedRectMeshes[k] = nil
                v:Destroy()
            end
        end)
    end

    do
        function rects.startBatching()
            rects.batching = {
                [0] = 0
            }

            rects.isBatching = true
        end

        local drawBatchedRects = rects.drawBatchedRects
        function rects.stopBatching()
            rects.isBatching = false
            drawBatchedRects(rects.batching)
        end

        function rects.drawQuadBatchedRect(x, y, w, h, colors)
            local tab = rects.batching
            local len = tab[0]
            tab[len + 1] = x
            tab[len + 2] = y
            tab[len + 3] = x + w
            tab[len + 4] = y + h
            tab[len + 5] = colors[1]
            tab[len + 6] = colors[2]
            tab[len + 7] = colors[3]
            tab[len + 8] = colors[4]
            tab[0] = len + 8
        end
    end

    do
        local drawSingleRect = rects.drawSingleRect
        local drawBatchedRect = rects.drawBatchedRect
        local drawQuadBatchedRect = rects.drawQuadBatchedRect
        local batch = paint.batch
        function rects.drawRect(x, y, w, h, colors, material, u1, v1, u2, v2, skew, topSize)
            if colors[4] == nil then
                colors[1] = colors
                colors[2] = colors
                colors[3] = colors
                colors[4] = colors
            end

            if u1 == nil then
                u1, v1 = 0, 0
                u2, v2 = 1, 1
            end

            if batch.batching then
                drawBatchedRect(x, y, x + w, y + h, colors)
            else
                if rects.isBatching then
                    drawQuadBatchedRect(x, y, w, h, colors)
                else
                    drawSingleRect(x, y, w, h, colors, material, u1, v1, u2, v2, skew, topSize)
                end
            end
        end
    end

    _G.paint.rects = rects
end

do
    local paint = _G.paint
    --
    --
    --
    --
    --
    --
    --
    --
    --
    --
    --
    --
    --
    --
    --
    --
    --
    --
    --
    local roundedBoxes = {}
    do
        local meshBegin = mesh.Begin
        local meshEnd = mesh.End
        local PRIMITIVE_POLYGON = MATERIAL_POLYGON
        local clamp = math.Clamp
        local halfPi = math.pi / 2
        local sin = math.sin
        local cos = math.cos
        local function fpow(num, power)
            if num > 0 then
                return num ^ power
            else
                return -((-num) ^ power)
            end
        end

        function roundedBoxes.getMeshVertexCount(radius, rightTop, rightBottom, leftBottom, leftTop)
            if radius > 3 then
                local vertsPerEdge = clamp(radius / 2, 3, 24)
                return 6 + (rightTop and vertsPerEdge or 0) + (rightBottom and vertsPerEdge or 0) + (leftBottom and vertsPerEdge or 0) + (leftTop and vertsPerEdge or 0)
            else
                return 6 + (rightTop and 1 or 0) + (rightBottom and 1 or 0) + (leftBottom and 1 or 0) + (leftTop and 1 or 0)
            end
        end

        local getMeshVertexCount = roundedBoxes.getMeshVertexCount
        local centreTab = {}
        function roundedBoxes.generateSingleMesh(createVertex, mesh, radius, x, y, endX, endY, leftTop, rightTop, rightBottom, leftBottom, colors, u1, v1, u2, v2, curviness)
            local vertsPerEdge = clamp(radius / 2, 3, 24)
            local isRadiusBig = radius > 3
            curviness = 2 / (curviness or 2)
            local w, h = endX - x, endY - y
            if mesh then meshBegin(mesh, PRIMITIVE_POLYGON, getMeshVertexCount(radius, rightTop, rightBottom, leftBottom, leftTop)) end
            local fifthColor = colors[5]
            if fifthColor == nil then
                createVertex((x + endX) * 0.5, (y + endY) * 0.5, 0.5, 0.5, colors, u1, v1, u2, v2)
            else
                centreTab[1], centreTab[2], centreTab[3], centreTab[4] = fifthColor, fifthColor, fifthColor, fifthColor
                createVertex((x + endX) * 0.5, (y + endY) * 0.5, 0.5, 0.5, centreTab, u1, v1, u2, v2)
            end

            createVertex(x + (leftTop and radius or 0), y, (leftTop and radius or 0) / w, 0, colors, u1, v1, u2, v2)
            createVertex(endX - (rightTop and radius or 0), y, 1 - (rightTop and radius or 0) / w, 0, colors, u1, v1, u2, v2)
            if rightTop then
                if isRadiusBig then
                    local deltaX = endX - radius
                    local deltaY = y + radius
                    for i = 1, vertsPerEdge - 1 do
                        local angle = halfPi * (i / vertsPerEdge)
                        local sinn, coss = fpow(sin(angle), curviness), fpow(cos(angle), curviness)
                        local newX, newY = deltaX + sinn * radius, deltaY - coss * radius
                        createVertex(newX, newY, 1 - (1 - sinn) * radius / w, (1 - coss) * radius / h, colors, u1, v1, u2, v2)
                    end
                end

                createVertex(endX, y + radius, 1, radius / h, colors, u1, v1, u2, v2)
            end

            createVertex(endX, endY - (rightBottom and radius or 0), 1, 1 - (rightBottom and radius or 0) / h, colors, u1, v1, u2, v2)
            if rightBottom then
                if isRadiusBig then
                    local deltaX = endX - radius
                    local deltaY = endY - radius
                    for i = 1, vertsPerEdge - 1 do
                        local angle = halfPi * (i / vertsPerEdge)
                        local sinn, coss = fpow(sin(angle), curviness), fpow(cos(angle), curviness)
                        local newX, newY = deltaX + coss * radius, deltaY + sinn * radius
                        createVertex(newX, newY, 1 - ((1 - coss) * radius) / w, 1 - ((1 - sinn) * radius) / h, colors, u1, v1, u2, v2)
                    end
                end

                createVertex(endX - radius, endY, 1 - radius / w, 1, colors, u1, v1, u2, v2)
            end

            createVertex(x + (leftBottom and radius or 0), endY, (leftBottom and radius or 0) / w, 1, colors, u1, v1, u2, v2)
            if leftBottom then
                if isRadiusBig then
                    local deltaX = x + radius
                    local deltaY = endY - radius
                    for i = 1, vertsPerEdge - 1 do
                        local angle = halfPi * (i / vertsPerEdge)
                        local sinn, coss = fpow(sin(angle), curviness), fpow(cos(angle), curviness)
                        local newX, newY = deltaX - sinn * radius, deltaY + coss * radius
                        createVertex(newX, newY, (1 - sinn) * radius / w, 1 - (1 - coss) * radius / h, colors, u1, v1, u2, v2)
                    end
                end

                createVertex(x, endY - radius, 0, 1 - radius / h, colors, u1, v1, u2, v2)
            end

            createVertex(x, y + (leftTop and radius or 0), 0, (leftTop and radius or 0) / h, colors, u1, v1, u2, v2)
            if leftTop then
                if isRadiusBig then
                    local deltaX = x + radius
                    local deltaY = y + radius
                    for i = 1, vertsPerEdge - 1 do
                        local angle = halfPi * (i / vertsPerEdge)
                        local sinn, coss = fpow(sin(angle), curviness), fpow(cos(angle), curviness)
                        local newX, newY = deltaX - coss * radius, deltaY - sinn * radius
                        createVertex(newX, newY, (1 - coss) * radius / w, (1 - sinn) * radius / h, colors, u1, v1, u2, v2)
                    end
                end

                createVertex(x + radius, y, radius / w, 0, colors, u1, v1, u2, v2)
            end

            if mesh then meshEnd() end
        end
    end

    do
        local meshPosition = mesh.Position
        local meshColor = mesh.Color
        local meshAdvanceVertex = mesh.AdvanceVertex
        local meshTexCoord = mesh.TexCoord
        local bilinearInterpolation = paint.bilinearInterpolation
        local function createVertex(x, y, u, v, colors, u1, v1, u2, v2)
            local leftTop, rightTop, rightBottom, leftBottom = colors[1], colors[2], colors[3], colors[4]
            meshPosition(x, y, 0)
            meshTexCoord(0, u * (u2 - u1) + u1, v * (v2 - v1) + v1)
            meshColor(bilinearInterpolation(u, v, leftTop.r, rightTop.r, rightBottom.r, leftBottom.r), bilinearInterpolation(u, v, leftTop.g, rightTop.g, rightBottom.g, leftBottom.g), bilinearInterpolation(u, v, leftTop.b, rightTop.b, rightBottom.b, leftBottom.b), bilinearInterpolation(u, v, leftTop.a, rightTop.a, rightBottom.a, leftBottom.a))
            meshAdvanceVertex()
        end

        local meshConstructor = Mesh
        local meshDraw = FindMetaTable('IMesh').Draw
        local format = string.format
        local setMaterial = render.SetMaterial
        local matrix = Matrix()
        local setField = matrix.SetField
        local pushModelMatrix = cam.PushModelMatrix
        local popModelMatrix = cam.PopModelMatrix
        local generateSingleMesh = roundedBoxes.generateSingleMesh
        local function getId(radius, w, h, corners, colors, u1, v1, u2, v2, curviness)
            local color1, color2, color3, color4, color5 = colors[1], colors[2], colors[3], colors[4], colors[5]
            if color5 == nil then
                return format('%u;%u;%u;%u;%x%x%x%x;%x%x%x%x;%x%x%x%x;%x%x%x%x;%f;%f;%f;%f;%f', radius, w, h, corners, color1.r, color1.g, color1.b, color1.a, color2.r, color2.g, color2.b, color2.a, color3.r, color3.g, color3.b, color3.a, color4.r, color4.g, color4.b, color4.a, u1, v1, u2, v2, curviness)
            else
                return format('%u;%u;%u;%u;%x%x%x%x;%x%x%x%x;%x%x%x%x;%x%x%x%x;%x%x%x%x;%f;%f;%f;%f;%f', radius, w, h, corners, color1.r, color1.g, color1.b, color1.a, color2.r, color2.g, color2.b, color2.a, color3.r, color3.g, color3.b, color3.a, color4.r, color4.g, color4.b, color4.a, color5.r, color5.g, color5.b, color5.a, u1, v1, u2, v2, curviness)
            end
        end

        local cachedRoundedBoxMeshes = {}
        function roundedBoxes.roundedBoxExSingle(radius, x, y, w, h, colors, leftTop, rightTop, rightBottom, leftBottom, material, u1, v1, u2, v2, curviness)
            curviness = curviness or 2
            local id = getId(radius, w, h, (leftTop and 8 or 0) + (rightTop and 4 or 0) + (rightBottom and 2 or 0) + (leftBottom and 1 or 0), colors, u1, v1, u2, v2, curviness)
            local meshObj = cachedRoundedBoxMeshes[id]
            if meshObj == nil then
                meshObj = meshConstructor()
                generateSingleMesh(createVertex, meshObj, radius, 0, 0, w, h, leftTop, rightTop, rightBottom, leftBottom, colors, u1, v1, u2, v2, curviness)
                cachedRoundedBoxMeshes[id] = meshObj
            end

            setField(matrix, 1, 4, x)
            setField(matrix, 2, 4, y)
            pushModelMatrix(matrix, true)
            setMaterial(material)
            meshDraw(meshObj)
            popModelMatrix()
        end

        timer.Create('paint.roundedBoxesGarbageCollector', 60, 0, function()
            for k, v in pairs(cachedRoundedBoxMeshes) do
                v:Destroy()
                cachedRoundedBoxMeshes[k] = nil
            end
        end)
    end

    do
        local prev1
        local prev2 = {}
        local batch = paint.batch
        local incrementZ = paint.incrementZ
        local color = Color
        local bilinearInterpolation = paint.bilinearInterpolation
        local function createVertex(x, y, u, v, colors)
            if prev1 == nil then
                local z = incrementZ()
                local blendedColor = color((colors[1].r + colors[2].r + colors[3].r + colors[4].r) / 4, (colors[1].g + colors[2].g + colors[3].g + colors[4].g) / 4, (colors[1].b + colors[2].b + colors[3].b + colors[4].b) / 4, (colors[1].a + colors[2].a + colors[3].a + colors[4].a) / 4)
                prev1 = {x, y, blendedColor, z}
                return
            end

            local prefferedColor = color(bilinearInterpolation(u, v, colors[1].r, colors[2].r, colors[3].r, colors[4].r), bilinearInterpolation(u, v, colors[1].g, colors[2].g, colors[3].g, colors[4].g), bilinearInterpolation(u, v, colors[1].b, colors[2].b, colors[3].b, colors[4].b), bilinearInterpolation(u, v, colors[1].a, colors[2].a, colors[3].a, colors[4].a))
            if prev2 == nil then
                prev2 = {x, y, prefferedColor}
                return
            end

            local batchTable = batch.batchTable
            local len = batchTable[0]
            batchTable[len + 1] = prev1[1]
            batchTable[len + 2] = prev1[2]
            batchTable[len + 3] = prev1[4]
            batchTable[len + 4] = prev1[3]
            batchTable[len + 5] = prev2[1]
            batchTable[len + 6] = prev2[2]
            batchTable[len + 7] = prev2[3]
            batchTable[len + 8] = x
            batchTable[len + 9] = y
            batchTable[len + 10] = prefferedColor
            batchTable[0] = len + 10
            prev2[1] = x
            prev2[2] = y
            prev2[3] = prefferedColor
        end

        local generateSingleMesh = roundedBoxes.generateSingleMesh
        function roundedBoxes.roundedBoxExBatched(radius, x, y, w, h, colors, leftTop, rightTop, rightBottom, leftBottom, curviness)
            prev1 = nil
            prev2 = nil
            generateSingleMesh(createVertex, nil, radius, x, y, x + w, y + h, leftTop, rightTop, rightBottom, leftBottom, colors, 0, 0, 1, 1, curviness)
        end
    end

    do
        local defaultMat = Material('vgui/white')
        local roundedBoxExSingle = roundedBoxes.roundedBoxExSingle
        local roundedBoxExBatched = roundedBoxes.roundedBoxExBatched
        local batch = paint.batch
        function roundedBoxes.roundedBoxEx(radius, x, y, w, h, colors, leftTop, rightTop, rightBottom, leftBottom, material, u1, v1, u2, v2, curviness)
            if colors[4] == nil then
                colors[1] = colors
                colors[2] = colors
                colors[3] = colors
                colors[4] = colors
            end

            if u1 == nil then u1, v1, u2, v2 = 0, 0, 1, 1 end
            curviness = curviness or 2
            if radius == 0 then leftTop, rightTop, rightBottom, leftBottom = false, false, false, false end
            material = material or defaultMat
            if batch.batching then
                roundedBoxExBatched(radius, x, y, w, h, colors, leftTop, rightTop, rightBottom, leftBottom, curviness)
            else
                roundedBoxExSingle(radius, x, y, w, h, colors, leftTop, rightTop, rightBottom, leftBottom, material, u1, v1, u2, v2, curviness)
            end
        end

        local roundedBoxEx = roundedBoxes.roundedBoxEx
        function roundedBoxes.roundedBox(radius, x, y, w, h, colors, material, u1, v1, u2, v2, curviness)
            roundedBoxEx(radius, x, y, w, h, colors, true, true, true, true, material, u1, v1, u2, v2, curviness)
        end
    end

    do
        local generateSingleMesh = roundedBoxes.generateSingleMesh
        local createdTable
        local len
        local function createVertex(x, y, u, v, _, u1, v1, u2, v2)
            if createdTable == nil then return end
            len = len + 1
            createdTable[len] = {
                x = x,
                y = y,
                u = u1 + u * (u2 - u1),
                v = v1 + v * (v2 - v1)
            }
        end

        local emptyTab = {}
        function roundedBoxes.generateDrawPoly(radius, x, y, w, h, leftTop, rightTop, rightBottom, leftBottom, u1, v1, u2, v2, curviness)
            createdTable = {}
            len = 0
            generateSingleMesh(createVertex, nil, radius, x, y, w, h, leftTop, rightTop, rightBottom, leftBottom, emptyTab, u1, v1, u2, v2, curviness)
            local tab = createdTable
            createdTable = nil
            len = nil
            return tab
        end
    end

    _G.paint.roundedBoxes = roundedBoxes
end

do
    local paint = paint
    local outlines = {}
    do
        local meshPosition = mesh.Position
        local meshColor = mesh.Color
        local meshTexCoord = mesh.TexCoord
        local meshAdvanceVertex = mesh.AdvanceVertex
        local isFirst = true
        local prevU
        local isInside
        local outlineLeft = 0
        local outlineRight = 0
        local outlineTop = 0
        local outlineBottom = 0
        local atan2 = math.atan2
        local function createVertex(x, y, u, v, colors)
            if isFirst then
                isFirst = false
                return
            end

            local texU = 1 - (atan2((1 - v) - 0.5, u - 0.5) / (2 * math.pi) + 0.5)
            if prevU and prevU > texU then
                texU = texU + 1
            else
                prevU = texU
            end

            local newX, newY
            if u < 0.5 then
                newX = x - outlineLeft * ((1 - u) - 0.5) * 2
            elseif u ~= 0.5 then
                newX = x + outlineRight * (u - 0.5) * 2
            else
                newX = x
            end

            if v < 0.5 then
                newY = y - outlineTop * ((1 - v) - 0.5) * 2
            elseif v ~= 0.5 then
                newY = y + outlineBottom * (v - 0.5) * 2
            else
                newY = y
            end

            if isInside then
                meshPosition(newX, newY, 0)
                meshColor(colors[2].r, colors[2].g, colors[2].b, colors[2].a)
                meshTexCoord(0, texU, 0.02)
                meshAdvanceVertex()
                meshPosition(x, y, 0)
                meshColor(colors[1].r, colors[1].g, colors[1].b, colors[1].a)
                meshTexCoord(0, texU, 1)
                meshAdvanceVertex()
            else
                meshPosition(x, y, 0)
                meshColor(colors[1].r, colors[1].g, colors[1].b, colors[1].a)
                meshTexCoord(0, texU, 1)
                meshAdvanceVertex()
                meshPosition(newX, newY, 0)
                meshColor(colors[2].r, colors[2].g, colors[2].b, colors[2].a)
                meshTexCoord(0, texU, 0.02)
                meshAdvanceVertex()
            end
        end

        local generateSingleMesh = paint.roundedBoxes.generateSingleMesh
        local meshBegin = mesh.Begin
        local meshEnd = mesh.End
        local PRIMITIVE_TRIANGLE_STRIP = MATERIAL_TRIANGLE_STRIP
        local getMeshVertexCount = paint.roundedBoxes.getMeshVertexCount
        function outlines.generateOutlineSingle(mesh, radius, x, y, w, h, leftTop, rightTop, rightBottom, leftBottom, colors, l, t, r, b, curviness, inside)
            isInside = inside or false
            outlineTop, outlineRight, outlineBottom, outlineLeft = t or 0, r or 0, b or 0, l or 0
            curviness = curviness or 2
            isFirst = true
            prevU = nil
            meshBegin(mesh, PRIMITIVE_TRIANGLE_STRIP, getMeshVertexCount(radius, rightTop, rightBottom, leftBottom, leftTop) * 2)
            generateSingleMesh(createVertex, nil, radius, x, y, w, h, leftTop, rightTop, rightBottom, leftBottom, colors, 0, 0, 1, 1, curviness)
            meshEnd()
        end
    end

    do
        local cachedOutlinedMeshes = {}
        local format = string.format
        local function getId(radius, w, h, corners, color1, color2, l, t, r, b, curviness, inside)
            return format('%u;%u;%u;%u;%x%x%x%x;%x%x%x%x;%u;%u;%u;%u;%f;%u', radius, w, h, corners, color1.r, color1.g, color1.b, color1.a, color2.r, color2.g, color2.b, color2.a, l, t, r, b, curviness or 2, inside and 1 or 0)
        end

        local pushModelMatrix = cam.PushModelMatrix
        local popModelMatrix = cam.PopModelMatrix
        local meshConstructor = Mesh
        local generateOutlineSingle = outlines.generateOutlineSingle
        local matrix = Matrix()
        local setField = matrix.SetField
        local setMaterial = render.SetMaterial
        local defaultMat = Material('vgui/white')
        local meshDraw = FindMetaTable('IMesh').Draw
        function outlines.drawOutlineSingle(radius, x, y, w, h, leftTop, rightTop, rightBottom, leftBottom, colors, material, l, t, r, b, curviness, inside)
            curviness = curviness or 2
            inside = inside or false
            local id = getId(radius, w, h, (leftTop and 8 or 0) + (rightTop and 4 or 0) + (rightBottom and 2 or 0) + (leftBottom and 1 or 0), colors[1], colors[2], l, t, r, b, curviness, inside)
            local meshObj = cachedOutlinedMeshes[id]
            if meshObj == nil then
                meshObj = meshConstructor()
                generateOutlineSingle(meshObj, radius, 0, 0, w, h, leftTop, rightTop, rightBottom, leftBottom, colors, l, t, r, b, curviness, inside)
                cachedOutlinedMeshes[id] = meshObj
            end

            setField(matrix, 1, 4, x)
            setField(matrix, 2, 4, y)
            pushModelMatrix(matrix, true)
            setMaterial(material or defaultMat)
            meshDraw(meshObj)
            popModelMatrix()
        end

        timer.Create('paint.outlinesGarbageCollector', 60, 0, function()
            for k, v in pairs(cachedOutlinedMeshes) do
                v:Destroy()
                cachedOutlinedMeshes[k] = nil
            end
        end)
    end

    do
        local generateSingleMesh = paint.roundedBoxes.generateSingleMesh
        local outlineL, outlineT, outlineR, outlineB
        local first
        local prevX, prevY, prevU, prevV
        local z
        local isInside
        local batch = paint.batch
        local function createVertex(x, y, u, v, colors)
            if first then
                first = false
                return
            elseif first == false then
                prevX, prevY, prevU, prevV = x, y, u, v
                first = nil
                return
            end

            local batchTable = batch.batchTable
            local len = batchTable[0]
            local color1, color2 = colors[1], colors[2]
            batchTable[len + 1] = prevX
            batchTable[len + 2] = prevY
            batchTable[len + 3] = z
            batchTable[len + 4] = color1
            do
                if prevU < 0.5 then
                    prevX = prevX - outlineL * ((1 - prevU) - 0.5) * 2
                elseif prevU ~= 0.5 then
                    prevX = prevX + outlineR * (prevU - 0.5) * 2
                end

                if prevV < 0.5 then
                    prevY = prevY - outlineT * ((1 - prevV) - 0.5) * 2
                elseif prevV ~= 0.5 then
                    prevY = prevY + outlineB * (prevV - 0.5) * 2
                end
            end

            batchTable[len + 5] = prevX
            batchTable[len + 6] = prevY
            batchTable[len + 7] = color2
            batchTable[len + 8] = x
            batchTable[len + 9] = y
            batchTable[len + 10] = color1
            batchTable[len + 11] = x
            batchTable[len + 12] = y
            batchTable[len + 13] = z
            batchTable[len + 14] = color1
            batchTable[len + 15] = prevX
            batchTable[len + 16] = prevY
            batchTable[len + 17] = color2
            prevX, prevY, prevU, prevV = x, y, u, v
            do
                if u < 0.5 then
                    x = x - outlineL * ((1 - u) - 0.5) * 2
                elseif u ~= 0.5 then
                    x = x + outlineR * (u - 0.5) * 2
                end

                if v < 0.5 then
                    y = y - outlineT * ((1 - v) - 0.5) * 2
                elseif v ~= 0.5 then
                    y = y + outlineB * (v - 0.5) * 2
                end
            end

            batchTable[len + 18] = x
            batchTable[len + 19] = y
            batchTable[len + 20] = color2
            batchTable[0] = len + 20
        end

        local incrementZ = paint.incrementZ
        function outlines.drawOutlineBatched(radius, x, y, w, h, leftTop, rightTop, rightBottom, leftBottom, colors, _, l, t, r, b, curviness, inside)
            outlineL, outlineT, outlineR, outlineB = l, t, r, b
            first = true
            curviness = curviness or 2
            isInside = inside or false
            z = incrementZ()
            generateSingleMesh(createVertex, nil, radius, x, y, x + w, y + h, leftTop, rightTop, rightBottom, leftBottom, colors, 0, 0, 1, 1, curviness)
        end
    end

    do
        local batch = paint.batch
        local drawOutlineSingle = outlines.drawOutlineSingle
        local drawOutlineBatched = outlines.drawOutlineBatched
        function outlines.drawOutlineEx(radius, x, y, w, h, leftTop, rightTop, rightBottom, leftBottom, colors, material, l, t, r, b, curviness, inside)
            if colors[2] == nil then
                colors[1] = colors
                colors[2] = colors
            end

            if radius == 0 then leftTop, rightTop, rightBottom, leftBottom = false, false, false, false end
            if t == nil then
                t, r, b = l, l, l
            elseif r == nil then
                r, b = l, t
            end

            inside = inside or false
            curviness = curviness or 2
            if batch.batching then
                drawOutlineBatched(radius, x, y, w, h, leftTop, rightTop, rightBottom, leftBottom, colors, material, l, t, r, b, curviness, inside)
            else
                drawOutlineSingle(radius, x, y, w, h, leftTop, rightTop, rightBottom, leftBottom, colors, material, l, t, r, b, curviness, inside)
            end
        end

        local drawOutlineEx = outlines.drawOutlineEx
        function outlines.drawOutline(radius, x, y, w, h, colors, material, l, t, r, b, curviness, inside)
            drawOutlineEx(radius, x, y, w, h, true, true, true, true, colors, material, l, t, r, b, curviness, inside)
        end
    end

    do
        local meshConstructor = Mesh
        local meshBegin = mesh.Begin
        local meshEnd = mesh.End
        local meshPosition = mesh.Position
        local meshColor = mesh.Color
        local meshAdvanceVertex = mesh.AdvanceVertex
        local PRIMITIVE_TRIANGLE_STRIP = MATERIAL_TRIANGLE_STRIP
        function outlines.generateBoxOutline(x, y, endX, endY, colors, outlineL, outlineT, outlineR, outlineB)
            local meshObj = meshConstructor()
            local innerR, innerG, innerB, innerA = colors[1].r, colors[1].g, colors[1].b, colors[1].a
            local outerR, outerG, outerB, outerA = colors[2].r, colors[2].g, colors[2].b, colors[2].a
            meshBegin(meshObj, PRIMITIVE_TRIANGLE_STRIP, 17)
            meshPosition(x, y, 0)
            meshColor(innerR, innerG, innerB, innerA)
            meshAdvanceVertex()
            meshPosition(x, y - outlineT, 0)
            meshColor(outerR, outerG, outerB, outerA)
            meshAdvanceVertex()
            meshPosition(endX, y, 0)
            meshColor(innerR, innerG, innerB, innerA)
            meshAdvanceVertex()
            meshPosition(endX, y - outlineT, 0)
            meshColor(outerR, outerG, outerB, outerA)
            meshAdvanceVertex()
            meshPosition(endX, y, 0)
            meshColor(innerR, innerG, innerB, innerA)
            meshAdvanceVertex()
            meshPosition(endX + outlineR, y, 0)
            meshColor(outerR, outerG, outerB, outerA)
            meshAdvanceVertex()
            meshPosition(endX, endY, 0)
            meshColor(innerR, innerG, innerB, innerA)
            meshAdvanceVertex()
            meshPosition(endX + outlineR, endY, 0)
            meshColor(outerR, outerG, outerB, outerA)
            meshAdvanceVertex()
            meshPosition(endX, endY, 0)
            meshColor(innerR, innerB, innerB, innerA)
            meshAdvanceVertex()
            meshPosition(endX, endY + outlineB, 0)
            meshColor(outerR, outerB, outerB, outerA)
            meshAdvanceVertex()
            meshPosition(x, endY, 0)
            meshColor(innerR, innerG, innerB, innerA)
            meshAdvanceVertex()
            meshPosition(x, endY + outlineB, 0)
            meshColor(outerR, outerG, outerB, outerA)
            meshAdvanceVertex()
            meshPosition(x, endY, 0)
            meshColor(innerR, innerG, innerB, innerA)
            meshAdvanceVertex()
            meshPosition(x - outlineL, endY, 0)
            meshColor(outerR, outerG, outerB, outerA)
            meshAdvanceVertex()
            meshPosition(x, y, 0)
            meshColor(innerR, innerG, innerB, innerA)
            meshAdvanceVertex()
            meshPosition(x - outlineL, y, 0)
            meshColor(outerR, outerG, outerB, outerA)
            meshAdvanceVertex()
            meshPosition(x, y - outlineL, 0)
            meshColor(outerR, outerG, outerB, outerA)
            meshAdvanceVertex()
            meshEnd()
            return meshObj
        end

        local format = string.format
        local function getId(w, h, color1, color2, outlineL, outlineT, outlineR, outlineB)
            return format('%f;%f;%x%x%x%x;%x%x%x%x;%f;%f;%f;%f', w, h, color1.r, color1.g, color1.b, color1.a, color2.r, color2.g, color2.b, color2.a, outlineL, outlineT, outlineR, outlineB)
        end

        local generateBoxOutline = outlines.generateBoxOutline
        local cachedBoxOutlineMeshes = {}
        local camPushModelMatrix = cam.PushModelMatrix
        local camPopModelMatrix = cam.PopModelMatrix
        local matrix = Matrix()
        local setField = matrix.SetField
        local meshDraw = FindMetaTable('IMesh').Draw
        local defaultMat = Material('vgui/white')
        local renderSetMaterial = render.SetMaterial
        function outlines.drawBoxOutline(x, y, w, h, colors, outlineL, outlineT, outlineR, outlineB)
            if colors[2] == nil then
                colors[1] = colors
                colors[2] = colors
            end

            if outlineT == nil then
                outlineT, outlineR, outlineB = outlineL, outlineL, outlineL
            elseif outlineR == nil then
                outlineR, outlineB = outlineL, outlineT
            end

            local id = getId(w, h, colors[1], colors[2], outlineL, outlineT, outlineR, outlineB)
            local mesh = cachedBoxOutlineMeshes[id]
            if mesh == nil then
                mesh = generateBoxOutline(0, 0, w, h, colors, outlineL, outlineT, outlineR, outlineB)
                cachedBoxOutlineMeshes[id] = mesh
            end

            setField(matrix, 1, 4, x)
            setField(matrix, 2, 4, y)
            renderSetMaterial(defaultMat)
            camPushModelMatrix(matrix, true)
            meshDraw(mesh)
            camPopModelMatrix()
        end

        timer.Create('paint.cachedBoxOutlineGarbageCollector', 60, 0, function()
            for k, v in pairs(cachedBoxOutlineMeshes) do
                v:Destroy()
                cachedBoxOutlineMeshes[k] = nil
            end
        end)
    end

    _G.paint.outlines = outlines
end

do
    local blur = {}
    local paint = paint
    local RT_SIZE = 256
    local BLUR = 10
    local BLUR_PASSES = 1
    local BLUR_TIME = 1 / 30
    local BLUR_EXPENSIVE = true
    local RT_FLAGS = 2 + 256 + 32768
    local TEXTURE_PREFIX = 'paint_library_rt_'
    local MATERIAL_PREFIX = 'paint_library_material_'
    local textures = {
        default = GetRenderTargetEx(TEXTURE_PREFIX .. 'default', RT_SIZE, RT_SIZE, 1, 2, RT_FLAGS, 0, 3)
    }

    local textureTimes = {
        default = 0
    }

    local textureMaterials = {
        default = CreateMaterial(MATERIAL_PREFIX .. 'default', 'UnlitGeneric', {
            ['$basetexture'] = TEXTURE_PREFIX .. 'default',
            ['$vertexalpha'] = 1,
            ['$vertexcolor'] = 1,
        })
    }

    do
        local copyRTToTex = render.CopyRenderTargetToTexture
        local pushRenderTarget = render.PushRenderTarget
        local popRenderTarget = render.PopRenderTarget
        local start2D = cam.Start2D
        local end2D = cam.End2D
        local overrideColorWriteEnable = render.OverrideColorWriteEnable
        local overrideAlphaWriteEnable = render.OverrideAlphaWriteEnable
        local drawScreenQuad = render.DrawScreenQuad
        local updateScreenEffectTexture = render.UpdateScreenEffectTexture
        local setMaterial = render.SetMaterial
        local blurMaterial = Material('pp/blurscreen')
        local setTexture = blurMaterial.SetTexture
        local setFloat = blurMaterial.SetFloat
        local recompute = blurMaterial.Recompute
        local screenEffectTexture = render.GetScreenEffectTexture()
        local whiteMaterial = Material('vgui/white')
        local blurRTExpensive = render.BlurRenderTarget
        local function blurRTCheap(rt, _, blurStrength, passes)
            setMaterial(blurMaterial)
            setTexture(blurMaterial, '$basetexture', rt)
            for i = 1, passes do
                setFloat(blurMaterial, '$blur', (i / passes) * blurStrength)
                recompute(blurMaterial)
                updateScreenEffectTexture()
                drawScreenQuad()
            end

            setTexture(blurMaterial, '$basetexture', screenEffectTexture)
        end

        function blur.generateBlur(id, blurStrength, passes, expensive)
            local texToBlur = textures[id or 'default']
            blurStrength = blurStrength or BLUR
            passes = passes or BLUR_PASSES
            expensive = expensive or BLUR_EXPENSIVE
            copyRTToTex(texToBlur)
            pushRenderTarget(texToBlur)
            start2D()
            local blurRT = expensive and blurRTExpensive or blurRTCheap
            blurRT(texToBlur, blurStrength, blurStrength, passes)
            overrideAlphaWriteEnable(true, true)
            overrideColorWriteEnable(true, false)
            setMaterial(whiteMaterial)
            drawScreenQuad()
            overrideAlphaWriteEnable(false, true)
            overrideColorWriteEnable(false, true)
            end2D()
            popRenderTarget()
        end
    end

    do
        local clock = os.clock
        local generateBlur = blur.generateBlur
        function blur.requestBlur(id, time, blurStrength, passes, expensive)
            id = id or 'default'
            time = time or BLUR_TIME
            if textureTimes[id] == nil then
                textureTimes[id] = clock() + time
                return
            end

            if id ~= 'default' and textureTimes[id] < clock() then
                generateBlur(id, blurStrength, passes, expensive)
                if time > 0 then
                    textureTimes[id] = nil
                else
                    textureTimes[id] = 0
                end
            end
        end

        hook.Add('RenderScreenspaceEffects', 'paint.blur', function()
            local time = textureTimes['default']
            if time == nil then return end
            if time < clock() then
                generateBlur()
                textureTimes['default'] = nil
            end
        end)
    end

    do
        local requestBlur = blur.requestBlur
        local getRenderTargetEx = GetRenderTargetEx
        local createMaterial = CreateMaterial
        local pushRenderTarget = render.PushRenderTarget
        local popRenderTarget = render.PopRenderTarget
        local clear = render.Clear
        function blur.getBlurTexture(id, time, blurStrength, passes, expensive)
            id = id or 'default'
            if textures[id] == nil then
                local tex = getRenderTargetEx(TEXTURE_PREFIX .. id, RT_SIZE, RT_SIZE, 1, 2, RT_FLAGS, 0, 3)
                textures[id] = tex
                textureTimes[id] = 0
                pushRenderTarget(tex)
                clear(0, 0, 0, 255)
                popRenderTarget()
            end

            requestBlur(id, time, blurStrength, passes, expensive)
            return textures[id]
        end

        local getBlurTexture = blur.getBlurTexture
        function blur.getBlurMaterial(id, time, blurStrength, passes, expensive)
            id = id or 'default'
            local mat = textureMaterials[id]
            if mat == nil then
                mat = createMaterial(MATERIAL_PREFIX .. id, 'UnlitGeneric', {
                    ['$basetexture'] = getBlurTexture(id, time, blurStrength, passes, expensive):GetName(),
                    ['$vertexalpha'] = 1,
                    ['$vertexcolor'] = 1,
                    ['$model'] = 1,
                    ['$translucent'] = 1,
                })

                textureMaterials[id] = mat
                return mat
            end

            requestBlur(id, time, blurStrength, passes, expensive)
            return mat
        end
    end

    paint.blur = blur
end

do
    local circles = {}
    local paint = paint
    local function fpow(num, power)
        if num > 0 then
            return num ^ power
        else
            return -((-num) ^ power)
        end
    end

    do
        local meshConstructor = Mesh
        local meshBegin = mesh.Begin
        local meshEnd = mesh.End
        local meshPosition = mesh.Position
        local meshColor = mesh.Color
        local meshTexCoord = mesh.TexCoord
        local meshAdvanceVertex = mesh.AdvanceVertex
        local PRIMITIVE_POLYGON = MATERIAL_POLYGON
        local originVector = Vector(0, 0, 0)
        local sin, cos = math.sin, math.cos
        function circles.generateSingleMesh(vertexCount, startAngle, endAngle, colors, rotation, curviness)
            local meshObj = meshConstructor()
            local r, g, b, a = colors[2].r, colors[2].g, colors[2].b, colors[2].a
            local deltaAngle = endAngle - startAngle
            meshBegin(meshObj, PRIMITIVE_POLYGON, vertexCount + 2)
            meshPosition(originVector)
            meshColor(colors[1].r, colors[1].g, colors[1].b, colors[1].a)
            meshTexCoord(0, 0.5, 0.5)
            meshAdvanceVertex()
            for i = 0, vertexCount do
                local angle = startAngle + deltaAngle * i / vertexCount
                meshPosition(fpow(cos(angle), curviness), fpow(sin(angle), curviness), 0)
                meshColor(r, g, b, a)
                meshTexCoord(0, fpow(sin(angle + rotation), curviness) / 2 + 0.5, fpow(cos(angle + rotation), curviness) / 2 + 0.5)
                meshAdvanceVertex()
            end

            meshEnd()
            return meshObj
        end
    end

    do
        local batch = paint.batch
        local incrementZ = paint.incrementZ
        local sin, cos = math.sin, math.cos
        function circles.generateMeshBatched(x, y, w, h, vertexCount, startAngle, endAngle, colors, curviness)
            local startColor, endColor = colors[1], colors[2]
            local batchTable = batch.batchTable
            local len = batchTable[0]
            local z = incrementZ()
            local deltaAngle = endAngle - startAngle
            for i = 0, vertexCount - 1 do
                local indexI = i * 10
                do
                    batchTable[len + 1 + indexI] = x
                    batchTable[len + 2 + indexI] = y
                    batchTable[len + 3 + indexI] = z
                    batchTable[len + 4 + indexI] = startColor
                end

                do
                    local angle = startAngle + deltaAngle * i / vertexCount
                    batchTable[len + 5 + indexI] = x + fpow(cos(angle), curviness) * w
                    batchTable[len + 6 + indexI] = y + fpow(sin(angle), curviness) * h
                    batchTable[len + 7 + indexI] = endColor
                end

                do
                    local angle = startAngle + deltaAngle * (i + 1) / vertexCount
                    batchTable[len + 8 + indexI] = x + fpow(cos(angle), curviness) * w
                    batchTable[len + 9 + indexI] = y + fpow(sin(angle), curviness) * h
                    batchTable[len + 10 + indexI] = endColor
                end
            end

            batchTable[0] = len + 10 * vertexCount
        end
    end

    do
        local angleConverter = math.pi / 180
        local batch = paint.batch
        local matrix = Matrix()
        local setUnpacked = matrix.SetUnpacked
        local pushModelMatrix = cam.PushModelMatrix
        local popModelMatrix = cam.PopModelMatrix
        local cachedCircleMeshes = {}
        local format = string.format
        local function getId(color1, color2, vertexCount, startAngle, endAngle, rotation, curviness)
            return format('%x%x%x%x;%x%x%x%x;%u;%f;%f;%f;%f', color1.r, color1.g, color1.b, color1.a, color2.r, color2.g, color2.b, color2.a, vertexCount, startAngle, endAngle, rotation, curviness)
        end

        local defaultMat = Material('vgui/white')
        local renderSetMaterial = render.SetMaterial
        local generateSingleMesh = circles.generateSingleMesh
        local generateMeshBatched = circles.generateMeshBatched
        local meshDraw = FindMetaTable('IMesh').Draw
        function circles.drawCircle(x, y, w, h, colors, vertexCount, startAngle, endAngle, material, rotation, curviness)
            if colors[2] == nil then
                colors[1] = colors
                colors[2] = colors
            end

            curviness = 2 / (curviness or 2)
            if vertexCount == nil then vertexCount = 24 end
            if startAngle == nil then
                startAngle = 0
                endAngle = 360
            end

            if rotation == nil then rotation = 0 end
            rotation = rotation * angleConverter
            startAngle = startAngle * angleConverter
            endAngle = endAngle * angleConverter
            if batch.batching then
                generateMeshBatched(x, y, w, h, vertexCount, startAngle, endAngle, colors, curviness)
            else
                local id = getId(colors[1], colors[2], vertexCount, startAngle, endAngle, rotation, curviness)
                local meshObj = cachedCircleMeshes[id]
                if meshObj == nil then
                    meshObj = generateSingleMesh(vertexCount, startAngle, endAngle, colors, rotation, curviness)
                    cachedCircleMeshes[id] = meshObj
                end

                material = material or defaultMat
                setUnpacked(matrix, w, 0, 0, x, 0, h, 0, y, 0, 0, 1, 0, 0, 0, 0, 1)
                renderSetMaterial(material)
                pushModelMatrix(matrix, true)
                meshDraw(meshObj)
                popModelMatrix()
            end
        end

        timer.Create('paint.circlesGarbageCollector' .. SysTime(), 60, 0, function()
            for k, v in pairs(cachedCircleMeshes) do
                v:Destroy()
                cachedCircleMeshes[k] = nil
            end
        end)
    end

    do
        local meshConstructor = Mesh
        local meshBegin = mesh.Begin
        local meshEnd = mesh.End
        local meshPosition = mesh.Position
        local meshColor = mesh.Color
        local meshTexCoord = mesh.TexCoord
        local meshAdvanceVertex = mesh.AdvanceVertex
        local PRIMITIVE_TRIANGLE_STRIP = MATERIAL_TRIANGLE_STRIP
        local sin, cos = math.sin, math.cos
        function circles.generateOutlineMeshSingle(vertexCount, startAngle, endAngle, colors, startU, endU, outlineWidth, curviness)
            local meshObj = meshConstructor()
            local startR, startG, startB, startA = colors[1].r, colors[1].g, colors[1].b, colors[1].a
            local endR, endG, endB, endA = colors[2].r, colors[2].g, colors[2].b, colors[2].a
            local deltaAngle = endAngle - startAngle
            local startRadius = 1 - outlineWidth
            meshBegin(meshObj, PRIMITIVE_TRIANGLE_STRIP, vertexCount * 2)
            for i = 0, vertexCount do
                local percent = i / vertexCount
                local angle = startAngle + deltaAngle * percent
                local sinn, coss = fpow(sin(angle), curviness), fpow(cos(angle), curviness)
                local u = startU + percent * (endU - startU)
                meshPosition(coss * startRadius, sinn * startRadius, 0)
                meshColor(startR, startG, startB, startA)
                meshTexCoord(0, u, 0)
                meshAdvanceVertex()
                meshPosition(coss, sinn, 0)
                meshColor(endR, endG, endB, endA)
                meshTexCoord(0, u, 1)
                meshAdvanceVertex()
            end

            meshEnd()
            return meshObj
        end
    end

    do
        local format = string.format
        local meshDraw = FindMetaTable('IMesh').Draw
        local pushModelMatrix = cam.PushModelMatrix
        local popModelMatrix = cam.PopModelMatrix
        local generateOutlineMeshSingle = circles.generateOutlineMeshSingle
        local matrix = Matrix()
        local setUnpacked = matrix.SetUnpacked
        local renderSetMaterial = render.SetMaterial
        local cachedCircleOutlineMeshes = {}
        local function getId(color1, color2, vertexCount, startAngle, endAngle, startU, endU, outlineWidth, curviness)
            return format('%x%x%x%x;%x%x%x%x;%u;%f;%f;%f;%f;%e', color1.r, color1.g, color1.b, color1.a, color2.r, color2.g, color2.b, color2.a, vertexCount, startAngle, endAngle, startU, endU, outlineWidth, curviness)
        end

        function circles.drawOutlineSingle(x, y, w, h, colors, vertexCount, startAngle, endAngle, material, startU, endU, outlineWidth, curviness)
            local id = getId(colors[1], colors[2], vertexCount, startAngle, endAngle, startU, endU, outlineWidth, curviness)
            local meshObj = cachedCircleOutlineMeshes[id]
            if meshObj == nil then
                meshObj = generateOutlineMeshSingle(vertexCount, startAngle, endAngle, colors, startU, endU, outlineWidth, curviness)
                cachedCircleOutlineMeshes[id] = meshObj
            end

            setUnpacked(matrix, w, 0, 0, x, 0, h, 0, y, 0, 0, 1, 0, 0, 0, 0, 1)
            renderSetMaterial(material)
            pushModelMatrix(matrix, true)
            meshDraw(meshObj)
            popModelMatrix()
        end

        timer.Create('paint.circleOutlinesGarbageCollector' .. SysTime(), 60, 0, function()
            for k, v in pairs(cachedCircleOutlineMeshes) do
                v:Destroy()
                cachedCircleOutlineMeshes[k] = nil
            end
        end)
    end

    do
        local defaultMat = Material('vgui/white')
        local angleConverter = math.pi / 180
        local drawOutlineSingle = circles.drawOutlineSingle
        local max = math.max
        function circles.drawOutline(x, y, w, h, colors, outlineWidth, vertexCount, startAngle, endAngle, material, startU, endU, curviness)
            if colors[2] == nil then
                colors[1] = colors
                colors[2] = colors
            end

            if vertexCount == nil then vertexCount = 24 end
            curviness = 2 / (curviness or 2)
            if startAngle == nil then
                startAngle = 0
                endAngle = 360
            end

            if startU == nil then
                startU = 0
                endU = 1
            end

            material = material or defaultMat
            startAngle = startAngle * angleConverter
            endAngle = endAngle * angleConverter
            outlineWidth = 1 / (1 + max(w, h) / outlineWidth)
            drawOutlineSingle(x, y, w, h, colors, vertexCount, startAngle, endAngle, material, startU, endU, outlineWidth, curviness)
        end
    end

    paint.circles = circles
end
