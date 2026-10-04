# Game rules so far (clean summary)

Everything here is decided unless marked **OPEN**. Numbers are starting points for playtests and live in Config.
Detailed role tables: design/roles.md. Task list: design/tasks.md.

## 1. Players and teams
- Minimum 12 players, or the match doesn't start. Built for 20 first.
- Teams (good / evil / Informants): **12 = 6 / 4 / 2**, **16 = 8 / 5 / 3**, **20 = 10 / 6 / 4**. At 12 the only evil support is the Footpad.
- Smaller lobbies: the Clerk is always in; the Lamplighter only if the Arsonist is in; the Civilian only at 20; other good supports, evil supports (besides the Footpad) and Informants (besides the Editor) are drawn at random. All districts stay open.
- Good: 3 heads + 7 supports. Evil: 3 heads + 3 supports. Informants: 1 head + 3 supports.
- Nobody knows anyone's team, not even evil (no mark). Only the Informants know each other and have a private chat.
- Closed lobbies: only players from the match can rejoin it.
- **Disconnects:** your character stays asleep where you were and can be killed or arrested. Rejoin at night = wake up there; at day = the Courthouse. Leave at night and you have until the next Dusk to come back; leave during the day and you have until the Dusk after the following night. If you don't come back, you count as out (only your name is announced; your journal drops). While away you can't vote but can be voted for.
- Later: experimental modes (e.g. Among Us-style, ~3 evil who know each other).

## 2. How to win
- **Evil loses** when its 3 heads + 1 support are out (12: all 4, 16: 4 of 5, 20: 4 of 6).
- **Good loses** when about 80% are out (12: 5 of 6, 16: 6 of 8, 20: 8 of 10).
- **Informants win** by publishing their report; they lose if all 4 are out, or if good or evil wins first.
- Death/vote-out only announces the name, never the role. A counter shows how many heads each side has left.

## 3. One cycle (about 5½ minutes, a game is about 5-6 cycles / 30 min)
- **Night, 4 minutes, first person:** everyone starts in the Courthouse Square.
  - Dusk 1:15 (lamps on, light fog, spread out)
  - Deep night 2:00 (2-3 random districts go dark, never the Square; main hunting time)
  - Last hour 0:45 (tense final push, fog lifts toward dawn)
- **Dawn:** a bell tolls once per death; missing players are named, never where/when/how.
- **Day, third person:** (0:30 trial if someone was arrested), 1:00 discussion at the evidence board, then 0:30 anonymous vote.
- **Alarm bell:** each player can ring it ONCE per match. It jumps the night to its last 15 seconds (early inquest). No "report body" button: finding a body doesn't end the night.

## 4. Killing
- Killers: the **Cutthroat** and the **Apothecary** (heads). The **Forger** (head) does not kill.
- **Footpad** (evil killing support): mugs players (knocks them out ~10 s, steals one clue). Its mug only becomes a kill once BOTH killing heads (Cutthroat and Apothecary) are out.
- **Evil supports (3):** Footpad always; the other 2 drawn at random from Cleaner, Arsonist and Swindler (task role: reads task lists, level 3 swaps a task to lure someone).
- **Arsonist** (evil support, working name): Among Us-style sabotage menu (gas main, fire, cut telegraph, lock gates), one shared cooldown, one active at a time; fixing gives task charge; fire never downs players. Each sabotage has fixed places (fire only in Soho; gas main: the Arsonist picks the district). Level 1: must be at the sabotage point. Level 2: shorter cooldown. Level 3: sabotage from anywhere.
- **Cleaner** (evil support): drags bodies, can dump them in the river at the Docks. Level 2: notified of kills with a general direction. Level 3: drag trails fade faster.
- **Team kill limit:** at most 2 kills per night for the whole evil team (12 players: 1). After that, all evil kills lock until dawn.
- **Contracts (first night only):** every killer secretly gets one target guaranteed NOT evil. They may kill someone else instead. Killing your contract gives a reward but leaves an extra trace.
- Kills don't stack: unused kills are lost at dawn.
- **Friendly fire on:** evil can kill evil; killing a teammate gives a very long cooldown.
- **Downed:** an attacked player is downed for 2 minutes, then dies. The **Physician** can fully revive them. A player still downed at dawn dies.
- **Arrest -> trial:** the Watchman can arrest at night. The arrested player sits in the cells (safe from killers) until day, which opens with a quick trial (30 s): the town votes guilty (out) or not guilty (released; the Watchman gets a very long cooldown). Arresting an Informant counts as right.
- Finding a body at night doesn't stop the night; the finder gets task charge and the body is a big clue for the board.
- **Unfound bodies stay where they fell for the whole match** (only the Cleaner can move them). Once a body is **found**, it's removed (like reporting a body in Among Us), leaving a chalk outline. The dead player's journal stays on the ground there until someone picks it up. The clues a body gives fade over time: fresh = detailed, old = only the basics, but never nothing.

