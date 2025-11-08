# Configuration

Configuration options for the Steam Group Rewards module.

---

Overview

The Steam Group Rewards module automatically gives money to players who join your Steam group. You can set which group to check and how much money to give.

---

### GroupID

#### 📋 Description
The Steam group ID to check. Players in this group will receive rewards.

#### ⚙️ Type
String

#### 💾 Default Value
""

#### 🌐 Realm
Server

#### 💡 Usage Notes
- Find your Steam group ID from the group's URL
- Example: If your group URL is `steamcommunity.com/groups/myserver`, the ID is `myserver`
- Leave empty ("") to disable rewards

---

### MoneyReward

#### 📋 Description
How much money to give players who are in your Steam group.

#### ⚙️ Type
Number

#### 💾 Default Value
500

#### 🌐 Realm
Server

#### 💡 Usage Notes
- Set this to match your server's economy
- Players receive this amount when they join the group
- Higher values give bigger rewards but may affect economy balance

