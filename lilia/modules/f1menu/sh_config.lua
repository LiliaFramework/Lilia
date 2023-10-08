--------------------------------------------------------------------------------------------------------
function GenerateRules()
    local body = "<h1>Game Server Rules</h1>"
    -- Introduction
    body = body .. "<p>Welcome to our game server! To ensure a fun and fair gaming experience for everyone, please abide by the following rules:</p>"
    -- Rule 1
    body = body .. "<h2>Rule 1: Respect Others</h2>"
    body = body .. "<p>Be respectful and considerate of other players. Avoid any form of harassment, hate speech, or personal attacks. Treat fellow gamers the way you want to be treated.</p>"
    -- Rule 2
    body = body .. "<h2>Rule 2: No Cheating or Hacking</h2>"
    body = body .. "<p>Cheating, hacking, or using any third-party software to gain an unfair advantage is strictly prohibited. Play fair and enjoy the game's challenge.</p>"
    -- Rule 3
    body = body .. "<h2>Rule 3: No Exploits</h2>"
    body = body .. "<p>Exploiting bugs or glitches in the game to gain an unfair advantage is not allowed. If you discover a bug, report it to the administrators.</p>"
    -- Rule 4
    body = body .. "<h2>Rule 4: Follow Admin Instructions</h2>"
    body = body .. "<p>Listen to and follow the instructions of the server administrators and moderators. Ignoring their directives may result in disciplinary action.</p>"
    -- Rule 5
    body = body .. "<h2>Rule 5: No Spamming or Advertising</h2>"
    body = body .. "<p>Do not spam the chat or use it for advertising unrelated content or other servers. Keep the chat enjoyable for everyone.</p>"
    -- Rule 6
    body = body .. "<h2>Rule 6: Play Fair</h2>"
    body = body .. "<p>Play the game fairly and competitively. Do not engage in any form of cheating or exploiting to gain an unfair advantage.</p>"
    -- Rule 7
    body = body .. "<h2>Rule 7: No Griefing</h2>"
    body = body .. "<p>Do not engage in griefing, which includes intentionally disrupting the gameplay of others or destroying their in-game creations.</p>"
    -- Rule 8
    body = body .. "<h2>Rule 8: Respect Server-Specific Rules</h2>"
    body = body .. "<p>Be aware that some games may have server-specific rules or guidelines. Familiarize yourself with these rules and follow them accordingly.</p>"
    -- Conclusion
    body = body .. "<p>Thank you for being a part of our gaming community. By following these rules, you contribute to a positive and enjoyable gaming environment for everyone.</p>"

    return body
end

--------------------------------------------------------------------------------------------------------
function GenerateTutorial()
    local body = "<h1>How to Make Perfect Scrambled Eggs</h1>"
    -- Introduction
    body = body .. "<p>Scrambled eggs are a classic breakfast favorite, and making them is easier than you might think. In this tutorial, we'll walk you through the steps to create delicious, fluffy scrambled eggs that will start your day off right.</p>"
    -- Ingredients
    body = body .. "<h2>Ingredients:</h2>"
    body = body .. "<ul>"
    body = body .. "<li>2-3 large eggs</li>"
    body = body .. "<li>Salt and pepper to taste</li>"
    body = body .. "<li>1-2 tablespoons of butter or cooking oil</li>"
    body = body .. "<li>Optional toppings (cheese, chives, herbs, or diced vegetables)</li>"
    body = body .. "</ul>"
    -- Tools
    body = body .. "<h2>Tools:</h2>"
    body = body .. "<ul>"
    body = body .. "<li>Non-stick skillet</li>"
    body = body .. "<li>Whisk or fork</li>"
    body = body .. "<li>Bowl</li>"
    body = body .. "<li>Spatula</li>"
    body = body .. "</ul>"
    -- Instructions
    body = body .. "<h2>Instructions:</h2>"
    -- Step 1
    body = body .. "<h3>Step 1: Prepare Your Eggs</h3>"
    body = body .. "<p>Start by cracking the eggs into a bowl. Use a whisk or fork to beat the eggs until the yolks and whites are fully combined. You can add a pinch of salt and a dash of pepper to season the eggs at this stage.</p>"
    -- Step 2
    body = body .. "<h3>Step 2: Heat the Pan</h3>"
    body = body .. "<p>Place a non-stick skillet over medium-low heat and add 1-2 tablespoons of butter or cooking oil. Allow it to melt and coat the bottom of the pan evenly.</p>"
    -- Step 3
    body = body .. "<h3>Step 3: Scramble the Eggs</h3>"
    body = body .. "<p>Pour the beaten eggs into the heated skillet. Let them sit undisturbed for a moment to allow the edges to set.</p>"
    -- Step 4
    body = body .. "<h3>Step 4: Stir Gently</h3>"
    body = body .. "<p>Using a spatula, gently stir the eggs in a folding motion. Continue to cook and stir until the eggs are mostly set but still slightly runny.</p>"
    -- Step 5
    body = body .. "<h3>Step 5: Optional Toppings</h3>"
    body = body .. "<p>If you like, you can add optional toppings such as cheese, chives, herbs, or diced vegetables to the eggs at this point. Stir them in and cook for an additional minute until everything is heated through.</p>"
    -- Step 6
    body = body .. "<h3>Step 6: Serve and Enjoy</h3>"
    body = body .. "<p>Transfer your scrambled eggs to a plate, and they're ready to enjoy! Season with additional salt and pepper if needed.</p>"

    return body
end

--------------------------------------------------------------------------------------------------------
lia.config.RulesEnabled = false
--------------------------------------------------------------------------------------------------------
lia.config.TutorialEnabled = false
--------------------------------------------------------------------------------------------------------