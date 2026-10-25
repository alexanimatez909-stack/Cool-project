# Victorian mystery game (Roblox): full design summary

**Made for uploading to Claude.** This is everything decided so far, in one file.

## About this project
- **Who:** Alexander, a student who is new to game development and coding. Explain things simply, one step at a time.
- **What:** a hidden-role mystery game in a Victorian London–inspired city, built in Roblox Studio (Luau).
  - Nights are a first-person hunt, inspired by DOORS.
  - Days are a debate around an evidence board in the Courthouse (third person).
- **Phase:** greybox and core feel. Plain grey parts, no detailed art yet.
- **Rules for helping:**
  - Design decisions are Alexander's: ask him, don't decide for him.
  - The server is the authority for anything that matters. Clients ask through RemoteEvents and the server checks everything.
  - Every tuning number lives in one Config ModuleScript (ReplicatedStorage.Config).
  - Say where each script goes (ServerScriptService, StarterPlayerScripts, ReplicatedStorage...).
- **Code:** GitHub repo alexanimatez909-stack/Cool-project, branch `claude/quirky-hamilton-uylq4s`.

Everything below is DECIDED unless it is marked **OPEN** or **draft**.

## Contents
1. What's built so far
2. Still open
3. Game rules (clean summary)
4. Roles in detail
5. Accessories
6. Tasks, minigames and buildings (build sheet)
7. Movement, camera and animation decisions

---

# 1. What's built so far

**In Studio (made by Alexander):**
- The v11 map, nearly finished, including the courtroom (now a big table with an evidence board in the corner).
- Locations for most task spots.
- His own knife attack script. It isn't in the repo yet: the victim just teleports and lies flat, with no animations.

**Scripts in the repo:**

| Script | Where | What it does |
|---|---|---|
| Config | ReplicatedStorage | Every tuning number |
| NightCycle | ServerScriptService | Night clock: stages, dark districts, fog; publishes workspace attributes |
| Journal + JournalServer | ServerScriptService | Each player's clues and notes (Journal.addClue, Journal.clueCount) |
| AvatarRules | ServerScriptService | Everyone uses the blocky R15 StarterCharacter; copies only the player's shirt, pants, face and skin colour |
| LanternBelt | ServerScriptService | Lantern welded at the left hip; switches the light |
| Movement, MovementState | StarterPlayerScripts | Walk, sprint + stamina, crouch, camera side shift |
| CameraFeel, FirstPerson | StarterPlayerScripts | DOORS-style head bob, tilt, sprint FOV, reduce motion |
| FirstPersonBody | StarterPlayerScripts | Your own body is visible in first person |
| MovementAnimations | StarterPlayerScripts | Plays our custom animations; hip turn when strafing |
| LanternControl | StarterPlayerScripts | F key switches the lantern |
| Footsteps, BreathingSound, StaminaBar | StarterPlayerScripts | Sounds and stamina UI |
| NightFog, NightClock | StarterPlayerScripts | Fog and the on-screen clock |
| JournalUI | StarterPlayerScripts | The J notebook |

