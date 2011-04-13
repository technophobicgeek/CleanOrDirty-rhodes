Finally, an app that does the dishes! A little householdy app that which lets you and your family/roommates keep track of whether your dishwasher is clean or dirty. Just create a virtual dishwasher for your home, and change its status between "Clean" and "Dirty" as needed. To share your beloved dishwasher, go to the Options screen and provide the unique code you see there to other members of your home, who can now happily use the dishwasher.

Ruby/Rhodes developers, I'd appreciate any feedback you've got.

For convenience, I've also uploaded a signed Android apk file in bin/target/, so you can try it out on a device/emulator.

My main questions here are:

- For the controllers, I feel I can achieve my intentions in more compact code. I've tried using code blocks in one place to combine a few methods. Are there other techniques applicable?

- My erb templates are also quite verbose and could probably be DRY-ed and simplified, perhaps using partials?

- Rhodes-specific question: Unfortunately, I did not follow a TDD way while building the client (yes, I'm ashamed), mainly because I haven't figured out how to write specs for an app which constantly syncs with a server. Do I actually have to have a server running? Is there a way/framework that I can use to mock server behavior so I can test exhaustively and fast?

- UI: can I make the screens more intuitive to use? Where could I have used Javascript (I'm still a complete newbie there) instead of plain ERB?


