# Tasks: build sheet (everything decided so far)

One file with everything about tasks, for building them in Studio. It combines design/tasks.md,
design/buildings.md and the task rules from CLAUDE.md / design/rules.md. If anything here changes,
those files change too.

Status: **designed, nothing scripted yet.** Numbers are starting points for playtests (they'll live in Config).

---

## 1. What tasks are for
- Doing tasks **fills your charge bar**, which upgrades your ability: level 1 → 2 → 3 (like Apex Legends Evo). Your level is kept all match.
- Ability levels are **hidden**: only you know your own level.
- Tasks **spread players across the map**, so people are alone and on the move.
- Tasks can **reveal clues** through mistakes (section 6).
- **Good** players' tasks also fill a shared **town bar**. Evil and Informant tasks don't count, and nobody can see whose tasks counted.
  - When the bar is full at dawn, a **police report** pins one TRUE clue to the board, e.g. "One of the killers wears hobnail boots". It can't be forged but is never enough on its own.
  - Then the bar resets.
- **Everyone** does tasks: good, evil and Informants. Seeing someone at a task proves nothing. What it means is up to the players.

## 2. Task list each night
- Each player gets a **short personal list** every night, shown in the **journal** (J).
- About **1 to 1½ minutes** of task time in total (roughly 2 long or 5 short tasks). That leaves about half the night for searching, abilities and hunting.
- Travel between tasks should be short, but still move players around the map.
- **Common tasks** (anyone can get them) come every night.
  - Each common task is only given to a **limited number of players** per night (Config), so lists stay varied.
- **Role tasks** are rare: every 2 nights, or random with a base amount and a limit (Config).
- Each task has **fixed spots** in the districts. A player's task spots are their own.
- Some tasks need **teamwork** (two players).

## 3. General rules for every task
- **No "hold a button" tasks.** Each one is a short activity, with lots of variety.
- Riskier tasks pay more. Every task is graded on time, noise, danger and reward (section 5).
- **Multi-step tasks keep finished steps** if you're interrupted or walk away.
- **Carrying anything** (bucket, letter, crate, parcel...) **stops you sprinting**.
- **No visual tasks that prove innocence** (unlike Among Us).
- Lamps in dark districts: only specific ones can be relit.

## 4. Minigame types (build these once, reuse everywhere)
There are about **6 minigame types**. Every task step, common or role, is one of these types with its own
text, picture and spot. A new task is just new settings, not new code.
**Build one type first, test it, then add the rest.**

| Type | What you do | Used by (examples) |
|---|---|---|
| **Sort** | Drag items into the right slots | Sort pills, file papers, pick the right tools, copy names into the ledger, restock a kit, rig the ledger, weigh goods |
| **Match** | Find the one that matches a sample | Case file vs coroner's notes, carve a stamp, mark the cards, deliver to the right house, check the cargo, sign in, buy matches |
| **Timing** | Press when a moving marker is in the zone | Sharpen the blade, develop plates, pump water, fix the cart wheel, haggle, tip the cabbie |
| **Order** | Visit or click things in the right order | Walk the beat, trim 3 wicks, try the door handles, chalk the tally |
| **Steady hand** | Keep a pointer inside a moving or narrow area | Fill the oil can, mix tinctures, fill the lye bucket, cut paper, relight a lamp, stoke the boiler, load plates |
| **Listen / find** | Pick out the right sound or spot in a scene | Listen at the bar, gossip, confessional grille, hide loot, tend a grave, read the paper |

## 5. Common tasks (11)
Grades: 1 = low, 3 = high. Noise = how much attention it draws. Danger = how exposed or isolated the spot is. Reward = charge earned.

| # | Task | Where | What you do | Time | Noise | Danger | Reward |
|---|---|---|---|---|---|---|---|
| 1 | Relight a street lamp | Street lamps, any district | Turn the gas valve to keep the flame steady (too much flares, too little dies). In a dark district only specific lamps can be relit: braver, higher reward, partly undoes the darkness | 1 | 2 (the light shows you) | 1 (3 if dark district) | 1 (3 if dark district) |
| 2 | Weigh the goods | Market stalls | Put brass weights on the scales until they balance | 1 | 1 | 1 | 1 |
| 3 | Feed the horses | Terraces mews | Each stall's sign says how many scoops; give each horse the right amount | 1 | 2 (horses whinny) | 1 | 1 |
| 4 | Wind the clock | Clock in the Square or the Market | Set the hands to the time the bells say, then wind | 1 | 2 (chimes) | 1 | 1 |
| 5 | Read the evening paper | Printing presses | Find tonight's story among the headlines; chance of a rumour clue | 2 | 1 | 1 | 1 + clue chance |
| 6 | Post a letter | Pick up in one district, deliver in another | Read the address and find the right door using street signs and landmarks (carrying) | 2 | 1 | 2 | 2 |
| 7 | Fetch water | Street pumps (Broad Street pump, Soho) | Pump in rhythm to fill the bucket without spilling, then carry it to a doorstep (carrying) | 2 | 2 (squeaky pump) | 2 | 2 |
| 8 | Check the cargo | Docks quay | Match crate stamps to the manifest; teamwork optional (one reads, one checks = faster) | 2 | 1 | 2 (fog) | 2 |
| 9 | Stoke the boiler | Goods station / coal wharf | Shovel coal to keep the pressure needle in the green | 2 | 3 (clanging) | 2 | 3 |
| 10 | Tend a grave | Churchyard | Find the headstone with the name on your card among many, then lay flowers | 2 | 1 | 3 (lots of cover) | 3 |
| 11 | Hoist a crate | Docks crane | One cranks the winch, one guides the hook; teamwork REQUIRED (very slow alone) | 3 | 3 | 2 | 3 |

## 6. Mistake traces
Some tasks leave a clue when the player slips up. These replace automatic records. The anti-faking rules:
1. A mistake **costs you**: you redo the step and get less charge.
2. The trace **cuts both ways**: it puts you at the spot and leaves world clues pointing to you.
3. Mistake traces are **vague about time** and fade like any trace.
4. You can **only slip up on a task you were assigned**, so you can't fake one somewhere else.

| Task | Mistake | World clue (anyone can find) | Mark on clothing (Inspector only) |
|---|---|---|---|
| Fetch water | Spill the bucket | Puddle at the pump, wet footprints leading away | Wet boots / trouser hems |
| Stoke the boiler | Spill coal | Scattered coal, black footprints | Coal dust on sleeves |
| Relight a street lamp | Let the flame flare | Scorch mark on the lamp post | Scorched sleeve |
| Tend a grave | Slip on the wet grass | Skid mark and knee prints by the grave | Muddy knees |
| Weigh the goods, Read the paper, Feed the horses, Wind the clock | none | - | - |

## 7. Role tasks (one per role, 20)
Rules:
- **Every role** has its own role task, themed to the role.
- **Medium length:** 2 short steps (~10 s each) at **2 different spots**. Finished steps are kept.
- **More charge** than common tasks.
- Being **seen** doing one **hints at your role** (that's the risk).
- **No two role tasks share a spot** (checked when assigning).
- Spots also **avoid** the sabotage points (gas mains, telegraph office, the Soho fire building) and the printing presses.
- Minigame types per step are a first pass. Swap any that feel wrong after testing.

| Role | Team | Step 1 (spot) | Type | Step 2 (spot) | Type |
|---|---|---|---|---|---|
| Inspector | Good head | Pull the right case file by its number (Courthouse, detective's office) | Match | Compare it with the coroner's notes (Cathedral quarter, coroner's office) | Match |
| Physician | Good head | Sort pills into the right bottles (Terraces, doctor's surgery) | Sort | Restock the first-aid kit (Docks, sailors' mission) | Sort |
| Watchman | Good head | Collect lantern and rattle (Soho, watch house) | Sort | Walk the beat: check 3 lamp posts in order (Market) | Order |
| Registrar | Good support | Copy names into the ledger (Terraces, register office) | Sort | Check the burials list (Cathedral quarter, parish records) | Listen / find |
| Constable | Good support | Sign in (Courthouse Square, police box) | Match | Try the door handles along a mews (Terraces) | Order |
| Foreman | Good support | Read the work rota (Docks, warehouse office) | Listen / find | Chalk the tally on crates (Goods yard) | Order |
| Clerk | Good support | File papers in order (Courthouse, archive) | Sort | Collect the court letters (Market, post office) | Match |
| Lamplighter | Good support | Fill the oil can (Soho, lamplighter's store) | Steady hand | Trim the wicks on 3 lamps (Cathedral quarter) | Order |
| Handyman | Good support | Pick the right tools (Soho, workshop) | Sort | Fix a broken cart wheel (Market piazza) | Timing |
| Civilian | Good support | Collect a parcel (Soho, pub) | Match | Deliver it to the right house (Terraces) | Match |
| Cutthroat | Evil head | Sharpen the blade in rhythm (Docks, knife-grinder's) | Timing | Stash it on a sewer ledge (River sewer) | Listen / find |
| Apothecary | Evil head | Mix tinctures from a recipe (Market, chemist's back room) | Steady hand | Pick nightshade (Cathedral quarter, physic garden) | Listen / find |
| Forger | Evil head | Cut paper to size (Terraces, stationer's) | Steady hand | Carve a fake stamp (Soho, engraver's) | Match |
| Footpad | Evil support | Haggle over stolen goods (Soho, pawnbroker) | Timing | Hide the loot under a loose cobble (Docks alley) | Listen / find |
| Cleaner | Evil support | Fetch a sack (Cathedral quarter, undertaker's yard) | Listen / find | Fill a bucket of lye (Docks, tannery) | Steady hand |
| Swindler | Evil support | Mark the cards (Soho, music hall card table) | Match | Rig the ledger (Market, auction house) | Sort |
| Arsonist | Evil support | Fill a flask with lamp oil (Docks, oil depot) | Steady hand | Buy matches (Market, tobacconist) | Match |
| Editor | Informant head | Check the headlines (Courthouse Square, newsstand) | Listen / find | Proof-read the draft (Market, newspaper office) | Match |
| Stringer | Informant | Listen for gossip (Market, coffee house) | Listen / find | Tip the cabbie for news (Terraces, cab rank) | Timing |
| Photographer | Informant | Load the plates (Terraces, photographer's studio) | Steady hand | Develop them in time (Soho, darkroom) | Timing |
| Eavesdropper | Informant | Listen at the bar (Docks, pub) | Listen / find | Listen at the confessional grille (Cathedral quarter) | Listen / find |

## 8. Buildings for the task spots
Three levels of building. **Most buildings stay solid blocks.**
- **Full interior:** walk in, several rooms, hiding spots. Only a few.
- **Front room:** the door opens into one small room with the task in it.
- **Shopfront:** used from the street (window, counter, door, yard). Nobody goes inside.

Lighting:
- Some interiors are lit, some dark, by building.
- Rule of thumb: **open at night = lit** (pubs, coffee house, surgery, watch house, newspaper night shift).
- **Shut for the night = dark** (shops, workshops, offices, stores).
- Dark interiors need a lantern and **count as dark for the Cutthroat's Shadow**.

### Full interiors (6)
| Building | District | Lit/dark | Used by |
|---|---|---|---|
| Courthouse (built) | Courthouse Square | Lit | Day phase, detective's office, archive, cells |
| Pub | Docks | Lit | Eavesdropper (listen at the bar) |
| Music hall | Soho | Lit | Swindler (mark the cards) |
| Chemist's (shop + back room) | Market | Shop lit, back room dark | Apothecary (mix tinctures) |
| Warehouse | Docks | Dark | Foreman (work rota) |
| Cathedral | Cathedral quarter | Dark (candles only) | Eavesdropper (confessional grille) |

### Front rooms (23)
| Building | District | Lit/dark | Used by |
|---|---|---|---|
| Detective's office (inside Courthouse) | Courthouse Square | Lit | Inspector |
| Archive (inside Courthouse) | Courthouse Square | Lit | Clerk |
| Doctor's surgery | Terraces | Lit | Physician |
| Sailors' mission | Docks | Lit | Physician |
| Watch house | Soho | Lit | Watchman |
| Pub (small) | Soho | Lit | Civilian (collect parcel) |
| Pawnbroker | Soho | Lit | Footpad |
| Coffee house | Market | Lit | Stringer |
| Newspaper office | Market | Lit | Editor |
| Post office | Market | Lit | Clerk |
| Coroner's office | Cathedral quarter | Dark | Inspector |
| Parish records | Cathedral quarter | Dark | Registrar |
| Register office | Terraces | Dark | Registrar |
| Stationer's | Terraces | Dark | Forger |
| Photographer's studio | Terraces | Dark | Photographer |
| Darkroom | Soho | Dark (red safelight) | Photographer |
| Lamplighter's store | Soho | Dark | Lamplighter |
| Workshop | Soho | Dark | Handyman |
| Engraver's | Soho | Dark | Forger |
| Knife-grinder's | Docks | Dark | Cutthroat |
| Tannery | Docks | Dark | Cleaner |
| Oil depot | Docks | Dark | Arsonist |
| Auction house | Market | Dark | Swindler |

### Shopfronts and outdoor role spots
| Spot | District | Used by |
|---|---|---|
| Police box | Courthouse Square | Constable |
| Newsstand | Courthouse Square | Editor |
| Tobacconist (shopfront) | Market | Arsonist |
| Cab rank | Terraces | Stringer |
| Mews doors (a row of door handles) | Terraces | Constable |
| Delivery house door | Terraces | Civilian |
| Broken cart wheel | Market piazza | Handyman |
| 3 lamp posts (the beat) | Market | Watchman |
| Crates for the tally | Goods yard | Foreman |
| Loose cobble | Docks alley | Footpad |
| Sewer ledge | River sewer | Cutthroat |
| Physic garden | Cathedral quarter | Apothecary |
| Undertaker's yard | Cathedral quarter | Cleaner |
| 3 lamps (wicks) | Cathedral quarter | Lamplighter |

## 9. Studio checklist: every spot to build
Tick these off as you build them. The list is grouped by district.

**Courthouse Square:** Courthouse (built) with detective's office + archive · police box · newsstand · clock (common: wind the clock) · NO sabotage point or press for role tasks here.

**Market:** chemist's (full interior, dark back room) · coffee house · newspaper office · post office · auction house · tobacconist shopfront · cart wheel in the piazza · 3 lamp posts for the beat · market stalls with scales (common) · clock (common) · printing press (common: read the paper).

**Soho:** music hall (full interior, card table) · watch house · small pub · pawnbroker · darkroom · lamplighter's store · workshop · engraver's · Broad Street pump (common: fetch water) + doorstep to carry the bucket to · printing press (common).

**Terraces:** doctor's surgery · register office · stationer's · photographer's studio · cab rank · mews door handles · delivery house door · mews stables with horses and stall signs (common: feed the horses).

**Docks:** pub (full interior, bar) · warehouse (full interior, office) · sailors' mission · knife-grinder's · tannery · oil depot · loose cobble in an alley · quay with crates + manifest (common: check the cargo) · crane (common: hoist a crate, 2 players) · goods station / coal wharf boiler (common: stoke the boiler) · Goods yard crates (Foreman tally) · printing press (common).

**Cathedral quarter:** cathedral (full interior, dark, confessional grille) · coroner's office · parish records · physic garden · undertaker's yard · 3 lamps for the wicks · churchyard headstones with names (common: tend a grave).

**Sewer:** a ledge in the River sewer (Cutthroat).

**Everywhere:** street lamps (common: relight a lamp; only specific lamps in dark districts) · letter pick-up points and delivery doors in different districts (common: post a letter).

## 10. Other rules that touch tasks
These belong to other systems but affect how tasks work.
- **Handyman:** does tasks twice as fast and can finish another player's task for them (they still get the charge). L2: carrying doesn't stop him sprinting. L3: each task adds a little charge to everyone nearby.
- **Foreman:** sees which task spots were done tonight and roughly when (to check alibis). L2: the district. L3: can give someone else a task.
- **Swindler:** reads one player's task list (knows where they'll go). L2: two lists. L3: swaps one task on a player's list, sending them to a spot of his choosing (a lure).
- **Clerk:** separate from the role task above. After marking a clue on the board by day, that NIGHT he does a short records task at the Courthouse to learn if it's real or forged.
- **Cut telegraph sabotage** (Arsonist): everyone's task lists vanish until it's fixed (splice the wire at the telegraph office) or the next bell.
- **Fixing any sabotage** gives task charge (anyone can fix).
- **Finding a body** first gives task charge.
- **Apothecary:** doing tasks shortens his Smoke vial cooldown.
- **Ghosts:** dead players do ghost tasks for their own team. Good ghosts add to the town bar, evil ghosts help charge evil abilities, Informant ghosts add a little dirt progress.

## 11. Still open (decide later or in playtests)
- How many players can get the same common task per night (Config).
- How often role tasks appear: "every 2 nights" vs "random with a base amount and a limit".
- How much charge each task gives, and how much charge each level needs.
- How big the town bar is.
- The exact building for each spot on the v11 map (picked in Studio as you build).
- Which minigame type to build first (suggestion: **Sort** or **Timing**, since many steps use them).

## 12. Suggested setup in Studio (not decided, just makes scripting easier later)
- Put every task spot in a Folder in Workspace called **TaskSpots**.
- Make each spot a Part (it can be invisible), placed where the player stands.
- Name each spot clearly, for example `Role_Cutthroat_1`, `Role_Cutthroat_2`, `Common_FetchWater_Pump1`.
- Give each Part attributes:
  - **District**, e.g. "Docks".
  - **Lit**: true or false, for interiors.
- Then the task script can find every spot by name without anyone hand-copying positions.
