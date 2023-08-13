hook.Add("OnCharInfoSetup", "AttribCreateCharInfoText", function(panel)
	if suppress and suppress.attrib then return end
	panel.attribName = panel.info:Add("DLabel")
	panel.attribName:Dock(TOP)
	panel.attribName:SetFont("liaMediumFont")
	panel.attribName:SetTextColor(color_white)
	panel.attribName:SetExpensiveShadow(1, Color(0, 0, 0, 150))
	panel.attribName:DockMargin(0, 10, 0, 0)
	panel.attribName:SetText("Skills")
	panel.attribs = panel.info:Add("DScrollPanel")
	panel.attribs:Dock(FILL)
	panel.attribs:DockMargin(0, 10, 0, 0)
end)

hook.Add("OnCharInfoSetup", "AttribOnCharInfoSetup", function(panel)
	if not IsValid(panel.attribs) then return end
	local char = LocalPlayer():getChar()
	local boost = char:getBoosts()

	for k, v in SortedPairsByMemberValue(lia.attribs.list, "name") do
		local attribBoost = 0

		if boost[k] then
			for _, bValue in pairs(boost[k]) do
				attribBoost = attribBoost + bValue
			end
		end

		local bar = panel.attribs:Add("liaAttribBar")
		bar:Dock(TOP)
		bar:DockMargin(0, 0, 0, 3)
		local attribValue = char:getAttrib(k, 0)

		if attribBoost then
			bar:setValue(attribValue - attribBoost or 0)
		else
			bar:setValue(attribValue)
		end

		local maximum = v.maxValue or lia.config.MaxAttributes
		bar:setMax(maximum)
		bar:setReadOnly()
		bar:setText(Format("%s [%.1f/%.1f] (%.1f", L(v.name), attribValue, maximum, attribValue / maximum * 100) .. "%)")

		if attribBoost then
			bar:setBoost(attribBoost)
		end
	end
end)