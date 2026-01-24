# Configuration

Configuration options for the Slots module.

---

Overview

The Slots module lets you configure slot machine gambling settings. You can set the cost to play, how often players win jackpots, and how much money they win for different symbol combinations.

---

### GamblingPrice

#### 📋 Description
How much money players pay to spin the slot machine once.

#### ⚙️ Type
Number

#### 💾 Default Value
13

#### 🌐 Realm
Server

#### 💡 Usage Notes
- Lower values (1-10) make gambling cheap and accessible
- Medium values (10-50) work well for most servers
- Higher values (50+) create expensive, high-stakes gambling

---

### JackpotChance

#### 📋 Description
The percentage chance of winning a jackpot. Higher numbers mean more frequent jackpots.

#### ⚙️ Type
Number

#### 💾 Default Value
32

#### 🌐 Realm
Server

#### 💡 Usage Notes
- Low (1-10%): Rare but exciting jackpots
- Medium (20-40%): Balanced, recommended for most servers
- High (50%+): Very common jackpots, may be too easy

---

### TripleBarClover

#### 📋 Description
How much players win when they get three bar clover symbols. This is multiplied by the bet amount.

#### ⚙️ Type
Number

#### 💾 Default Value
200

#### 🌐 Realm
Server

#### 💡 Usage Notes
- Example: Bet of 13 × 200 = 2,600 currency win
- This is a high-value win, so use a large multiplier

---

### SingleBarDollarSign

#### 📋 Description
How much players win for the single bar dollar sign combination.

#### ⚙️ Type
Number

#### 💾 Default Value
50

#### 🌐 Realm
Server

#### 💡 Usage Notes
- Example: Bet of 13 × 50 = 650 currency win
- This gives players small wins to keep them playing

---

### Lucky7Diamond

#### 📋 Description
How much players win for the lucky 7 diamond combination. This is the biggest jackpot.

#### ⚙️ Type
Number

#### 💾 Default Value
500

#### 🌐 Realm
Server

#### 💡 Usage Notes
- Example: Bet of 13 × 500 = 6,500 currency win
- This should be the highest multiplier since it's the best combination

---

### HorseShoeDoubleBar

#### 📋 Description
How much players win for the horseshoe double bar combination.

#### ⚙️ Type
Number

#### 💾 Default Value
100

#### 🌐 Realm
Server

#### 💡 Usage Notes
- Example: Bet of 13 × 100 = 1,300 currency win
- This is a medium-value win between small and jackpot wins

