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
- Report size (decided, tune in playtests): dirt on 8 different players at 20 players. It should be HARD: the dirt must be specific evidence about that player, not vague.
- Still open: report size for smaller lobbies.

## Good team (10: 3 heads + 7 supports)

| Role | Main ability | Level 2 | Level 3 | Status |
|---|---|---|---|---|
| **Inspector** (head) | Lantern beam reveals hidden traces; analyses accessories up close. | Exact age of a trace | Unlocks a DAYTIME examination (once per game): question a player about where they were at a chosen bell; the game secretly tells the Inspector if it's true | Decided (the Inspector is the one special exception to 'one ability': so important that level 3 adds a daytime power) |
| **Physician** (head) | **Revive**: fully revives a downed player, once per night. | Revived player gives "last words" (a clue about the attacker) | Senses roughly where downed players are (heartbeat) | Decided |
| **Watchman** (head) | **Arrest -> trial**: locks a player in the cells for the rest of the night (they're SAFE from killers there). The next day opens with a quick trial (Config.DAY_TRIAL_LENGTH): the town votes guilty or not guilty. Guilty = out. Not guilty = released, and the Watchman gets a very long cooldown. Arresting an Informant counts as right. | Whistle first: freezes the target a few seconds | Shorter cooldown after a correct arrest | Decided |

Visible abilities (decided, for now): good abilities can be seen when used (e.g. someone reviving a player). Being seen is a risk (killers learn who to hunt), so players figure it out themselves. Revisit after playtests (ideas: look-alike actions, hidden results).

Supports (7): to design.

## Evil team (6: 3 heads + 3 supports)

Win (decided): evil is out when its 3 heads + 1 support are out (4 of 6 at 20 players). Good is out after 8 of 10 are out.

Killing rules (decided):
- A: not every head kills. Killers at the start: Cutthroat and Apothecary.
- B: team kill limit per night by lobby size (Config.EVIL_KILLS_PER_NIGHT: 12 = 1, 16 = 2, 20 = 2). After the last allowed kill, all evil kills lock until dawn.
- C: one killing support role, weaker than the heads; its kill unlocks only once an evil head is out.
- Contracts (decided): each night every killer secretly gets one target guaranteed NOT evil (evil players can't recognise each other). Killing someone else is allowed. A contract can become a clue. Unused kills are lost at dawn.

| Role | Main ability | Level 2 | Level 3 | Status |
|---|---|---|---|---|
| **Cutthroat** (head) | **Knife**: fast, silent attack that downs the victim; can travel through the sewers. Every kill leaves a How and a Who clue. | Shorter cooldown | Fewer traces | Decided |
| **Apothecary** (head) | **Poison**: poisons an object (teapot, lantern oil); whoever uses it is DOWNED a while later, wherever they are (so the Physician can still save them). Counts toward the night's kill limit when PLANTED. | Choose the delay | The poisoned object leaves no trace | Decided |
| **Forger** (head, does NOT kill) | **Forge**: plants a fake clue in the world (fake footprints, a thread from someone's scarf...). | Shorter cooldown | Forgeries fade over time like real clues | Decided (OPEN: who can spot a forgery's flaw) |

Support ideas (3 needed, nothing decided): killing support (locked until a head is out), Cleaner (moves bodies / wipes traces; took over from the Undertaker), Saboteur (tampers with task spots to cause mistake traces), Pickpocket (steals a clue from a journal), lamp/fire sabotage. Watch out: too many evidence-messing roles make clues pointless.