**Tools (paste into Studio's Command Bar):**
- `tools/RestorePlayerScripts.lua` installs all the scripts. It keeps the animation IDs already in your Config.
- `tools/MakeMovementAnimations.lua` builds the 7 movement animations.
- `tools/MakeStabAnimation.lua` builds the knife stab. It needs rebuilding in the new smooth style.

**Next planned:**
1. The Cutthroat stab animation, hooked into Alexander's knife script.
2. Then the smallest playable loop: one kill, one clue, the evidence board, the vote.
3. Task minigames, building one type first (Sort or Timing).

# 2. Still open
- **Voting:** how the vote is cast while seated at the courtroom table.
- **Role reveal:** how long it stays on screen, and whether it shows your team.
- **Claude's own defaults, waiting for Alexander to confirm:** F as the lantern key, the lantern on the left hip, and the same reach animation for turning it off.
- **End of match:** what the win screen shows (reveal all roles?), and whether everyone goes back to the lobby.
- **The lobby place:** what it looks like.
- **Ghosts:** how they look and move.
- **Footpad** level 2 and 3 (drafts). **Names:** the game title, and the "Arsonist" (working name).
- **Music and sound mood.** **Making money** (only idea so far: selling custom kill animations).
- **Task numbers:** charge per task, charge needed per level, how often role tasks appear, the size of the town bar, how many players get each common task.

---

# 3. Game rules (clean summary)


### 1. Players and teams
- Minimum 12 players, or the match doesn't start. Built for 20 first.
- Teams (good / evil / Informants): **12 = 6 / 4 / 2**, **16 = 8 / 5 / 3**, **20 = 10 / 6 / 4**. At 12 the only evil support is the Footpad.
- Smaller lobbies: the Clerk is always in; the Lamplighter only if the Arsonist is in; the Civilian only at 20; other good supports, evil supports (besides the Footpad) and Informants (besides the Editor) are drawn at random. All districts stay open.
- Good: 3 heads + 7 supports. Evil: 3 heads + 3 supports. Informants: 1 head + 3 supports.
- Nobody knows anyone's team, not even evil (no mark). Only the Informants know each other and have a private chat.
- Players join the game into a **lobby** (never straight into the city) and join matches from there, like Among Us. **Public:** you join a waiting pool and are teleported to the map when the game starts. Once 12 are in the pool, a 30 s countdown starts (more can join, up to 20). **Private:** join with a code; the host who made it presses start (still needs 12). Nobody can join a game that has already started.
- Closed lobbies: only players from the match can rejoin it.
- **Disconnects:** your character stays asleep where you were and can be killed or arrested. Rejoin at night = wake up there; at day = the Courthouse. Leave at night and you have until the next Dusk to come back; leave during the day and you have until the Dusk after the following night. If you don't come back, you count as out (only your name is announced; your journal drops). While away you can't vote but can be voted for.
- Later: experimental modes (e.g. Among Us-style, ~3 evil who know each other).

### 2. How to win
- **Evil loses** when its 3 heads + 1 support are out (12: all 4, 16: 4 of 5, 20: 4 of 6).
- **Good loses** when about 80% are out (12: 5 of 6, 16: 6 of 8, 20: 8 of 10).
- **Informants win** by publishing their report; they lose if all 4 are out, or if good or evil wins first.
- Death/vote-out only announces the name, never the role. A counter shows how many heads each side has left.

### 3. One cycle (about 5½ minutes, a game is about 5-6 cycles / 30 min)
- **Night, 4 minutes, first person:** everyone starts in the Courthouse Square.
  - Dusk 1:15 (lamps on, light fog, spread out)
  - Deep night 2:00 (2-3 random districts go dark, never the Square; main hunting time)
  - Last hour 0:45 (tense final push, fog lifts toward dawn)
- **Dawn:** a bell tolls once per death; missing players are named, never where/when/how.
- **Role reveal:** once everyone is in and the map has loaded, your screen shows your role and a short description.
- **Day, third person:** (0:30 trial if someone was arrested), 1:00 discussion at the evidence board, then 0:30 anonymous vote. You can skip. The player with the most votes is out; a tie (or skip on top) means nobody is out.
- **Alarm bell:** each player can ring it ONCE per match. It jumps the night to its last 15 seconds (early inquest). No "report body" button: finding a body doesn't end the night.

### 4. Killing
- Killers: the **Cutthroat** and the **Apothecary** (heads). The **Forger** (head) does not kill.
- **Footpad** (evil killing support): mugs players (knocks them out ~10 s, steals one clue). Its mug only becomes a kill once BOTH killing heads (Cutthroat and Apothecary) are out.
- **Evil supports (3):** Footpad always; the other 2 drawn at random from Cleaner, Arsonist and Swindler (task role: reads task lists, level 3 swaps a task to lure someone).
- **Arsonist** (evil support, working name): Among Us-style sabotage menu (gas main, fire, cut telegraph, lock gates), one shared cooldown, one active at a time; fixing gives task charge; fire never downs players. Each sabotage has fixed places (fire only in Soho; gas main: the Arsonist picks the district). Level 1: must be at the sabotage point. Level 2: shorter cooldown. Level 3: sabotage from anywhere.
- **Cleaner** (evil support): drags bodies, can dump them in the river at the Docks. Level 2: notified of kills with a general direction. Level 3: drag trails fade faster.
- **Team kill limit:** at most 2 kills per night for the whole evil team (12 players: 1). After that, all evil kills lock until dawn.
- **Contracts (first night only):** every killer secretly gets one target guaranteed NOT evil. They may kill someone else instead. Killing your contract gives a reward but leaves an extra trace.
- Kills don't stack: unused kills are lost at dawn.
- **Friendly fire on:** evil can kill evil; killing a teammate gives a very long cooldown.
- **Knife attack:** about 2.5 s. When the Cutthroat presses kill, the victim is grabbed and frozen until the stab, so it can't be escaped; the Cutthroat is stuck in place and visible to anyone watching.
- **Downed:** an attacked player is downed for 2 minutes, then dies. While downed you can crawl slowly and call for help (proximity voice/chat). The **Physician** can fully revive them. A player still downed at dawn dies.
- **Arrest -> trial:** the Watchman can arrest at night. The arrested player sits in the cells (safe from killers) until day, which opens with a quick trial (30 s): the town votes guilty (out) or not guilty (released; the Watchman gets a very long cooldown). Arresting an Informant counts as right.
- Finding a body at night doesn't stop the night; the finder gets task charge and the body is a big clue for the board.
- **Unfound bodies stay where they fell for the whole match** (only the Cleaner can move them). Once a body is **found**, it's removed (like reporting a body in Among Us), leaving a chalk outline. The dead player's journal stays on the ground there until someone picks it up. The clues a body gives fade over time: fresh = detailed, old = only the basics, but never nothing.

### 5. Abilities
- Every role has ONE main ability (cooldown, some use charges).
- Doing tasks fills a charge bar that upgrades the ability: level 1 -> 2 -> 3. The level is kept all match and is **hidden** from other players.
- Upgrades make it smarter, not just stronger (shorter cooldown, more info, fewer traces, a bit more range).

### 6. Tasks
- Everyone gets a short personal task list each night (in the journal): about 1-1½ minutes of task time.
- Common tasks (anyone can get them) every night; role tasks are rare.
- Each common task is handed to a limited number of players per night; your task spots are your own.
- Each task is graded on noise, reward, danger and time. No "hold a button" tasks. Multi-step tasks keep progress.
- Carrying something stops you sprinting.
- Every role has its own role task: 2 short steps at 2 spots, never sharing a spot with another role task.
- All tasks use about 6 reusable minigame types (sort, match, timing, order, steady hand, listen/find) with different pictures and words.
- Tasks don't leave a record automatically. Some tasks can leave a **mistake trace** if you slip up (e.g. spilled water -> wet footprints). You can only slip up on a task you were assigned.
- **Town bar:** good players' tasks fill a shared bar. When it's full at dawn, a **police report** pins one true clue to the board.
- Task roles: Handyman (good) and Swindler (evil); the Foreman (good) reads finished task spots.

### 7. Clues and evidence
- Sherlock Holmes, not CSI: one clue never convicts; you need about 3 pieces of evidence about a person.
- Any action can leave traces. Traces fade: old traces give vaguer clues. Head roles leave stronger traces.
- Clues glint in lantern light and make a small sound; hold E to investigate (only alone).
- Everyone wears 3 random Victorian accessories: **headwear, neckwear and footwear**, each shared by 3-4 players. Accessory clues are obvious: they show or name the item ("red scarf wool", "hobnail boot prints"). Only the Inspector can analyse marks on them. Full list: design/accessories.md.
- Only the Forger (evil head) can plant fake evidence.
- **Journal (J):** clues are added automatically, plus a free notes page. It drops when you die. Anyone can read its notes page for free; its clues stay hidden until someone picks it up, which means taking all of them. If the Cleaner dumps the body in the river, the journal sinks and its clues are lost. How many clues each player holds is shown during the day.
- **Courtroom:** everyone sits at a large table; a big evidence board in the corner updates live. While seated, click the evidence-board icon on screen, then click clues from your journal to pin them.
- **Board:** at day, in the voting room, your journal opens and you choose which clues to pin, **at most 2 per day**. No automatic pinning. Pins show your **name**. To give an **alibi**, show a clue from your own journal (never one off the board); it's shown to everyone and then used up (max 1 alibi per day; doesn't use a pin). Pinned clues leave the board after **2 days** and go back into the pinner's journal.

