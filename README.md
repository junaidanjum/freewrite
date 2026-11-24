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

- **safer delete**: deleting an entry moves it to the Trash instead of erasing it. video entries go to the Trash as one folder (video, thumbnail and transcript together).
- **undo**: after a delete, "Moved to Trash · Undo" appears at the bottom of History for a few seconds. undo puts the entry back where it was.

## coming next

we're planning things like icloud sync, an iphone app and private on-device ai. see the full list and suggest your own in [what's next for freewrite](https://github.com/junaidanjum/freewrite/discussions/1).

## run it yourself

- clone repo.
- open in xcode.
- under Signing & Capabilities, pick your own team.
- click build.
- done -- you're up and running.
