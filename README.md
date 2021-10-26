# Maker+ Plugin Suite
Hello! Welcome to the Maker+ Suite for the GrandMA2 software.
This plugin suite can be used to help keep organize where your song sequences are saved.
It is also used to create, rename, copy, delete, assign, and trigger plugins/macros.

Below is some information about how each plugin in this suite does. I encourage you to read through every plugin! There are tons of features that can hopefully speed up your process in creating songs.

## How To Setup for My Showfile
If you'd like to download this plugin suite for your showfile:
There is a green button on the top of this repository *'Clone or Download'*.
Click this button and then proceed to click the *'Download ZIP'*. Unzip file.
Transfer the unzipped folder to a USB stick. You can then transfer the USB to your GrandMA2 console.

Once you have the USB connected to your console, from your GrandMA2 software, create a new basic windows: `System` -> `Plugins`.
`Edit` an empty space for a new plugin. On the bottom of this popup GUI, click on the `import` button. Change your `Select Drive` to the USB drive with the Maker+ plugin suite. Go through each folder and find a XML files that you'd like to import.

> *LUA* files won't show on `import` GUI. *XML* files help import *LUA* files into the plugin pool.

Repeat process until you `import` all plugins you'd like in your showfile.

---
## User Manager Folder
This set of plugins can manipulate pool objects from the GrandMA2 software (i.e. Sequences, Macros, Effects, etc.).
This range of plugins can vary from adjusting individual songs (Its sequence and addons) or it can manipulate a entire array of songs.

### *BUILD Plugin*
- Creates a sequence and the requested addons for a new song
- Assigns song's first addon onto the selected executor
- Not able to name a song with punctuation
- Not able to name a song with specific version number
- Naming songs are not case-sensitive
- Desired group can store default values to first cue of song (Important for tracking!)


### *RENAME Plugin*
- Relabel a sequence and the addons associated to the sequence
- Can type the name/number of the sequence you'd like to rename
- Not able to name a song with punctuation
- Not able to name a song with specific version number
- Searching songs are not case-sensitive
- Naming songs are not case-sensitive


### *REPLICATE Plugin*
- Copies a song and creates another version
- Can type the name of the song they would like copy
- Can type the number of the song they would like copy
- Rename the sequence content and addons content
- Assigns song onto the selected executor


### *REVISE Plugin*
- Places a song onto the selected executor
- Can type the name of the song they would like edit
- Can type the number of the song they would like edit
- Searching songs are not case-sensitive


### *SQUASH Plugin*
- Deletes the sequence and addons from your song library
- Can type the name of the song they would like edit
- Can type the number of the song they would like edit
- Searching songs are not case-sensitive
- Gives you the option to condense MAKER+ libraries [NOTE: It condenses all of them]


### *FINDER Plugin*
- Search for a song
- Will blink the song sequence and all addons
- Will turn the sequence/addons white and then resets the color
- Searching songs is not case-sensitive
- Can use the first a '-' followed by the first character of an addon to shortcut into using that addon
  - i.e. ``'-m A SONG NAME'`` : Use MAKER addon after the search ends
  - Can use '-e ' before typing the song they wish to find ; Assigning song to selected executor


### *CONDENSE Plugin*
- Helps condense your library for sequence pool and/or addons
- Type number of last sequence/macro that is in your library to condense all in that range
- If you leave the text input blank: shortcut --> condenses until it reaches something that has more than 3 spaces


### *REALPHA Plugin*
- Reorganizes pool to alphabetical order within a continuous list

### *REPAIR Plugin*
- References sequence pool and creates new/updated addons associated in that sequences current order
- Recommended to delete addons before using this BUT not required in order to work

---
## Addons Folder
**Addons** are plugins that are to be used to perform a task. This typically is for an individual song. Using the `SETUP` settings, you can have a addon created everytime a new sequence is created.
### *MAKER Plugin*
- Places a song after the last cue
- Uses the **$MAKER** user variable
- Sets the **$MAKER** user variable as nothing at end of plugin
- Looks through the sequence library for song name
- Can ignore the label name and use the number of the sequence
- Searching songs are not case-sensitive


### *ALT_MAKER Plugin*
- Places an asset after the last cue
- Uses the **$MAKER** user variable
- Sets the **$MAKER** user variable as nothing at end of plugin
- Looks through the sequence library for song name


### *ADDER Plugin*
- Adds a song to the next cue
- Uses the **$MAKER** user variable
- Sets the **$MAKER** user variable as nothing at end of plugin
- Looks through the sequence library for song name
- Can ignore the label name and use the number of the sequence
- Searching songs are not case-sensitive


