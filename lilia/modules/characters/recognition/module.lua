--[[--
Characters - Recognition

**Configuration Values:**.

- **RecognitionEnabled**: Is character recognition enabled? | **bool**.

- **FactionAutoRecognize**: Do members from the same faction always auto-recognize each other? | **bool**.

- **FakeNamesEnabled**: Are fake names enabled? | **bool**.

- **ScoreboardHiddenVars**: Variables to hide from a non-recognized character in the scoreboard | **table**.

- **ChatIsRecognized**: Chat types that are recognized | **table**.

- **MemberToMemberAutoRecognition**: Factions that auto-recognize members between each other | **table**.
]]
-- @configurations Recognition
MODULE.name = "Characters - Recognition"
MODULE.author = "76561198312513285"
MODULE.discord = "@liliaplayer"
MODULE.desc = "Adds the ability to recognize people / You can also allow auto faction recognition."
MODULE.identifier = "RecognitionCore"