# Pet Salon

## Synopsis

Hello!
This project fell through due to scheduling conflicts. I didn't want the work I put into tech go to waste, so I've made the code available to the community.
The code describes a 'Pet Salon Tycoon' game; users own a plot, wash pets that slide along a conveyor, buy machines to automate the process, and accrue value as the quality of cleaning improves. At the end of the line, pets mysteriously vanish into the ether - but thankfully, that generates you cash!

I hope this will serve as a useful reference! Please [reach out](https://twitter.com/messages/compose?recipient_id=1269492331163660289) if you have any questions.

## Media

![Cats on a conveyor belt. As each cat passes through the washing gate, its value doubles.](/.github/media/cat_army.gif)
![Cats on a conveyor belt. One cat is coloured gold, as it is a higher tier than the rest of the pets.](/.github/media/pet_tiers.png)

## Featureset

This project is built with Quenty's [Nevermore](https://github.com/Quenty/NevermoreEngine/); it's a very powerful ecosystem, but unfortunately with few holistic examples available online. Let this serve as inspiration to try it out!

No assets or place files are included. You'll have to piece the project structure together yourself by looking through the code - sorry! I hope that it can still serve as a useful reference.

- Complete tycoon system.
  - Currencies save/load.
  - Built objects (called `Buildables` internally) save/load.
  - Built objects have a cute load-in animation on the client.
  - State can be reset and reloaded dynamically, thanks to reactive programming patterns. See the 'settings' menu in-game!
- Client-side animation of pets and models.
  - Good network replication hygiene; for pets, only 'creation', 'deletion', and 'value changed' packets are sent. All animation happens predictively on the client, according to the synchronised server/client clock.
  - Animal heads rotate to look at the local player when they're standing within a reasonable range and angle.
- UI
  - Numerous elements with shared components;
    - Sidebar menu.
    - Currency pane menu.
    - Settings 'slider' menu.
  - Elements have cute springy animations!
  - Demonstrates resizing of parent containers to fit content, allowing for flexible designs - i.e., settings menu expands to fit any number of sliders.
  - Full Horacekat support to demo each pane, with [Evenmore](https://github.com/OttoHatt/evenmore) widgets included for testing - see '.story.lua' files!

## License

This project is released under GPL V3. If you'd like to acquire this code free of GPL's infectious restrictions, please contact me.