# Art

- `stamina-frame.svg`: source for the stamina bar frame (edit this, then re-render).
- `stamina-frame.png`: 2048x336 transparent PNG to upload to Roblox. The see-through channel the fill slides in is at
  x 304–1744, y 186–230 (pixels), i.e. scale x 0.1484 + width 0.7031, y 0.5536 + height 0.1310.
- `PinyonScript-Regular.ttf`: the script font used for "Stamina" (SIL Open Font License).
- Render: open `render.html` in headless Chromium with a transparent background at 2048 wide and crop to 2048x336.
- `journal-book.svg`: source for the open journal book (1500x1000 units). Rendered to 2048x1366 and split into
  `journal-left.png` and `journal-right.png` (1024x1366 each, Roblox's maximum width). Text areas as a share of the
  whole book: left x 0.100 y 0.225 w 0.353 h 0.615; right x 0.548, same size. Render with `render-book.html`.
- `make_journal_icon.py`: builds `journal-icon.png` (512x512, the journal button). The book is a real 3D box
  (LIFT = degrees up, TURN = degrees turned towards you) projected with perspective; the flat cover
  (`journal-icon-cover.svg`) is warped onto it, and the brass frame follows the book's outline
  (`journal-icon.svg` = frame + page edges): its 4 sides sit the same distance (GAP_*) from the book's outline.
  The fancy J in the bottom-right corner is drawn as brush strokes (J_PATHS). Run `python3 make_journal_icon.py`.
