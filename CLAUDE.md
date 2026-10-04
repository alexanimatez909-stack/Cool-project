# Project: Victorian mystery game (Roblox) — working title TBD

Full design doc: https://claude.ai/code/artifact/a9017426-87a6-45d5-be7d-77267b7fb338
Clean rules summary: design/rules.md (keep it in sync whenever a rule changes).
(Read-only reference for Alexander. This file is the summary Claude should work from.)

## How to work with Alexander
- Alexander is new to game development and coding. Explain what you're doing in plain language, one step at a time.
- Make small changes, then let him test in Studio before moving on. Never build several systems in one go.
- Say where each script goes (ServerScriptService, StarterPlayerScripts, ReplicatedStorage, etc.) and why.
- If something is a design decision rather than a technical one, ask him — don't decide for him.

## Current phase: greybox + core feel
Build with plain grey parts only. No textures or detailed art until the layout is proven in playtests.
Milestones, in order:
1. Greybox city: central Square + 6 districts + sewer lines (see below). Playable area ≈ 1,940 × 1,355 studs (v5 added a west extension), ≈ 120 sec to walk east–west at WalkSpeed 16. X coordinates now go negative on the west side (down to about −315); keep the same plan→Studio mapping. Proportions are realistic (street width vs building height like real Victorian streets); distances are compressed. Streets irregular and crooked with alleys that always run all the way through (no dead-end stubs, no hidden courtyards); one winding main road loops through all districts; tall landmarks (church spire, market roof, Courthouse dome) for orientation.
   Map edges are SOFT: streets visibly carry on into a low-detail backdrop city (BackdropData.lua: blocks, fake_streets, passenger viaduct, south-bank skyline across the river), blocked at the edge by props (`edge_blockers`: police cordons, locked gates, road-works hoardings). Behind the props, an invisible collidable safety wall runs along playable_boundary. Add fog so the backdrop fades out. The workhouse & brewery (west) and road works (east) are still solid.
2. Movement: first-person lock at night, sprint + stamina, crouch.
3. DOORS-style camera: head bob, tilt on turns/strafe, sprint FOV, crouch lowers camera, exhaustion shake, visible body, "reduce motion" setting.
4. Night cycle (redesigned, see "Night design" below): 3 church bells start 3 stages of different lengths (Dusk 60 s, Deep night 120 s, Last hour 60 s, all in Config). Light fog all night. At Deep night 2–3 random districts lose their lamps (never the Courthouse Square). Everyone has a lantern.
5. NEXT: the smallest playable loop: one kill (downs a player), one clue, the evidence board, anonymous vote. Then roles one at a time.

