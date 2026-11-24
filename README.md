# hi, this is freewrite (fork)

a simple, open-source mac app to freewrite.

this is a fork of [farza's freewrite](https://github.com/farzaa/freewrite). all credit for the app goes to farza and the original contributors.

download the original app [here](https://www.freewrite.io/)

![img](https://i.imgur.com/2ucbtff.gif)

## where this fork starts

cloned from upstream at [`c21d71c`](https://github.com/farzaa/freewrite/commit/c21d71c) (2026-04-11, "Fix TextEditor cursor position and window dragging on macOS Tahoe, persist video volume").

everything after that commit is this fork's own work. to see it:

    git log c21d71c..HEAD
    git diff c21d71c..HEAD

## what's different

### writing

- **writing prompts**: an empty page shows a prompt, sentence starter or cue word. stare long enough (30s) and it fades to a new one. edit them in `freewrite/placeholders.txt`.
- **word count**: a quiet count in the bottom bar. hover it for characters.
- **zoom**: zoom in, zoom out and actual size from the view menu, `⌘+` / `⌘−` / `⌘0`, or the magnifier icons in the bottom bar. 50% to 300%, same steps as apple notes. only the writing area scales, and the column widens with it.

### fonts

- **font picker**: "More…" in the bottom bar (or `⌘T`) opens a searchable list of every installed font, each shown in its own typeface.
- **shuffle**: the shuffle icon next to the font name jumps to a random font.
- **keeps your place**: changing font, size or zoom keeps the same line at the top instead of jumping around.

### entries

- **safer delete**: deleting an entry moves it to the Trash instead of erasing it. video entries go to the Trash as one folder (video, thumbnail and transcript together).
- **undo**: after a delete, "Moved to Trash · Undo" appears at the bottom of History for a few seconds. undo puts the entry back where it was.

### window

- **window buttons on hover**: close, minimize and zoom stay hidden while you write and fade in when you move to the top-left corner.

## fixed from the original

these were reported on farza's repo. we track them in [issues from the original freewrite](https://github.com/junaidanjum/freewrite/discussions/2).

- [#28](https://github.com/farzaa/freewrite/issues/28) changing font or size jumped to the top of the entry.
- [#76](https://github.com/farzaa/freewrite/issues/76) switching dark and light mode jumped to the top of the entry.
- [#73](https://github.com/farzaa/freewrite/issues/73) the window buttons had disappeared.

## coming next

we're planning things like icloud sync, an iphone app and private on-device ai. see the full list and suggest your own in [what's next for freewrite](https://github.com/junaidanjum/freewrite/discussions/1).

## run it yourself

- clone repo.
- open in xcode.
- under Signing & Capabilities, pick your own team.
- click build.
- done -- you're up and running.