### *ALT_ADDER Plugin*
- Adds an asset to the next cue
- Uses the **$MAKER** user variable
- Sets the **$MAKER** user variable as nothing at end of plugin
- Looks through the sequence library for song name

---
## Companions Folder
These are plugins that don't rely on the Maker+ libraries (Sequences/Addons) but these plugins do rely on the `SETUP` plugin `API_MANAGE` plugin
### *ARCHIVE Plugin*
- Creates a new sequence for your service
- Asks what to label the sequence if **$MAKER** user variable is set to zero
- Labels sequence the upcoming weekday's date if **$MAKER** user variable is not set
  - The weekday's date: Is set from the `SETUP` plugin with the your user settings (i.e. `user.weekday = 'Sunday'`)
- Assigns the new sequence on to your selected executor

---
## Settings Folder
Make sure that this set of plugins are **BEFORE** all other plugins of the Maker+ suite in GrandMA2 plugin pool. The order of where this set of plugins matter!
### *SETUP Plugin*
- Manage multiple users of Maker+ and where data is stored
- All other Maker+ plugins reference the `SETUP` plugin for where to put their data
- If you make any changes with Maker+ plugins, press the `SETUP` plugin
- **TIP:** Maker+ Users settings could, if desired, point to the same place as another users settings

### *OBJ_MANAGE Plugin*
- Where addons are integrated into the Maker+ suite
- `maker.manager` directs external plugins *(User manager, addons, companions)* to do functions such as: `Create`, `Edit`, `Delete`, `Copy`, `Move`
- `maker.manager` also directs external plugins to increment numbers
  - Ignores the left most column of your sequence/macro pool (You choose column size!)
  - Uses only the second column of your Maker+ view (You choose column size!)
  - Every pool number is being used

### *CALLER Plugin*
- The interface from GMA2 software to Maker+ suite
- Need three variables filled out
	- `MAKER_USER` variable is for which Maker+ user you want to use
	- `MAKER_TASK` variable is to pick which Maker+ program you want to use
	- `MAKER_SONG` variable for what song you want to use (some times for more options)
- Import this plugin file after all other plugins (should be the last in the list of plugins)

### *API_MAKER Plugin*
```lua
maker.util.print(message, caller)
maker.util.error(message, extra, caller)
maker.util.prompt(pool, action)
maker.util.input(user, poolIndex, strTitle, caller)
maker.util.underVer(oldName, pool, verNum, caller)
maker.util.unpack(sName, caller)
maker.util.pack(arr, caller)
maker.util.round(num, numDecimalPlaces, caller)
maker.util.thru(numArray, caller)
maker.util.group(option, caller)
maker.util.date(offset, caller)
maker.util.weekday(reqDofW, caller)
maker.util.timeTravel(user, caller)
maker.util.renumber(caller)
maker.util.cueNumbers(caller)

maker.test.count(user, caller)
maker.test.pool(user, caller)
maker.test.seq(user, caller)
maker.test.archive(user, caller)

maker.find.pool(user, poolName, caller)
maker.find.operand(user, sName, caller)
maker.find.avail(user, poolIndex, caller)
maker.find.last(user, poolIndex, caller)
maker.find.gap(user, poolIndex, caller)
maker.find.count(user, poolIndex, sName, caller)
maker.find.strOrNum(user, sName, caller)

maker.find.ver.next(user, poolIndex, sName, caller)
maker.find.ver.count(user, poolIndex, sName, caller)
maker.find.ver.match(user, poolIndex, sName, caller)
maker.find.ver.pick(user, sName, caller)

maker.move.obj(user, poolIndex, caller)
maker.move.alpha(user, poolIndex, caller)

maker.request(user, poolIndex, seqArray, caller)

maker.repair(user, poolIndex, caller)
```

---
# FAQ

Questions | Answers
---|---|
Does Maker+ work on MA3? | Not at the moment.
I used on of the User Managers and I have no idea where it went  :( | Check the Command Line History. At the end of every plugin is a summary of what the plugin did.
I HAVE **IDEAS/BUGS**!!! | You can either create a `Issues` message on Github, email: csantillan@eastside.com, or DM on Instagram: **@mrcoopaloop**
Do you have tutorial videos? | [Here is the playlist :)](https://www.youtube.com/watch?v=eXnK9hRVN3k&list=PLRSV3X_VskNT6akKFeNY4hFJZFu40O7Xr)
