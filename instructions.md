--[[
    INSTRUCTIONS FOR DOCUMENTING FUNCTIONS

    ALL documentation must be written using language that is simple, clear, and understandable by people who are NOT programmers. Avoid technical jargon whenever possible, and explain concepts as you would to someone new to code or scripting. Each example should clearly show what the function does—with well-commented usage and meaningful input so non-developers can follow easily.

    For each function listed in `functions.md`, write documentation using the exact structure and field labels as shown in the example below. Use the checkboxes in `functions.md` to track your progress - check off each function as you complete its documentation.

    `functions.md` serves as your master checklist containing all 412 undocumented library functions organized by category (lia, lia.admin, lia.attribs, etc.). Each function has a checkbox that you must mark as completed once documented.

    You must follow this format exactly for every function:
        - Place the documentation block directly above the function it describes.
        - Use the field labels just as shown: "Purpose", "When Called", "Parameters", "Returns", "Realm", "Example Usage".
        - In the "Parameters" section, list each parameter on a new line with its type, and describe in plain language what it does. State if a parameter is optional.
        - "Returns" should specify the return type, or `nil` for no return. Again, keep this simple.
        - "Realm" states if the function is used on "Server", "Client", or "Shared".
        - In "Example Usage", provide a single code block demonstrating a high complexity usage, clearly commented and showing how someone might use the function in practice as part of a larger or more realistic scenario. The Lua code example must always start with a tab, as shown in the example above.

    Example Documentation Block:
    --------------------------------------------------------------------------
--[[
        Purpose:
            Applies punishment actions (kick/ban) to a player based on infraction details

        When Called:
            When an administrative action needs to be taken against a player for rule violations

        Parameters:
            client (Player)
                The player who will be punished
            infraction (string)
                A simple explanation of what the player did wrong
            kick (boolean)
                True if the player should be kicked out of the game
            ban (boolean)
                True if the player should be banned from the game
            time (number)
                How many minutes to ban the player for (0 means forever)
            kickKey (string)
                The language key for the kick message (optional)
            banKey (string)
                The language key for the ban message (optional)

        Returns:
            nil

        Realm:
            Server

        Example Usage:

            ```lua
                -- This example chooses how to punish players based on the rule they broke.
                -- It uses a table of different punishments for different infractions
                -- and applies the correct punishment accordingly.
                local punishmentOptions = {
                    ["RDM"] =   {kick = true, ban = false, time = 0},          -- RDM: only kick
                    ["Cheating"] = {kick = true, ban = true, time = 0},        -- Cheating: kick and ban forever
                    ["Spam"] =  {kick = true, ban = false, time = 30}          -- Spam: kick and 30 min ban
                }
                local player = getPlayerByName("Bob")  -- Sample function to get a player
                local infractionType = "Cheating"      -- This would typically come from some infractions check
                local details = punishmentOptions[infractionType]
                if details then
                    lia.admin.applyPunishment(
                        player,
                        infractionType,
                        details.kick,
                        details.ban,
                        details.time,
                        "kickReasonKey",
                        "banReasonKey"
                    )
                else
                    print("No punishment set up for this infraction.")
                end
            ```
    ]]
    --------------------------------------------------------------------------

    INSTRUCTIONS:
    - For each function in functions.md, write its documentation using the above format and place it directly above the matching function definition.
    - Match the example's formatting, indentation, section order, and field labels exactly.
    - Each "Example Usage" must provide a single high-complexity code example, with clear comments. Every code example should be as clear and well-commented as possible for non-developers.
    - Only process and fully document one file per prompt run. Mark each function as complete by checking the checkbox next to it in functions.md.
    - Carefully follow the provided wording and structure for every documented function.

    CHECKLIST WORKFLOW:
    - Open functions.md and locate an unchecked function (marked with [ ]).
    - Find the corresponding function definition in the codebase.
    - Write documentation using the format above, placing it directly before the function.
    - Once documentation is complete, check the box in functions.md (change [ ] to [x]).
    - Move to the next unchecked function and repeat.

    PROGRESS TRACKING:
    - Functions marked with [ ] are not yet documented.
    - Functions marked with [x] have completed documentation.
    - Total count shows overall progress across all library categories.

    This prompt ensures that all function documentation you produce will be easy to understand for non-developers, consistently formatted, and positioned for maximum clarity.