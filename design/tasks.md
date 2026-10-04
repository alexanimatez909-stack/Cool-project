# Tasks list (draft, agreed with Alexander; nothing built yet)

Grades are 1 (low) to 3 (high). Time = how long it takes, Noise = disruption (how much it draws attention),
Danger = how exposed/isolated the spot is, Reward = charge earned (riskier tasks pay more).
New tasks can be added at any time; each new task gets a row here.

## Rules for tasks
- There are two kinds: common tasks (anyone can get them, any role, any team, any night; NOT the Among Us meaning) and role tasks (only for a specific role).
- Role tasks (decided): every role has its own role task at its own spot (no two role tasks share a location); more charge than common tasks; being seen doing one hints at your role.
- Every player gets common tasks every night. Role tasks are rare: they only show up every 2 nights, or randomly with a base amount and a limit (Config values), so we don't need hundreds of role tasks per role to keep them interesting.
- Each night, a common task is only handed out to a limited number of players so lists stay varied (the exact number is a Config value, tuned in playtests).
- Carrying anything (bucket, letter, crate...) stops you sprinting.
- Multi-step tasks keep finished steps if you're interrupted or leave.

## Common tasks

| # | Task | Where | What you do (the puzzle) | Time | Noise | Danger | Reward |
|---|---|---|---|---|---|---|---|
| 1 | Relight a street lamp | Street lamps in any district | Turn the gas valve to keep the flame steady (too much flares, too little dies). In a dark district only specific lamps can be relit: braver, higher reward, partly undoes the darkness | 1 | 2 (light shows you) | 1 (3 in a dark district) | 1 (3 in a dark district) |
| 2 | Weigh the goods | Market stalls | Put brass weights on the scales until they balance | 1 | 1 | 1 | 1 |
| 3 | Feed the horses | Terraces mews | Each stall's sign says how many scoops; give each horse the right amount | 1 | 2 (horses whinny) | 1 | 1 |
| 4 | Wind the clock | Clock in the Square or Market | Set the hands to the time the bells say, then wind | 1 | 2 (chimes) | 1 | 1 |
| 5 | Read the evening paper | Printing presses | Find tonight's story among the headlines; chance of a rumour clue | 2 | 1 | 1 | 1 + clue chance |
| 6 | Post a letter | Pick up in one district, deliver in another | Read the address and find the right door using street signs and landmarks (carrying) | 2 | 1 | 2 | 2 |
| 7 | Fetch water | Street pumps (Broad Street pump, Soho) | Pump in rhythm to fill the bucket without spilling, then carry it to a doorstep (carrying) | 2 | 2 (squeaky pump) | 2 | 2 |
| 8 | Check the cargo | Docks quay | Match crate stamps to the manifest; teamwork optional (one reads, one checks = faster) | 2 | 1 | 2 (fog) | 2 |
| 9 | Stoke the boiler | Goods station / coal wharf | Shovel coal to keep the pressure needle in the green | 2 | 3 (clanging) | 2 | 3 |
| 10 | Tend a grave | Churchyard | Find the headstone with the name on your card among many, then lay flowers | 2 | 1 | 3 (lots of cover) | 3 |
| 11 | Hoist a crate | Docks crane | One cranks the winch, one guides the hook; teamwork required (very slow alone) | 3 | 3 | 2 | 3 |

## Mistake traces
Only some tasks can leave a clue, and only when the assigned player makes a mistake (you can't slip up at a task you don't have).
A mistake costs you (redo the step, less charge). The trace is vague about time and ages like any trace.
World clues anyone can find; marks on clothing only the Inspector can analyse.

| Task | Mistake | World clue (anyone) | Mark on clothing (Inspector only) |
|---|---|---|---|
| Fetch water | Spill the bucket | Puddle at the pump, wet footprints leading away | Wet boots / trouser hems |
| Stoke the boiler | Spill coal | Scattered coal, black footprints | Coal dust on sleeves |
| Relight a street lamp | Let the flame flare | Scorch mark on the lamp post | Scorched sleeve |
| Tend a grave | Slip on the wet grass | Skid mark and knee prints by the grave | Muddy knees |
| Weigh the goods, Read the paper, Feed the horses, Wind the clock | none | - | - |

## Still open
- Role tasks (per role), and the task-related role.
- How task records (alibis) are shown to players.

## Role tasks (DRAFT, waiting for Alexander's feedback)

Rules (decided): every role has its own role task; medium length, split into 2 short steps (~10 s each) at 2 different spots; finished steps are kept if interrupted; more charge than common tasks; being seen doing one hints at your role. No two role tasks share a spot (checked when assigning). Spots also avoid sabotage points (gas mains, telegraph office, the Soho fire) and the printing presses. District names are placeholders until the v10 map files are in the repo.

| Role | Step 1 (spot) | Step 2 (spot) |
|---|---|---|
| Inspector | Pull the right case file by its number (Courthouse, detective's office) | Compare it with the coroner's notes (Church quarter, coroner's office) |
| Physician | Sort pills into the right bottles (Terraces, doctor's surgery) | Restock the first-aid kit (Docks, sailors' mission) |
| Watchman | Collect lantern and rattle (Soho, watch house) | Walk the beat: check 3 lamp posts in order (Market) |
| Registrar | Copy names into the ledger (Terraces, register office) | Check the burials list (Church quarter, parish records) |
| Constable | Sign in (Courthouse Square, police box) | Try the door handles along a mews (Terraces) |
| Foreman | Read the work rota (Docks, warehouse office) | Chalk the tally on crates (Goods yard) |
| Clerk | File papers in order (Courthouse, archive) | Collect the court letters (Market, post office) |
| Lamplighter | Fill the oil can (Soho, lamplighter's store) | Trim the wicks on 3 lamps (Church quarter) |
| Handyman | Pick the right tools (Soho, workshop) | Fix a broken cart wheel (Market piazza) |
| Civilian | Collect a parcel (Soho, pub) | Deliver it to the right house (Terraces) |
| Cutthroat | Sharpen the blade in rhythm (Docks, knife-grinder's) | Stash it on a sewer ledge (River sewer) |
| Apothecary | Mix tinctures from a recipe (Market, chemist's back room) | Pick nightshade (Church quarter, physic garden) |
| Forger | Cut paper to size (Terraces, stationer's) | Carve a fake stamp (Soho, engraver's) |
| Footpad | Haggle over stolen goods (Soho, pawnbroker) | Hide the loot under a loose cobble (Docks alley) |
| Cleaner | Fetch a sack (Church quarter, undertaker's yard) | Fill a bucket of lye (Docks, tannery) |
| Swindler | Mark the cards (Soho, music hall card table) | Rig the ledger (Market, auction house) |
| Arsonist | Fill a flask with lamp oil (Docks, oil depot) | Buy matches (Market, tobacconist) |
| Editor | Check the headlines (Courthouse Square, newsstand) | Proof-read the draft (Market, newspaper office) |
| Stringer | Listen for gossip (Market, coffee house) | Tip the cabbie for news (Terraces, cab rank) |
| Photographer | Load the plates (Terraces, photographer's studio) | Develop them in time (Soho, darkroom) |
| Eavesdropper | Listen at the bar (Docks, pub) | Listen at the confessional grille (Church quarter) |
