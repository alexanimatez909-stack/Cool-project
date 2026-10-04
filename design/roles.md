# Roles (being designed for a 20-player server: 10 good / 6 evil / 4 Informants)

Every role has ONE main ability (cooldown or charges). Task charge upgrades it from level 1 to level 3; the level carries over between nights.

## Informants (4 at 20 players)

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

## Good team (10: 3 heads + 7 supports)

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

## Evil team (6: 3 heads + 3 supports)

Win (decided): evil is out when its 3 heads + 1 support are out (12: 4 of 4, 16: 4 of 5, 20: 4 of 6). Good is out when about 80% are out (12: 5 of 6, 16: 6 of 8, 20: 8 of 10).

Lobby sizes: 12 = 6/4/2 (evil support = Footpad only), 16 = 8/5/3 (Footpad + 1 random), 20 = 10/6/4.

Killing rules (decided):
- A: not every head kills. Killers at the start: Cutthroat and Apothecary.
- B: team kill limit per night by lobby size (Config.EVIL_KILLS_PER_NIGHT: 12 = 1, 16 = 2, 20 = 2). After the last allowed kill, all evil kills lock until dawn.
- C: one killing support role, the Footpad, weaker than the heads; its kill unlocks only once BOTH killing heads (Cutthroat and Apothecary) are out.
- Contracts (decided): on the FIRST night only, every killer secretly gets one target guaranteed NOT evil (evil players can't recognise each other). Killing someone else is allowed. Killing your contract target gives a reward but leaves an EXTRA trace. Unused kills are lost at dawn.

| Role | Main ability | Level 2 | Level 3 | Status |
|---|---|---|---|---|
| **Cutthroat** (head) | **Knife**: fast, silent attack that downs the victim; can travel through the sewers. Every kill leaves a How and a Who clue. PLUS a second ability, **Shadow**: camouflaged while standing in darkness (e.g. under a lamp that is out); can dash from one dark spot to another (e.g. two broken lamps diagonal across a lit street), downing a passer-by during the dash animation and staying camouflaged at the far end (uses the Knife's cooldown and the night kill limit). | Shorter cooldown | Fewer traces | Decided. Shadow (decided): works only where the light level is below a threshold (Config). Lamps are NOT smashed; Shadow only uses spots that are already dark (dark districts, lamps out from the Arsonist's gas main). The camouflage lasts indefinitely and can't be revealed by abilities; the ONLY way to see him is to stand right next to him with a lantern. The Cutthroat's identity must stay secret when he attacks (the whole point of the game). Dash: from one dark spot to another up to 25 studs away (Config), downing a passer-by during the dash animation and staying camouflaged at the far end. The dash leaves no trace. It uses the Knife's cooldown and the night kill limit. Dark-adapted eyes (part of Shadow, decided): passive; in darkness (same light threshold) the Cutthroat sees OUTLINES of players within ~40 studs (Config) but no details (no accessories, can't tell who is who) and can't see or read clues, so he can hunt without a lantern but still needs one to investigate. The kill scene itself still leaves its normal clue. |
| **Apothecary** (head) | **Poison**: poisons an object (teapot, lantern oil); whoever uses it is DOWNED a while later, wherever they are (so the Physician can still save them). Counts toward the night's kill limit when PLANTED. PLUS a second ability, **Smoke vial**: throws a vial that makes a thick cloud of chemical smoke (~15 s) that blocks sight and lantern light, to escape if spotted. Cooldown gets shorter with tasks and assists. | Choose the delay | The poisoned object leaves no trace | Decided |
| **Forger** (head, does NOT kill) | **Forge**: plants a fake clue in the world (fake footprints, a thread from someone's scarf...). | Shorter cooldown | Forgeries fade over time like real clues | Decided (the Clerk can spot forgeries) |

Supports (3 slots, decided): the Footpad is ALWAYS in; the other 2 are drawn at random each game from Cleaner, Arsonist and Swindler.

| Role | Main ability | Level 2 | Level 3 | Status |
|---|---|---|---|---|
| **Footpad** (killing support) | **Mug**: knocks a player out (~10 s) and steals one clue from their journal. Once BOTH killing heads are out, the mug becomes a KILL (downs the victim) and still steals a clue. Leaves a clear clue for the victim (e.g. "they had a cane"). | (draft) Shorter cooldown | (draft) Chooses which clue to steal (e.g. the newest) | Decided (levels draft) |
| **Swindler** (task role) | Reads one player's task list (knows where they'll go tonight) | Reads two lists | Swaps one task on a player's list, sending them to a spot of the Swindler's choosing (a lure) | Decided |
| **Cleaner** | **Drag**: drags a body somewhere else; can dump bodies in the river at the Docks (the dropped journal sinks with it and its clues are LOST, decided). | Gets notified when someone is killed, with the general direction of the kill | Drag trails fade faster | Decided |
| **Arsonist** (working name) | **Sabotage** (Among Us-style): picks one sabotage from a menu; all share one cooldown and only one can be active at a time. Fixing a sabotage gives task charge (anyone can fix, evil too). | Shorter cooldown | Can sabotage from ANYWHERE (level 1-2 must go to the sabotage point) | Decided |

Sabotage menu (decided). Each sabotage has FIXED places on the map, like Among Us (e.g. the fire can only happen in Soho), so players learn where to run:
- **Gas main** (like Lights): the Arsonist PICKS a district; all its lamps go out, even lit ones. Fix: turn the valve back on at that district's gas main. Unfixed: dark until the next bell.
- **Fire** (like Reactor): a building in Soho (only there) catches fire; loud, everyone hears it. Fix: TWO players pump water at two spots at the same time. Unfixed: all traces/clues in that district burn away and the district closes for the rest of the night. Players are NOT downed by fire (decided).
- **Cut telegraph** (like Comms): task lists vanish and the alarm bell can't be rung. Fix: splice the wire at the telegraph office. Unfixed: fixed automatically at the next bell.
- **Lock gates** (like Doors): one district's gates or sewer grates lock for ~20 s, trapping people. Can't be fixed; opens by itself.
- Cut: Tamper (task-spot tampering). Pickpocket was folded into the Footpad. Watch out: too many evidence-messing roles make clues pointless.
