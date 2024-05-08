--- Configuration for Recognition Module.
-- @realm shared
-- @configurations Recognition


-- @table Configuration
-- @field RecognitionEnabled Is character recognition enabled? | **bool**
-- @field FactionAutoRecognize Do members from the same faction always auto-recognize each other? | **bool**
-- @field FakeNamesEnabled Are fake names enabled? | **bool**
-- @field ScoreboardHiddenVars Variables to hide from a non-recognized character in the scoreboard | **table**
-- @field ChatIsRecognized Chat types that are recognized | **table**
-- @field MemberToMemberAutoRecognition Factions that auto-recognize members between each other | **table**
MODULE.name = "Characters - Recognition"
MODULE.author = "76561198312513285"
MODULE.discord = "@liliaplayer"
MODULE.desc = "Adds the ability to recognize people / You can also allow auto faction recognition."
MODULE.identifier = "RecognitionCore"