## 5. Abilities
- Every role has ONE main ability (cooldown, some use charges).
- Doing tasks fills a charge bar that upgrades the ability: level 1 -> 2 -> 3. The level is kept all match.
- Upgrades make it smarter, not just stronger (shorter cooldown, more info, fewer traces, a bit more range).

## 6. Tasks
- Everyone gets a short personal task list each night (in the journal): about 1-1½ minutes of task time.
- Common tasks (anyone can get them) every night; role tasks are rare.
- Each common task is handed to a limited number of players per night; your task spots are your own.
- Each task is graded on noise, reward, danger and time. No "hold a button" tasks. Multi-step tasks keep progress.
- Carrying something stops you sprinting.
- Tasks don't leave a record automatically. Some tasks can leave a **mistake trace** if you slip up (e.g. spilled water -> wet footprints). You can only slip up on a task you were assigned.
- Task roles: Handyman (good) and Swindler (evil); the Foreman (good) reads finished task spots.

## 7. Clues and evidence
- Sherlock Holmes, not CSI: one clue never convicts; you need about 3 pieces of evidence about a person.
- Any action can leave traces. Traces fade: old traces give vaguer clues. Head roles leave stronger traces.
- Clues glint in lantern light and make a small sound; hold E to investigate (only alone).
- Everyone wears 3 random Victorian accessories: **headwear, neckwear and footwear**, each shared by 3-4 players. Accessory clues are obvious: they show or name the item ("red scarf wool", "hobnail boot prints"). Only the Inspector can analyse marks on them. Full list: design/accessories.md.
- Only the Forger (evil head) can plant fake evidence.
- **Journal (J):** clues are added automatically, plus a free notes page. It drops when you die. Anyone can read its notes page for free; its clues stay hidden until someone picks it up, which means taking all of them. If the Cleaner dumps the body in the river, the journal sinks and its clues are lost. How many clues each player holds is shown during the day.
- **Board:** at day, in the voting room, your journal opens and you choose which clues to pin, **at most 2 per day**. No automatic pinning. Pins show your **name**. To give an **alibi**, show a clue from your own journal (never one off the board); it's shown to everyone and then used up (max 1 alibi per day; doesn't use a pin). Pinned clues leave the board after **2 days** and go back into the pinner's journal.

## 8. Movement and the night
- Walk, sprint (stamina, loud, clear footprints), crouch (quiet, faint prints). Killers are no faster.
- Lantern: on = see clues but be seen; off = hidden but can't search well.
- Paper map (M) shows landmarks only, never players.
- Night: proximity voice/chat. Day: everyone. Ghosts have their own channel.
- **Ghosts** never talk to the living. They do ghost tasks for their team and can haunt once per night (flicker a lamp, cold breath, a knock; never words). Evil ghosts can haunt to mislead.

## 9. Roles so far
- **Good heads:** Inspector (lantern beam; level 3 adds a once-per-game daytime examination), Physician (revive, once per night), Watchman (arrest -> trial). Good abilities are visible when used; being seen makes you a target. Supports (7): Registrar (death register, like the Among Us Scientist), Constable (one escort per night), Foreman, Clerk (marks a board clue by day, investigates it at night, next day learns real/forged and chooses to strike it or keep it; L2 clues contributed, L3 clues picked up last night), Lamplighter, Handyman (task role) and 1 Civilian (at full charge, about every 2 nights, copies a DEAD player's ability for one use). No role ever appears twice.
- **Evil heads:** Cutthroat (knife, downs the victim; second ability Shadow: camouflage in darkness, dash up to 25 studs between dark spots to down a passer-by, and sees outlines of players in the dark), Apothecary (poison downs the victim later; counts toward the kill limit when planted; second ability Smoke vial: a cloud that blocks sight and lanterns, to escape), Forger (plants fake clues; the Clerk can spot them). 3 supports: killing support + 2 **OPEN** (ideas: Cleaner, Saboteur, Pickpocket, Arsonist).
- **Informants:** Editor (head, Lead story), Stringer, Photographer, Eavesdropper. Shared report needs specific dirt on half of the living non-Informant players (min 3, recalculated each dawn; 8 at the start of a 20-player game); any Informant can publish it at a press (~20 s, loud).
