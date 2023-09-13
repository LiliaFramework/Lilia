--------------------------------------------------------------------------------------------------------
local langTable = {
    radioFreq = "Frequency",
    radioSubmit = "Submit",
    radioNoRadio = "You don't have any radio to adjust.",
    radioNoRadioComm = "You don't have any radio to communicate",
    radioFormat = "%s radios in \"%s\"",
}

--------------------------------------------------------------------------------------------------------
function MODULE:ModuleLoaded()
    table.Merge(lia.lang.stored["english"], langTable)
end
--------------------------------------------------------------------------------------------------------