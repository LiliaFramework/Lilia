function FrameworkHUD:ShouldDrawBranchWarning()
    if self.BranchWarning and BRANCH ~= "x86-64" then return true end
end

function FrameworkHUD:DrawBranchWarning()
    draw.SimpleText("We recommend the use of the x86-64 Garry's Mod Branch for this server, consider swapping as soon as possible.", "liaSmallFont", ScrW() * .5, ScrH() * .97, Color(255, 255, 255, 10), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end
