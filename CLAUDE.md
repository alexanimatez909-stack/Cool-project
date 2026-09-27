# Project: Victorian mystery game (Roblox) — working title TBD

Full design doc: https://claude.ai/code/artifact/a9017426-87a6-45d5-be7d-77267b7fb338
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
4. Night cycle (redesigned, see "Night design" below): 3 church bells start 3 stages of different lengths (Dusk ~60 s, Deep night ~75 s, Last hour ~30 s, all in Config). Light fog all night. At Deep night 2–3 random districts lose their lamps (never the Courthouse Square). Everyone has a lantern.
5. Then: one kill, one clue, the evidence board, anonymous vote.

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
Hidden-role mystery in a Victorian London–inspired city. Nights are a first-person hunt; days are a debate over an evidence board in the Courthouse (third-person).
- Teams: Good and Evil roughly even; Informants (2–3) in lobbies of 12+. 8 players = 4/4/0, 12 = 5/5/2, 16 = 7/7/2, 20 = 9/8/3.
- Nobody knows their teammates. Evil players recognise each other only up close (subtle mark). No team chat for good/evil; Informants have private chat.
- Only evil head roles can kill. Friendly fire on (killing a teammate = very long cooldown).
- Win: a team is out when all its head roles are out. Informants win by publishing their report.
- On death/vote-out only the name is announced; roles stay hidden. A head-role counter shows both sides' remaining heads.
- Dawn: church bell tolls once per death; missing players named, never where/when/how. Bodies must be found.
- Roles are NOT finalised yet. Draft heads: Inspector, Physician, Watchman (good); Cutthroat, Apothecary, Shade (evil); Editor (Informants).

## Evidence (agreed with Alexander; replaces the older "only evil actions leave clues" draft)
- Victorian forensics (Sherlock Holmes, not CSI): observation and reasoning. One clue is never enough to convict; clues lead to other clues and only a combination narrows it down to one person. Must not be too hard: short sentences, the journal remembers everything.
- Every clue must point to something players can check: where/when (compare with alibis), temporary marks on a person (sewer muck on boots, blood on a sleeve, items carried; inspectable during the day), and visible identity traits.
- Visible identity traits: at game start every player is given one or two random visible accessories (e.g. red scarf, top hat, walking cane) so witness and physical clues ("red wool thread") can be matched to people. Players' own accessories are removed (decided): everyone wears only the game's Victorian items, so clues stay reliable.
- Any action can leave traces, not only evil ones; some traces help clear a player (alibis). Kills are permanent unless an evil role (e.g. a Cleaner) moves the body; moving it leaves its own traces (a blood trail that fades faster).
- One trace system: every trace has type, where, when, who made it (hidden), how long it lasts, and which question it answers (How/When/Where/Why/Who). New clue types are new entries in a list, not new code.
- Trace vs clue: a trace is the thing in the world; examining it gives a clue, which gets vaguer the older the trace is (fresh footprint = direction, speed, a minute ago; last night's = "someone passed through"). This is how clues carry over between nights but lose accuracy.
- Roles as experts: everyone gets the basic reading of a trace; experts get more (Inspector: footprints and scenes; Physician: bodies, time and cause of death; Watchman: routes and streets).
- Finding clues at night: they glint in lantern light when you're close AND make a subtle sound nearby. Investigating: hold E for a few seconds (only when nobody is right next to you), and some clues use small mini-tasks (e.g. matching a footprint). Found clues go into a journal and get marked on the paper map.
- First traces to build: the kill scene (permanent), footprints (fade fast; crouching leaves almost none), blood trail (fades).
- Journal (press J; can be read while moving): a "Clues" section filled automatically when you investigate (with night, stage and district), and a free "Notes" page. Notes carry over between nights for the whole match. On death the journal drops; anyone can read it, and picking it up forces you to take ALL the clues inside. How many clues each player holds is visible during the day, so picking up a dead player's journal is a risk. Because other players can read notes, note text must be filtered with TextService before anyone else sees it.
- Built: ServerScriptService.Journal (ModuleScript) keeps each player's clues and notes by UserId (survives rejoin). The clue system adds clues ONLY through Journal.addClue(player, text, district); Journal.clueCount(player) is for the daytime "clues held" display. JournalUI (StarterPlayerScripts) is the J notebook; opening it raises the closed book from below and opens it in the middle straight onto Clues/Notes (the front half swings over, its page edges visible side-on; art/journal-cover.png, Config.JOURNAL_RISE_TIME/COVER_TIME/THICKNESS, optional sounds); closing plays it backwards, faster. JournalServer adds test clues while Config.JOURNAL_TEST_CLUES is on.
- Still open: does the original kill spot always keep something permanent even if the body is moved; which mini-tasks; the accessory list; how clues get onto the evidence board; forgeries.
- Older draft points still worth keeping: Who clues list a few names including the culprit; clues drop on death; searching only works alone.

## Map plan files (source of truth for the greybox)
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