## Night design (agreed with Alexander; tune after playtests)
- Stages instead of equal bells: Dusk (bell 1: lamps on, light fog, spread out), Deep night (bell 2: some districts go dark, main hunting time), Last hour (bell 3: short tense push), then dawn.
- Darkness by district, not the whole city: 2–3 districts go dark each night, chosen at random so killers can't camp one spot. Courthouse Square is always lit. Lit = safe to search but full of witnesses; dark = killer opportunities, but clues there are valuable.
- Lanterns are a trade-off: on = you see clues nearby but everyone sees you from afar; off = hidden but can't search well. Walking a dark district with the lantern off is suspicious (a social clue).
- Spawning: each night everyone starts in the Courthouse Square and walks out at Dusk (players are gathered round a part named NightSpawn; the square's 3 exits make "who went which way" evidence). Dusk is already for gathering evidence while it's still easy.
- Navigation: a Victorian paper map (press M) showing landmarks only, no streets: players know the direction, not the route. No minimap, and never show other players.
- Fog: light at Dusk, medium in Deep night, medium in the Last hour then slowly lifting late in the stage toward dawn (Config.FOG). Heavier fog can later be per district (Docks).
- Built: ServerScriptService.NightCycle runs the clock. It publishes the time as workspace attributes (Night, Phase "Night"/"Day", Stage 0–3, StageName ("Gathering" before bell 1, "Dusk", "DeepNight", "LastHour", "Day"), StageEndsAt, DarkDistricts e.g. "Soho,Docks"). Fog, street lamps, lanterns and on-screen clocks should react to those attributes (GetAttributeChangedSignal) rather than keep their own timers. District names match Config.DISTRICT_HEIGHTS keys.
- Balance comes from playtesting with every lever in Config. Aim for the smallest playable loop early (night clock, dark districts, lantern, one kill, one clue, vote) rather than waiting for all systems; test with friends using simple placeholder rules.

## Matches and lobbies
- Closed lobbies (decided): once a match starts, only the players who were in it can join back (e.g. after a disconnect). Nobody else can join a running match.
- Planned structure (not built yet): a Lobby place where players gather, and a Match place (the city) that each group is sent into as a private reserved server; disconnected players are sent back into their match, anyone else goes to the lobby. Studio testing works in the single place until then.
- Still open: how long someone may be gone before they count as out; what happens to their character while away (vanish or stay, can it be killed); whether they come back where they left or in the Courthouse Square; they should keep their role, journal clues and accessories.

## Engineering rules
- Server is the authority for anything that matters (kills, clues, roles, votes, win checks). Clients request via RemoteEvents; the server validates everything.
- Put every tuning number in one config ModuleScript (bell length, day phase lengths, lobby splits, stamina, cooldowns, friendly fire on/off) so balance changes are one edit.
- Use ModuleScripts for shared logic; keep scripts small and named clearly.
- Voice/chat: night = proximity (Roblox default spatial voice + nearby-only text bubbles); day = everyone. Ghosts get their own channel. Plan for text-only players.

## The game in brief
Hidden-role mystery in a Victorian London–inspired city. Nights are a first-person hunt; days are a debate over an evidence board in the Courthouse (third-person). Everything below is DECIDED with Alexander unless marked OPEN. Numbers are starting points for playtests and live in Config. Clean player-facing summary: design/rules.md. Full role tables: design/roles.md.

### Players and teams
- Minimum lobby 12 players, or the match doesn't start (Config.MIN_PLAYERS). Roles are built for 20 first.
- Splits (Config.LOBBY_SPLITS): 12 = 5/5/2, 16 = 7/7/2, 20 = 10 good / 6 evil / 4 Informants. OPEN: re-check 12 and 16.
- At 20: Good = 3 heads + 7 supports, Evil = 3 heads + 3 supports, Informants = 1 head + 3 supports. Every lobby always has all 3 heads per team; smaller lobbies lose supports first.
- NO role ever appears twice in a game.
- Nobody knows anyone's team, not even evil players (no mark). Only the Informants know each other and have a private chat. No team chat for good/evil.
- Closed lobbies: only players from the match can rejoin it.
- Later: experimental modes (e.g. Among Us-style, ~3 evil who know each other).

### Winning
- Evil loses when its 3 heads + 1 support are out (4 of 6 at 20; Config.EVIL_SUPPORTS_OUT_TO_LOSE).
- Good loses when 8 of its 10 are out (Config.GOOD_OUT_TO_LOSE). (An "equal numbers" rule was tried and removed.)
- Informants win by publishing their report; they lose if all are out, or if good or evil wins first.
- On death/vote-out only the name is announced, never the role. A counter shows each side's remaining heads.

### One cycle (about 5½ min; a game is about 5–6 cycles ≈ 30 min)
- Night 4:00 (Config.NIGHT_STAGES): Dusk 1:00, Deep night 2:00, Last hour 1:00 (never more than 7 min). Measured: running crosses the v10 map in ~60 s, walking ~90 s.
- Dawn: a bell tolls once per death; missing players are named, never where/when/how. Bodies must be found.
- Day (third person): trial 0:30 (only if the Watchman arrested someone; Config.DAY_TRIAL_LENGTH), discussion 1:00 (DAY_DISCUSSION_LENGTH), anonymous vote 0:30 (DAY_VOTE_LENGTH).
- Alarm bell in the Courthouse Square: each player can ring it ONCE per match to end the night early. No "report body" button.

### Killing and saving
- Killers: Cutthroat and Apothecary (evil heads). The Forger (head) never kills. The Footpad (support) can only kill once BOTH killing heads are out.
- Team kill limit: the whole evil team gets at most Config.EVIL_KILLS_PER_NIGHT kills per night (12 = 1, 16 = 2, 20 = 2). After the last one, every evil kill locks until dawn.
- Contracts: each night every killer secretly gets one target guaranteed NOT evil (because evil can't recognise each other). They may kill someone else instead. OPEN: how a contract becomes a clue.
- Kills don't stack: unused kills are lost at dawn.
- Friendly fire on: evil can kill evil; killing a teammate = very long cooldown.
- Downed: an attacked player is DOWNED for 2 minutes (Config), then dies. The Physician can fully revive them. OPEN: what happens to a downed player at dawn.
- Good abilities are visible when used (e.g. someone reviving a player); being seen makes you a target. Players figure it out (revisit after playtests).
- Finding a body does NOT end the night; the finder gets task charge and the body is a big clue for the board.

### Abilities
- Every role has ONE main ability (cooldown; some use charges/battery). Only exception: the Inspector's level 3 adds a daytime examination.
- Doing tasks fills a charge bar that upgrades the ability: level 1 → 2 → 3 (Apex Legends Evo-style). The level is kept all match.
- Upgrades make abilities smarter, not just stronger (shorter cooldown, more info, fewer traces, a bit more range). Good roles upgrade too.

### Roles (20 players)
Good heads:
- Inspector — Lantern beam reveals hidden traces; analyses accessories up close (only the Inspector can). L2: exact age of a trace. L3: unlocks a once-per-game DAYTIME examination (question a player about where they were at a chosen bell; the game secretly says if it's true).
- Physician — Revive: fully revives a downed player, once per night. L2: revived player gives "last words" (a clue about the attacker). L3: senses roughly where downed players are (heartbeat).
- Watchman — Arrest → trial: locks a player in the cells for the rest of the night (safe from killers there); the day opens with a quick guilty/not guilty trial. Guilty = out. Not guilty = released and the Watchman gets a very long cooldown. Arresting an Informant counts as right. L2: whistle freezes the target a few seconds first. L3: shorter cooldown after a correct arrest.
Good supports (all 7 in every 20-player game):
- Registrar (like the Among Us Scientist) — Death register: shows who is alive, downed or dead right now; uses a battery that tasks recharge. L2: district. L3: when they went down.
- Constable — Escort: stays close to one player per night; if that player is attacked, the attack fails and the Constable sees the attacker's accessory. L2: lasts longer. L3: attacker's full description.
- Foreman (task info) — Sees which task spots were done tonight and roughly when (checks alibis). L2: district. L3: can give someone else a task.
- Clerk (records) — By DAY marks one clue on the board; that NIGHT does a short records task at the Courthouse; next day learns real or forged and CHOOSES to strike it off or keep it. Counters the Forger. L2: sees how many clues a player has contributed to the board. L3: sees how many clues a player picked up last night (holding more than picked up = stolen; counters the Footpad).
- Lamplighter — Relights dark lamps and fixes sabotages alone and faster (even the two-person fire). L2: sees roughly where a sabotage was set off. L3: protects one district from the gas main for the night.
- Handyman (good task role) — Does tasks twice as fast and can finish another player's task for them (they still get the charge). L2: carrying doesn't stop sprinting. L3: each task adds a little charge to everyone nearby.
- Civilian — No normal ability. At full charge (about every 2 nights) kneels at a DEAD player's body and gets ONE use of that player's ability (never the living, so it's never a lie detector).
Evil heads:
- Cutthroat — Knife: fast silent attack that downs the victim; can travel through the sewers. Every kill leaves a How and a Who clue. L2: shorter cooldown. L3: fewer traces.
- Apothecary — Poison: poisons an object (teapot, lantern oil); whoever uses it is downed a while later, wherever they are. Counts toward the kill limit when PLANTED. L2: chooses the delay. L3: the object leaves no trace.
- Forger (no kill) — Forge: plants a fake clue in the world (fake footprints, a thread from someone's scarf...). The only role that forges. L2: shorter cooldown. L3: forgeries fade over time like real clues. Counter: the Clerk.
Evil supports (3 per game: the Footpad ALWAYS, plus 2 drawn at random from Cleaner, Arsonist, Swindler):
- Footpad (killing support) — Mug: knocks a player out (~10 s) and steals one clue from their journal; leaves a clear clue (e.g. "they had a cane"). Once BOTH killing heads are out, the mug becomes a kill (and still steals a clue). L2 (draft): shorter cooldown. L3 (draft): chooses which clue to steal.
- Cleaner — Drag: moves a body; can dump it in the river at the Docks (its journal sinks and those clues are lost). L2: notified when someone is killed, with a general direction. L3: drag trails fade faster.
- Swindler (evil task role) — Reads one player's task list (knows where they'll go). L2: two lists. L3: swaps one task on a player's list to send them to a spot of the Swindler's choosing (a lure).
- Arsonist (working name) — Sabotage (Among Us-style): one shared cooldown, one active at a time; fixing gives task charge (anyone can fix). L1: must be at the sabotage point. L2: shorter cooldown. L3: from anywhere. Each sabotage has FIXED places like Among Us:
  - Gas main (Lights): the Arsonist picks a district; all its lamps go out. Fix: turn the valve at that district's gas main. Unfixed: dark until the next bell.
  - Fire (Reactor): a building in Soho only. Fix: TWO players pump water at two spots at once. Unfixed: that district's traces/clues burn away and it closes for the night. Fire never downs players.
  - Cut telegraph (Comms): task lists vanish and the alarm bell can't be rung. Fix: splice the wire at the telegraph office. Unfixed: fixed at the next bell.
  - Lock gates (Doors): one district's gates or sewer grates lock ~20 s. Can't be fixed.
Informants (4, one of each):
- Editor (head) — Lead story: marks one player; all Informants get dirt on them faster and the Editor briefly hears roughly where they are. L2: shorter cooldown. L3: two stories at once.
- Stringer — Tail: shadowing gives dirt faster, quieter footsteps. L2: from further away. L3: learns where the target goes next.
- Photographer — Snapshot: dirt from a distance, but the flash lights up the street. L2: shorter cooldown. L3: weaker flash.
- Eavesdropper — Hears voice/chat from further away, even through doors; standing near two players talking gives dirt on both. L2: longer range. L3: can toggle seeing nearby footsteps through walls for a short time.
- Report: ONE shared report needing specific dirt on 8 different players (at 20). Any Informant can publish it at a printing press (~20 s, everyone hears the press but not where). Dirt comes from copying board clues at night or shadowing players; Informants never take clues from the world. OPEN: report size for smaller lobbies.

## Evidence
- Victorian forensics (Sherlock Holmes, not CSI): observation and reasoning. One clue is never enough; players need about 3 pieces of evidence about a person before an informed guess. No single source (clue, record or ability) should be enough. Short sentences; the journal remembers everything.
- Every clue must point to something players can check: where/when (alibis), temporary marks on a person (sewer muck on boots, blood on a sleeve, items carried; inspectable by day), and visible identity traits.
- Accessories: every player gets 3 random Victorian items, one per category: headwear, neckwear (scarf/cravat/colour), carried/coat item (cane, pocket watch, gloves...). Each item is shared by 3–4 players. Players' own Roblox accessories are removed. Anyone can see what others wear; ONLY the Inspector can analyse marks on them (mud on a hem, torn scarf, coal dust, scorched gloves). OPEN: the actual accessory list.
- Any action can leave traces, not only evil ones; some traces clear a player. Head roles leave stronger, longer-lasting traces.
- One trace system: every trace has type, where, when, who made it (hidden), how long it lasts, and which question it answers (How/When/Where/Why/Who). New clue types are new list entries, not new code. Who clues list a few names including the culprit.
- Trace vs clue: a trace is the thing in the world; examining it gives a clue that gets vaguer the older the trace is (fresh footprint = direction, speed, a minute ago; last night's = "someone passed through").
- Roles as experts: everyone gets the basic reading; experts get more (Inspector: footprints/scenes; Physician: bodies; Watchman: routes).
- Finding clues at night: they glint in lantern light when close AND make a subtle sound. Hold E for a few seconds to investigate (only when nobody is right next to you); some clues use small mini-tasks (anything that fits the clue). Found clues go into the journal and onto the paper map.
- First traces to build: the kill scene (permanent), footprints (fade fast; crouching leaves almost none), blood trail (fades). Moving a body leaves a drag/blood trail.
- Board: clues held for 2 nights are pinned to the board automatically (you choose when to reveal, not whether). OPEN: how clues get onto the board otherwise.
- Journal (press J; readable while moving): a Clues section filled automatically (with night, stage, district) and a free Notes page; both last the whole match. On death the journal drops: anyone can read its NOTES for free, but its CLUES stay hidden until someone picks it up, which takes ALL of them. How many clues each player holds is shown by day, so picking one up is a risk. A body dumped in the river sinks its journal (clues lost). Note text must be filtered with TextService before others see it.
- Built: ServerScriptService.Journal (ModuleScript) keeps each player's clues and notes by UserId (survives rejoin). The clue system adds clues ONLY through Journal.addClue(player, text, district); Journal.clueCount(player) is for the daytime "clues held" display. JournalUI (StarterPlayerScripts) is the J notebook; opening it raises the closed book from below with its page edges pointing at the player, then both halves open out flat onto Clues/Notes (Config.JOURNAL_RISE_TIME/OPEN_TIME/THICKNESS, optional sounds); closing plays it backwards, faster. JournalServer adds test clues while Config.JOURNAL_TEST_CLUES is on.

## Tasks (nothing built yet)
- Tasks: charge your ability, can reveal clues (through mistakes), spread players across the map, and add to good-team progress. Everyone does tasks (good, evil, Informants).
- A short personal list each night, shown in the journal, worth about 1–1½ minutes of task time (2 long or 5 short), leaving about half the night for searching, abilities and hunting. Travel between tasks should be short but still move players around.
- Common tasks (anyone can get them) every night; each common task goes to a limited number of players per night (Config). Role tasks are rare (every 2 nights, or random with a base amount and a limit).
- Each task has fixed spots in the districts; a player's task spots are their own. Some tasks need teamwork.
- Graded on noise/disruption, reward, danger and time. Riskier = more reward. No "hold a button" tasks; each is a short activity, lots of variety. Multi-step tasks keep finished steps. Carrying anything stops you sprinting. Lamps in dark districts: only specific ones can be relit.
- No visual tasks that prove innocence; what seeing someone at a task means is up to players.
- Mistake traces (instead of automatic records): some tasks can leave a clue when the player slips up (spilled water → wet footprints). Anti-faking: (1) mistakes cost you (redo, less charge); (2) the trace cuts both ways (puts you at the spot and leaves world clues pointing to you); (3) mistake traces are vague about time like any trace; (4) you can only slip up on a task you were assigned. design/tasks.md lists the 11 drafted common tasks, their grades and mistake traces.
- OPEN: role tasks themselves; how good-team progress pays off; whether others can see someone's ability level.

## Map plan files (source of truth for the greybox)
- NOTE: Alexander redesigned the map to v10 in another session (playable area about 1,729 × 1,190 studs; Cathedral quarter moved onto the Embankment with its long side along the river; east side cut off; Market = one covered market hall + piazza; Courthouse next to Soho). The v10 files are not in this repo yet; the details below are still v6 until he uploads them.
- map-plan.png: to-scale plan for humans. map-plan.json: exact coordinates for building. map-plan-generator.py: the Python script that produced both (edit and rerun to change the layout).
- Coordinates: 1 unit = 1 stud. Plan X = Roblox X (east +). Plan Z = Roblox Z (south +). Y is up. Origin = plan's north-west corner; place it wherever suits in Studio, but keep the mapping consistent.
- Build ground as one large flat part under the whole playable_boundary, then:
  1. Barriers: viaduct (34 wide, 45 high along its centreline), workhouse compound walls, west wall, road_works (hoardings ~10 high), river embankment railing.
  2. Water: river outside the south boundary, dock_basin (not walkable), bridge (walkable).
  3. Landmarks from `landmarks` + `landmark_heights`; courthouse dome from `courthouse_dome`.
  4. Buildings from `buildings` (≈860, each one house/warehouse, 40–65 studs tall): use `box` (centre, size_x, size_z, rotation_deg around Y) ONLY when `use_box` is true (rectangularity ≥ 0.99), otherwise build from `triangles` (two WedgeParts per triangle). Use each building's `height`. Buildings in a row touch each other with no gap; the gaps are streets and alleys.
  5. Streets are the gaps between blocks. `streets` lists centrelines and widths for reference (main 40, side 26, alley 18, covered passage 14 — main road fits ~10 avatars side by side; no walkable gap anywhere is narrower than ~16 studs). Covered passages need a roof/building bridge over them.
  6. Points: `sewer_grates` and `sewer_tunnels` (each tunnel has a `route_centreline` that follows the streets; build it underground directly beneath that line, ~14 wide, ~14 high, floor ~18 studs below street level, with a ladder up to each grate), `printing_presses` (each has `pos` just inside a building and an `entrance` door point on the street), `churchyard_gates`.
- Verify after generating: main road floor measures ~40 studs wide and buildings use their `height`. Use `triangles` (not `box`) whenever `use_box` is false, otherwise buildings bulge into streets and alleys and create narrow squeezes.
- IMPORTANT: Roblox Studio cannot read files from the PC. The map data must live INSIDE Studio as a ModuleScript. Use `MapData.lua` from this folder: create/replace a ModuleScript named `MapData` in ReplicatedStorage and set its Source to the full contents of MapData.lua (it is a compact copy of map-plan.json, ~168k characters; if Studio refuses a Source that long, split the JSON string across two ModuleScripts and concatenate). The generator script must `require` that module. Whenever map-plan.json changes, MapData.lua changes too — replace the module's Source again, delete the old "Greybox" folder, and rerun the generator. When the module loads it prints `[MapData] loaded version ...` in Output; check the version matches the newest file (currently `2026-09-26-v6-backdrop-goods-station`, 857 buildings, 17 side streets, 48 alleys).
- BACKDROP: load BackdropData.lua as a second ModuleScript named `BackdropData` (it prints its own version). Build backdrop blocks as simple anchored boxes/wedges with no interiors, slightly darker/less detailed, into a Folder named "Backdrop"; fake streets as ground strips; a blocker prop at each `edge_blockers` point; the passenger viaduct as a brick arcade ~45 studs tall along its centreline; a few spires on the south bank. None of it is reachable.
- Prefer writing ONE Studio script that reads the JSON data and generates the greybox into a Folder named "Greybox", so the map can be regenerated after layout changes instead of hand-placing hundreds of parts.
- Density is deliberately different per district: Road hierarchy: the 40-stud main loop links districts; 17 side streets (26 studs, ids S1–S17 in `side_streets`) connect districts and landmarks; 48 alleys (18 studs, ids A1–A48 in `alleys`) are local lanes, mews, yards and shortcuts; the plan image labels them with the same ids so plan and Studio can be compared street by street: shortcuts through very long blocks, plus routes that lead somewhere (e.g. Lych-gate Passage from the churchyard to the river walk). Each is listed in `alleys` with its purpose. Blocks otherwise stay whole.
- Checks the plan already passes: one connected walkable area, Courthouse square has exactly 2 streets + 1 covered alley, no grate in the square, playable area ≈ 1,940 × 1,355 studs, sewer tunnels 100% under streets, no landmark overlapped by a street.

## Map
- Reference image: reference-map.png in this folder (approximate look and positions only; it is NOT to scale and has far fewer alleys than we want).
- Scale rules for the greybox (starting values, adjust after playtests):
  - Whole map ≈ 1,940 studs long (≈ 120 sec walking at 16).
  - Main winding road: 40 studs wide. Side streets: 26 studs. Alleys: 18 studs. Covered passages through buildings: 14 studs.
  - Buildings 40–65 studs tall so the street feels enclosed (height ≈ 1.5–2× street width, like real Victorian streets).
  - Maximum unbroken building row depends on the district (see map plan section); mazes only in Soho and the Tudor lanes.
  - Every district needs several ways in and out; avoid long dead ends near chokepoints.
- v5 west extension: the workhouse & brewery compound moved west (outside the playable area, a solid walled barrier with a 120-stud chimney); Soho expanded into its old space with Broad Street, Pump Square (Broad Street pump), a Music hall landmark and several lanes (Poland St, Marshall St, Rookery Lane along the workhouse wall, Carnaby Court). v6: the passenger railway viaduct is now BACKDROP scenery beyond the north edge (not a wall). A separate goods line comes straight in from the west into the Goods station (through shed, cargo only: 2 through tracks + 1 bay/terminus platform, ~70 studs tall) in the south-west, then runs at street level down Goods Yard Road and along the quay (`goods_railway`). The Docks extend west to the terminus with Goods Yard Road and Coal Wharf Lane, and the west wharf runs the full length of the river frontage.
- Outline: NOT a square. Irregular, roughly oval playable area: curving railway viaduct across the north, curving Thames along the south, brewery/workhouse compound on the west, road works on the east. Low-detail foggy rooftops continue outside it.
- Courthouse square: hidden, reached by only two narrow streets plus one covered alley — never a crossroads.
- Terraces: separate rows with gaps, mews lanes, stables and archways opening onto surrounding streets (not a closed block).
- Cathedral: large Gothic cathedral in a walled churchyard full of cover (tombs, mausoleum, yews, hedges, winding paths, lych-gate, crypt steps).
- Positions: Market (Covent Garden–style hall + piazza + portico church) north-west, next to Soho (west). Terraces north-east (enclosed garden square). Courthouse square hidden in the centre. Church quarter east/south-east (Gothic church, walled graveyard, Tudor houses). Docks south-west/south along the Thames.
- Districts: The Square (Courthouse + evidence board, brightest), The Docks (Thames, fog, body dumping, press), Church quarter (graveyard, crypt, bell tower, Tudor houses), The Terraces (Notting Hill–style stucco), Soho (Jekyll & Hyde slum, darkest, press), The Market (covered iron-and-glass market, press).
- Sewer lines (neighbouring districts only, ~470–480 studs each): River (Docks east wharf ↔ Embankment near the lych-gate, running east under the Embankment; its east end also branches to an arched outfall in the embankment wall with a tiny wooden landing stage at river level, reachable only through the sewer — see `river_outfall`), Old (Soho ↔ Market, under Frith Street and Church Lane), East (Terraces ↔ Cathedral quarter, under Mews Lane, Churchyard Row and Cathedral Lane). Each tunnel runs directly beneath the street above it; the two grates sit on that street at each end. Grates go on quiet side streets, never in the Courthouse square or the Market piazza.
- Sewers are a real underground area. Everyone can wade (slow, loud, leaves muck footprints); sewer roles get a fast-travel menu once hidden inside the grate. Anyone can peek up through grate bars (camera-only; grate stays shut).
- Avatars: everyone gets the same animations (Config.AVATAR_ANIMATIONS, Rthro walk/run for now) and the same body scale and standard body parts, forced by ServerScriptService.AvatarRules. Keeps the first-person camera identical for all players and stops small avatars hiding more easily. R15 only. First person shows only the legs by default (Config.FIRST_PERSON_BODY) so torso and arms never block the view.
- Movement: sprint (loud, clear footprints), walk, crouch (quiet, faint prints). Ground types change noise. Hiding spots have a time limit. Killers are no faster than anyone else.
- Built: StarterPlayerScripts.Footsteps plays everyone's footsteps on each client (3D, from their position), sound chosen by the floor's Material or a "FootstepSound" attribute on the part (Config.FOOTSTEP_SOUNDS); sprint is loudest and heard furthest, crouch barely. Roblox's default Running sound is muted.
- Smaller lobbies close off districts with gates.
