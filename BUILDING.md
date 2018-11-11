# How to Build the Textbook

Install needed dependencies:

* Install [Node.js](https://nodejs.org/en/).
* Install the [Gitbook CLI](https://www.npmjs.com/package/gitbook-cli).
  You most likely want to install globally with the `-g` flag, which might
  require prefixing the install command with `sudo`, as follows:
  `sudo npm install -g gitbook-cli`.
* From the root directory of the textbook (the same directory as this file),
  run `gitbook install` then `gitbook update`.

To edit the textbook:

* Find the section you want to edit in `SUMMARY.md`.  That will tell you
  which Markdown file to edit.

To build the textbook and push changes to the world:

* Run `make build` to build locally.
* Run `make serve`.  This runs a local dev server that hosts the edited textbook.  
  Check that everything looks right.
* Run `make deploy` to push it to the world.  Check the public website to make
  sure everything looks right.
