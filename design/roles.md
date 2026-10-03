# Roles (being designed for a 20-player server: 8 good / 8 evil / 4 Informants)

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

## Good team (8: 3 heads + 5 supports)
To design.

## Evil team (8: 3 heads + 5 supports)

Killing rules (decided):
- A: not every head kills. Killers at the start: Cutthroat and Apothecary.
- B: team kill limit per night by lobby size (Config.EVIL_KILLS_PER_NIGHT: 12 = 1, 16 = 2, 20 = 2). After the last allowed kill, all evil kills lock until dawn.
- C: one killing support role, weaker than the heads; its kill unlocks only once an evil head is out.

| Role | Main ability | Level 2 | Level 3 | Status |
|---|---|---|---|---|
| **Cutthroat** (head) | Fast, silent knife kill on a cooldown; can travel through the sewers. Every kill leaves a How and a Who clue. | Shorter cooldown | Fewer traces | Draft |
| **Apothecary** (head) | Poisons an object (teapot, lantern oil); whoever uses it dies later, scrambling When clues and alibis. | Choose the delay | Poison 2 objects | Draft (delayed death still to confirm) |
| **Forger** (head, does NOT kill) | Plants a fake clue in the world. | Shorter cooldown | Forgeries age like real ones | Draft (counter: a flaw a good checking role can spot) |

Support ideas (5 needed, nothing decided): killing support (locked until a head is out), Cleaner (moves bodies / wipes traces; took over from the Undertaker), Saboteur (tampers with task spots to cause mistake traces), Pickpocket (steals a clue from a journal), lamp/fire sabotage. Watch out: too many evidence-messing roles make clues pointless.