### 8. Movement and the night
- Walk, sprint (stamina, loud, clear footprints), crouch (quiet, faint prints). Killers are no faster. No jumping.
- The lantern always hangs from your belt at your left hip; switching it on or off (F), you reach down and turn the knob.
- Lantern: on = see clues but be seen; off = hidden but can't search well.
- Paper map (M) shows landmarks only, never players.
- Night: proximity voice/chat. Day: everyone. Ghosts have their own channel.
- **Ghosts** never talk to the living. They do ghost tasks for their team and can haunt once per night (flicker a lamp, cold breath, a knock; never words). Evil ghosts can haunt to mislead.

### 9. Roles so far
- **Good heads:** Inspector (lantern beam; level 3 adds a once-per-game daytime examination), Physician (revive, once per night), Watchman (arrest -> trial). Good abilities are visible when used; being seen makes you a target. Supports (7): Registrar (death register, like the Among Us Scientist), Constable (one escort per night), Foreman, Clerk (marks a board clue by day, investigates it at night, next day learns real/forged and chooses to strike it or keep it; L2 clues contributed, L3 clues picked up last night), Lamplighter, Handyman (task role) and 1 Civilian (at full charge, about every 2 nights, copies a DEAD player's ability for one use). No role ever appears twice.
- **Evil heads:** Cutthroat (knife, downs the victim; second ability Shadow: camouflage in darkness, dash up to 25 studs between dark spots to down a passer-by, and sees outlines of players in the dark), Apothecary (poison downs the victim later; counts toward the kill limit when planted; second ability Smoke vial: a cloud that blocks sight and lanterns, to escape), Forger (plants fake clues; the Clerk can spot them). 3 supports: Footpad always, plus 2 drawn at random from Cleaner, Swindler and Arsonist.
- **Informants:** Editor (head, Lead story), Stringer, Photographer, Eavesdropper. Shared report needs specific dirt on half of the living non-Informant players (min 3, recalculated each dawn; 8 at the start of a 20-player game); any Informant can publish it at a press (~20 s, loud).

---

# 4. Roles in detail

Every role has ONE main ability (cooldown or charges). Task charge upgrades it from level 1 to level 3; the level carries over between nights.

### Informants (4 at 20 players)

Shared report (decided): the Informants build ONE shared report. Once it is complete, ANY Informant can take it to a printing press and publish it (about 20 s, everyone hears the press clanking but not where).

| Role | Main ability | Level 2 | Level 3 | Status |
|---|---|---|---|---|
| **Editor** (head, 1 only) | **Lead story**: mark one player as "the story". All Informants get dirt on that player faster, and the Editor briefly hears roughly where that player is. | Shorter cooldown | Two stories at once | Decided |
| **Eavesdropper** | Hears proximity voice/chat from further away, even through doors. Standing near two players who are talking gives dirt on both. | Longer hearing range | Can toggle on to see nearby footsteps through walls for a limited time | Decided |
| **Stringer** | **Tail**: shadowing gives dirt faster, with quieter footsteps. | Shadowing works from further away | Also learns where the target goes next | Decided |
| **Photographer** | **Snapshot**: gets dirt from a distance, but the flash lights up the street for anyone nearby. | Shorter cooldown | Weaker flash, harder to spot | Decided |

Rejected: Newsboy (depended on randomly getting the "Read the evening paper" task).

- One of each role (decided): no duplicate Informant roles.
- Report size (decided, tune in playtests): scales with players still alive: half of the living non-Informant players, rounded up, minimum 3, recalculated each dawn (8 at the start of a 20-player game). Dirt on players who later die still counts. The dirt must be specific evidence about that player, not vague.

### Good team (10: 3 heads + 7 supports)

| Role | Main ability | Level 2 | Level 3 | Status |
|---|---|---|---|---|
| **Inspector** (head) | Lantern beam reveals hidden traces; analyses accessories up close. | Exact age of a trace | Unlocks a DAYTIME examination (once per game): question a player about where they were at a chosen bell; the game secretly tells the Inspector if it's true | Decided (the Inspector is the one special exception to 'one ability': so important that level 3 adds a daytime power) |
| **Physician** (head) | **Revive**: fully revives a downed player, once per night. | Revived player gives "last words" (a clue about the attacker) | Senses roughly where downed players are (heartbeat) | Decided |
| **Watchman** (head) | **Arrest -> trial**: locks a player in the cells for the rest of the night (they're SAFE from killers there). The next day opens with a quick trial (Config.DAY_TRIAL_LENGTH): the town votes guilty or not guilty. Guilty = out. Not guilty = released, and the Watchman gets a very long cooldown. Arresting an Informant counts as right. | Whistle first: freezes the target a few seconds | Shorter cooldown after a correct arrest | Decided |

Visible abilities (decided, for now): good abilities can be seen when used (e.g. someone reviving a player). Being seen is a risk (killers learn who to hunt), so players figure it out themselves. Revisit after playtests (ideas: look-alike actions, hidden results).

Supports (7 slots, no role ever appears twice):

| Role | Main ability | Level 2 | Level 3 | Status |
|---|---|---|---|---|
| **Foreman** (task role) | Sees which task spots were done tonight and roughly when (checks alibis) | Also learns the district | Can give someone else a task | Decided (max 1 per game) |
| **Lamplighter** | Relights dark lamps and fixes sabotages alone and faster (even the two-person fire) | Sees roughly where a sabotage was set off from | Protects one district from the gas main for the night | Decided |
| **Constable** | **Escort**: stays close to a player; if that player is attacked, the attack fails and the Constable sees the attacker's accessory | Lasts longer | Sees the attacker's full description | Decided: ONE escort per night, max 1 Constable per game |
| **Registrar** (Among Us Scientist) | **Death register**: shows who is alive, downed or dead right now. Uses a battery that tasks recharge. | Also shows the district where someone is downed/dead | Also shows when they went down | Decided |
| **Handyman** (task role) | Does tasks twice as fast and can finish another player's task for them (that player still gets the charge) | Carrying doesn't stop them sprinting | Each task they finish adds a little charge to everyone nearby | Decided |
| **Clerk** | **Investigate a clue**: during the DAY marks one clue on the board; that NIGHT does a short records task at the Courthouse to investigate it; the next day learns if it's real or forged and CHOOSES whether to strike it off the board or keep it. Forgeries get a day or two to cause trouble before they're caught. | **The ledger**: also looks up how many clues a player has contributed to the board in total | **Yesterday's haul**: also sees how many clues a player picked up last night (holding more than you picked up = stolen, catches the Footpad) | Decided |
| **Civilian** | **Take up the trade**: at full task charge (about every 2 nights), kneels at a dead player's body and gets ONE use of that player's ability. Can't be used on the living (so it's never a lie detector). | | | Decided |

Good support slots (decided, 7 at 20 players): Registrar, Constable, Foreman, Clerk, Lamplighter, Handyman and 1 Civilian. NO role ever appears twice (decided: duplicates cause unnecessary confusion).

Rejected: Spiritualist (won't work if the dead player leaves the game). Bloodhound handler not picked. The Clerk spots forgeries.

### Evil team (6: 3 heads + 3 supports)

Win (decided): evil is out when its 3 heads + 1 support are out (12: 4 of 4, 16: 4 of 5, 20: 4 of 6). Good is out when about 80% are out (12: 5 of 6, 16: 6 of 8, 20: 8 of 10).

Lobby sizes: 12 = 6/4/2 (evil support = Footpad only), 16 = 8/5/3 (Footpad + 1 random), 20 = 10/6/4. Smaller lobbies (decided, smart random draw): heads always in; Good supports: the Clerk is ALWAYS in (counters the Forger and Footpad, who are always in); the Lamplighter is only in if the Arsonist was drawn; the Civilian only at 20; the remaining seats are drawn at random from Registrar, Constable, Foreman, Handyman (20: all 7; 16: 5; 12: 3). Evil supports: Footpad always + random (20: 2, 16: 1, 12: none) from Cleaner, Arsonist, Swindler. Informants: Editor + random from Stringer, Photographer, Eavesdropper (20: 3, 16: 2, 12: 1).

Killing rules (decided):
- A: not every head kills. Killers at the start: Cutthroat and Apothecary.
- B: team kill limit per night by lobby size (Config.EVIL_KILLS_PER_NIGHT: 12 = 1, 16 = 2, 20 = 2). After the last allowed kill, all evil kills lock until dawn.
- C: one killing support role, the Footpad, weaker than the heads; its kill unlocks only once BOTH killing heads (Cutthroat and Apothecary) are out.
- Contracts (decided): on the FIRST night only, every killer secretly gets one target guaranteed NOT evil (evil players can't recognise each other). Killing someone else is allowed. Killing your contract target gives a reward but leaves an EXTRA trace. Unused kills are lost at dawn.

| Role | Main ability | Level 2 | Level 3 | Status |
|---|---|---|---|---|
| **Cutthroat** (head) | **Knife**: fast, silent attack that downs the victim; can travel through the sewers. Every kill leaves a How and a Who clue. PLUS a second ability, **Shadow**: camouflaged while standing in darkness (e.g. under a lamp that is out); can dash from one dark spot to another (e.g. two broken lamps diagonal across a lit street), downing a passer-by during the dash animation and staying camouflaged at the far end (uses the Knife's cooldown and the night kill limit). | Shorter cooldown | Fewer traces | Decided. Shadow (decided): works only where the light level is below a threshold (Config). Lamps are NOT smashed; Shadow only uses spots that are already dark (dark districts, lamps out from the Arsonist's gas main). The camouflage lasts indefinitely and can't be revealed by abilities; the ONLY way to see him is to stand right next to him with a lantern. The Cutthroat's identity must stay secret when he attacks (the whole point of the game). Dash: from one dark spot to another up to 25 studs away (Config), downing a passer-by during the dash animation and staying camouflaged at the far end. The dash leaves no trace. It uses the Knife's cooldown and the night kill limit. Dark-adapted eyes (part of Shadow, decided): passive; in darkness (same light threshold) the Cutthroat sees OUTLINES of players within ~40 studs (Config) but no details (no accessories, can't tell who is who) and can't see or read clues, so he can hunt without a lantern but still needs one to investigate. The kill scene itself still leaves its normal clue. |
| **Apothecary** (head) | **Poison**: poisons an object (teapot, lantern oil); whoever uses it is DOWNED a while later, wherever they are (so the Physician can still save them). Counts toward the night's kill limit when PLANTED. PLUS a second ability, **Smoke vial**: throws a vial that makes a thick cloud of chemical smoke (~15 s) that blocks sight and lantern light, to escape if spotted. Cooldown gets shorter with tasks and assists (poison used: -20 s; poison victim dies: -60 s). | Choose the delay | The poisoned object leaves no trace | Decided |
| **Forger** (head, does NOT kill) | **Forge**: plants a fake clue in the world (fake footprints, a thread from someone's scarf...). | Shorter cooldown | Forgeries fade over time like real clues | Decided (the Clerk can spot forgeries) |

Supports (3 slots, decided): the Footpad is ALWAYS in; the other 2 are drawn at random each game from Cleaner, Arsonist and Swindler.

| Role | Main ability | Level 2 | Level 3 | Status |
|---|---|---|---|---|
| **Footpad** (killing support) | **Mug**: knocks a player out (~10 s) and steals one clue from their journal. Once BOTH killing heads are out, the mug becomes a KILL (downs the victim) and still steals a clue. Leaves a clear clue for the victim (e.g. "they wore a red scarf"). | (draft) Shorter cooldown | (draft) Chooses which clue to steal (e.g. the newest) | Decided (levels draft) |
| **Swindler** (task role) | Reads one player's task list (knows where they'll go tonight) | Reads two lists | Swaps one task on a player's list, sending them to a spot of the Swindler's choosing (a lure) | Decided |
| **Cleaner** | **Drag**: drags a body somewhere else; can dump bodies in the river at the Docks (the dropped journal sinks with it and its clues are LOST, decided). | Gets notified when someone is killed, with the general direction of the kill | Drag trails fade faster | Decided |
| **Arsonist** (working name) | **Sabotage** (Among Us-style): picks one sabotage from a menu; all share one cooldown and only one can be active at a time. Fixing a sabotage gives task charge (anyone can fix, evil too). | Shorter cooldown | Can sabotage from ANYWHERE (level 1-2 must go to the sabotage point) | Decided |

Sabotage menu (decided). Each sabotage has FIXED places on the map, like Among Us (e.g. the fire can only happen in Soho), so players learn where to run:
- **Gas main** (like Lights): the Arsonist PICKS a district; all its lamps go out, even lit ones. Fix: turn the valve back on at that district's gas main. Unfixed: dark until the next bell.
- **Fire** (like Reactor): a building in Soho (only there) catches fire; loud, everyone hears it. Fix: TWO players pump water at two spots at the same time. Unfixed: all traces/clues in that district burn away and the district closes for the rest of the night. Players are NOT downed by fire (decided).
- **Cut telegraph** (like Comms): task lists vanish and the alarm bell can't be rung. Fix: splice the wire at the telegraph office. Unfixed: fixed automatically at the next bell.
- **Lock gates** (like Doors): one district's gates or sewer grates lock for ~20 s, trapping people. Can't be fixed; opens by itself.
- Cut: Tamper (task-spot tampering). Pickpocket was folded into the Footpad. Watch out: too many evidence-messing roles make clues pointless.

---

# 5. Accessories

Every player gets one item from each category at the start of the match. Each item is shared by 3-4 players, so one accessory clue narrows it down to a few people and two together can point to one. At 20 players there are 6 items per category; smaller lobbies use fewer items so each is still shared by 3-4 players. Players' own Roblox accessories are removed.

Rule: accessory clues must be OBVIOUS. The clue shows a piece of the item or names it in plain words, so players only work out WHO wears it, never WHAT it is.
Examples: "A thread of red scarf wool caught on the railings." / "Hobnail boot prints heading north."

Anyone can see what others wear. Only the Inspector can analyse marks ON accessories (mud on boots, a torn scarf, soot on a hat).

### Headwear
| Item | Clue it can leave |
|---|---|
| Top hat | Dropped top hat; a witness sees a tall hat |
| Bowler hat | Dropped bowler; a witness sees a round hat |
| Flat cap | Dropped flat cap |
| Deerstalker | Dropped deerstalker; its ear flaps seen by a witness |
| Bonnet | Bonnet ribbon caught on a fence |
| Straw boater | Bits of straw from a boater |

### Neckwear (colour is the clue)
| Item | Clue it can leave |
|---|---|
| Red scarf | Red scarf wool |
| Green scarf | Green scarf wool |
| Grey muffler | Grey muffler fluff |
| Black cravat | Black cravat silk |
| White bow tie | White bow-tie silk (bright in lantern light) |
| Yellow spotted neckerchief | Yellow spotted cotton scrap |

### Footwear (the footprint is the clue)
| Item | Footprint |
|---|---|
| Hobnail boots | Ring of nail dots |
| Riding boots | Long narrow print with a tall heel |
| Wooden clogs | Square print; they also clack loudly when walking |
| Polished shoes | Clean, pointed print |
| Worn-out boots | Patch hole in the sole |
| Rubber galoshes | Wavy rubber pattern |

---

# 6. Tasks, minigames and buildings (build sheet)


Status: **designed, nothing scripted yet.** Numbers are starting points for playtests (they'll live in Config).

---

### 1. What tasks are for
- Doing tasks **fills your charge bar**, which upgrades your ability: level 1 → 2 → 3 (like Apex Legends Evo). Your level is kept all match.
- Ability levels are **hidden**: only you know your own level.
- Tasks **spread players across the map**, so people are alone and on the move.
- Tasks can **reveal clues** through mistakes (section 6).
- **Good** players' tasks also fill a shared **town bar**. Evil and Informant tasks don't count, and nobody can see whose tasks counted.
  - When the bar is full at dawn, a **police report** pins one TRUE clue to the board, e.g. "One of the killers wears hobnail boots". It can't be forged but is never enough on its own.
  - Then the bar resets.
- **Everyone** does tasks: good, evil and Informants. Seeing someone at a task proves nothing. What it means is up to the players.

### 2. Task list each night
- Each player gets a **short personal list** every night, shown in the **journal** (J).
- About **1 to 1½ minutes** of task time in total (roughly 2 long or 5 short tasks). That leaves about half the night for searching, abilities and hunting.
- Travel between tasks should be short, but still move players around the map.
- **Common tasks** (anyone can get them) come every night.
  - Each common task is only given to a **limited number of players** per night (Config), so lists stay varied.
- **Role tasks** are rare: every 2 nights, or random with a base amount and a limit (Config).
- Each task has **fixed spots** in the districts. A player's task spots are their own.
- Some tasks need **teamwork** (two players).

### 3. General rules for every task
- **No "hold a button" tasks.** Each one is a short activity, with lots of variety.
- Riskier tasks pay more. Every task is graded on time, noise, danger and reward (section 5).
- **Multi-step tasks keep finished steps** if you're interrupted or walk away.
- **Carrying anything** (bucket, letter, crate, parcel...) **stops you sprinting**.
- **No visual tasks that prove innocence** (unlike Among Us).
- Lamps in dark districts: only specific ones can be relit.

### 4. Minigame types (build these once, reuse everywhere)
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

### 5. Common tasks (11)
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

### 6. Mistake traces
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

### 7. Role tasks (one per role, 20)
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

### 8. Buildings for the task spots
Three levels of building. **Most buildings stay solid blocks.**
- **Full interior:** walk in, several rooms, hiding spots. Only a few.
- **Front room:** the door opens into one small room with the task in it.
- **Shopfront:** used from the street (window, counter, door, yard). Nobody goes inside.

Lighting:
- Some interiors are lit, some dark, by building.
- Rule of thumb: **open at night = lit** (pubs, coffee house, surgery, watch house, newspaper night shift).
- **Shut for the night = dark** (shops, workshops, offices, stores).
- Dark interiors need a lantern and **count as dark for the Cutthroat's Shadow**.

#### Full interiors (6)
| Building | District | Lit/dark | Used by |
|---|---|---|---|
| Courthouse (built) | Courthouse Square | Lit | Day phase, detective's office, archive, cells |
| Pub | Docks | Lit | Eavesdropper (listen at the bar) |
| Music hall | Soho | Lit | Swindler (mark the cards) |
| Chemist's (shop + back room) | Market | Shop lit, back room dark | Apothecary (mix tinctures) |
| Warehouse | Docks | Dark | Foreman (work rota) |
| Cathedral | Cathedral quarter | Dark (candles only) | Eavesdropper (confessional grille) |

#### Front rooms (23)
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

#### Shopfronts and outdoor role spots
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

### 9. Studio checklist: every spot to build
Tick these off as you build them. The list is grouped by district.

**Courthouse Square:** Courthouse (built) with detective's office + archive · police box · newsstand · clock (common: wind the clock) · NO sabotage point or press for role tasks here.

**Market:** chemist's (full interior, dark back room) · coffee house · newspaper office · post office · auction house · tobacconist shopfront · cart wheel in the piazza · 3 lamp posts for the beat · market stalls with scales (common) · clock (common) · printing press (common: read the paper).

**Soho:** music hall (full interior, card table) · watch house · small pub · pawnbroker · darkroom · lamplighter's store · workshop · engraver's · Broad Street pump (common: fetch water) + doorstep to carry the bucket to · printing press (common).

**Terraces:** doctor's surgery · register office · stationer's · photographer's studio · cab rank · mews door handles · delivery house door · mews stables with horses and stall signs (common: feed the horses).

**Docks:** pub (full interior, bar) · warehouse (full interior, office) · sailors' mission · knife-grinder's · tannery · oil depot · loose cobble in an alley · quay with crates + manifest (common: check the cargo) · crane (common: hoist a crate, 2 players) · goods station / coal wharf boiler (common: stoke the boiler) · Goods yard crates (Foreman tally) · printing press (common).

**Cathedral quarter:** cathedral (full interior, dark, confessional grille) · coroner's office · parish records · physic garden · undertaker's yard · 3 lamps for the wicks · churchyard headstones with names (common: tend a grave).

**Sewer:** a ledge in the River sewer (Cutthroat).

**Everywhere:** street lamps (common: relight a lamp; only specific lamps in dark districts) · letter pick-up points and delivery doors in different districts (common: post a letter).

### 10. Other rules that touch tasks
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

### 11. Still open (decide later or in playtests)
- How many players can get the same common task per night (Config).
- How often role tasks appear: "every 2 nights" vs "random with a base amount and a limit".
- How much charge each task gives, and how much charge each level needs.
- How big the town bar is.
- The exact building for each spot on the v11 map (picked in Studio as you build).
- Which minigame type to build first (suggestion: **Sort** or **Timing**, since many steps use them).

### 12. Suggested setup in Studio (not decided, just makes scripting easier later)
- Put every task spot in a Folder in Workspace called **TaskSpots**.
- Make each spot a Part (it can be invisible), placed where the player stands.
- Name each spot clearly, for example `Role_Cutthroat_1`, `Role_Cutthroat_2`, `Common_FetchWater_Pump1`.
- Give each Part attributes:
  - **District**, e.g. "Docks".
  - **Lit**: true or false, for interiors.
- Then the task script can find every spot by name without anyone hand-copying positions.

---

# 7. Movement, camera and animation decisions
- **Body:** everyone spawns as the same blocky R15 rig ("Block Avatar (2012)", named StarterCharacter). Only the player's shirt, pants, t-shirt, face and skin colour are copied onto it. No accessories from their own avatar, and no body shapes.
- **Style:** like DOORS. Fluid, calm, slightly hunched and careful. Stylised, not lifelike.
- **Speeds:** walk 18, sprint 28 (stamina), crouch 8. No jumping.
- **Step rhythm:** fixed at a calm 2 steps per second walking and 2.8 sprinting. Running fast means longer strides, not quicker steps. The animations, head bob and footstep sounds all follow this rhythm.
- **Arms when walking:**
  - The shoulder barely moves; the elbow does the work.
  - At the back of the swing, the arm hangs by your side.
  - Swinging forward, the forearm lifts until it points almost straight ahead, with the hand flat.
  - Then it lowers slowly across the back-swing, never thrown down.
  - Arms swing with the opposite leg. No hand twist.
  - Walk, sprint and crouch-walk are smooth loops (a curve through the key poses), so nothing bounces.
- **Idle:** hands hanging by the sides, with the gentlest swing as you breathe.
- **Crouch:** one foot planted in front, the other knee down behind, arms held forward.
- **Moving sideways or backwards:**
  - The hips turn toward the direction of travel, with a slight lean. The chest stays facing forward.
  - Walking backwards plays the walk in reverse.
  - Everyone sees this on every player.
- **Camera:**
  - First person at night.
  - Head bob, tilt, and a wider view while sprinting.
  - Stepping sideways slides the view toward that shoulder.
  - A "reduce motion" setting turns these off.
- **Your body in first person:**
  - It is always there and simply sits below your view.
  - Looking ahead, you see none of it. Tilting down a little, you may catch the edge of a hand. Looking right down, you see your chest, arms, legs and lantern.
  - It never pops in. Only parts almost touching the camera are hidden.
- **Lantern:**
  - It always hangs at the left hip.
  - F switches it on or off: you reach down and turn the knob (about 0.9 s), and the light changes when the knob turns.
- **Animation set:** Idle, Walk, Sprint, CrouchIdle, CrouchWalk, OutOfBreath, LanternToggle. They are drafts in Studio until published; then the IDs go in Config.MOVEMENT_ANIMATIONS.
- **Knife stab:**
  - About 2.5 s. Look over the shoulder, draw the knife from the back, snap to the target, thrust forward.
  - Pull the knife out (a little blood, not graphic), glance at it, and put it back under the coat.
  - Markers: KnifeOut 0.65, Hit 1.30, Bloody 1.80, KnifeAway 2.35.
  - The victim is grabbed and frozen until the Hit. The attacker is locked in place and visible the whole time.
  - The first-person camera follows the head during the stab.
  - Any cosmetic kill animations sold later must keep the same length and Hit timing.
