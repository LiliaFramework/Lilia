<h1 style="text-align:center; font-size:2rem; font-weight:bold;">About</h1>

**Name:**
Steam Group Rewards

**Description:**

Provides a Steam group membership rewards system that automatically checks player membership in your Steam group and rewards them with in-game currency for joining. Features automatic group member checking, manual claim system, and configurable rewards.

<h2 style="text-align:center; font-size:1.5rem; font-weight:bold;">Main Features</h2>

- Automatic Steam group membership checking every 5 minutes
- Manual membership verification on demand
- Configurable money rewards for group members
- One-time claim per character system
- Player commands for easy group access and reward claiming
- Server-side tracking of claimed rewards

<h2 style="text-align:center; font-size:1.5rem; font-weight:bold;">Configuration</h2>

- **GroupID**: Your Steam group ID/name (set in module.lua)
- **MoneyReward**: Amount of money to reward players (default: 500, set in module.lua)

<h2 style="text-align:center; font-size:1.5rem; font-weight:bold;">Player Commands</h2>

- `/group`: Opens your Steam group page in the player's browser
- `/claim`: Claims the group membership reward (if eligible)

<h2 style="text-align:center; font-size:1.5rem; font-weight:bold;">Setup Instructions</h2>

1. Set your Steam group ID in `module.lua` (line 8): `MODULE.GroupID = "yourgroupname"`
2. Optionally adjust the money reward amount (line 9): `MODULE.MoneyReward = 500`
3. Players use `/group` to join your Steam group
4. After joining, players use `/claim` to receive their reward
5. The system automatically checks group membership every 5 minutes

<p align="center"><a href="https://github.com/LiliaFramework/Modules/raw/refs/heads/gh-pages/steamgrouprewards.zip" style="display:inline-block;padding:12px 24px;font-size:1.5rem;font-weight:bold;text-decoration:none;color:#fff;background-color:var(--md-primary-fg-color,#007acc);border-radius:4px;">DOWNLOAD HERE</a></p>
