# Installing OCaml

If all you need is a way to follow along with the code examples in this book,
you don't actually have to install OCaml! The code on each page is executable in
your browser, as described earlier in this [Preface](about).

If you want to take it a step further but aren't ready to spend time installing
OCaml yourself, we provide a [virtual machine](../appendix/vm) with OCaml
pre-installed inside a Linux OS.

But if you want to do OCaml development on your own, you'll need to install it
on your machine. There's no universally "right" way to do that. The instructions
below are for Cornell's CS 3110 course, which has goals and needs beyond just
OCaml. Nonetheless, you might find them to be useful even if you're not a
student in the course.

Here's what we're going to install:

- A Unix development environment
- OPAM, the OCaml Package Manager
- An OPAM *switch* with the OCaml compiler and some packages
- The Visual Studio Code editor, with OCaml support

The installation process will rely heavily on the *terminal*, or text interface
to your computer.  If you're not too familiar with it, you might want to
brush up with a [terminal tutorial][terminal-tutorial].

[terminal-tutorial]: https://ubuntu.com/tutorials/command-line-for-beginners

```{tip}
If this is your first time installing development software, it's worth pointing
out that "close doesn't count": trying to proceed past an error usually just
leads to worse errors, and sadness. That's because we're installing a kind of
tower of software, with each level of the tower building on the previous. If
you're not building on a solid foundation, the whole thing might collapse. The
good news is that if you do get an error, you're probably not alone. A quick
google search will often turn up solutions that others have discovered. Of
course, do think critically about suggestions made by random strangers on the
internet.
```

Let's get started!

## Unix Development Environment

**First, upgrade your OS.** If you've been intending to make any major OS
upgrades, do them now. Otherwise when you do get around to upgrading, you might
have to repeat some or all of this installation process. Better to get it out of
the way beforehand.

**Linux.** If you're already running Linux, you're done with this step. Proceed
to OPAM, below.

**Mac.** Beneath the surface, macOS is already a Unix-based OS. But you're going
to need some developer tools and a Unix package manager. There are two to pick
from: [Homebrew][homebrew] and [MacPorts][macports]. From the perspective of
this textbook and CS 3110, it doesn't matter which you choose. So if you're
already accustomed to one, feel free to keep using it. Make sure to run its
update command before continuing with these instructions.

Otherwise, pick one and follow the installation instructions on its website. The
installation process for Homebrew is typically easier and faster, which might
nudge you in that direction. If you do choose MacPorts, make sure to follow
*all* the detailed instructions on its page, including XCode and an X11 server.
**Do not install both Homebrew and MacPorts**; they aren't meant to co-exist. If
you change your mind later, make sure to uninstall one before installing the
other. After you've finished installing either Homebrew or MacPorts, you can
proceed to OPAM, below.

[homebrew]: https://brew.sh/
[macports]: https://www.macports.org/install.php

**Windows.** Unix development in Windows 10 is made possible by the Windows
Subsystem for Linux (WSL). Follow [Microsoft's install instructions for
WSL][wsl]. Here are a few notes on Microsoft's instructions:

- From the perspective of this textbook and CS 3110, it doesn't matter whether
  you join Windows Insider.

- WSL2 is preferred over WSL1 by OCaml (and WSL2 offers performance and
  functionality improvements), so install WSL2 if you can.

- To open Windows PowerShell as Administrator, click Start, type PowerShell,
  and it should come up as the best match.  Click "Run as Administrator",
  and click Yes to allow changes.

- To use WSL2 (rather than WSL1) you might need to enable virtualization in your
  machine's BIOS; some laptop manufacturers disable it before shipping machines
  from the factory. The instructions for that are dependent on the manufacturer
  of your machine. Try googling "enable virtualization <manufacturer> <model>",
  substituting for the manufacturer and model of your machine. This
  [Red Hat Linux][rh-virt] page might also help.

- These instructions assume that you install Ubuntu (20.04) as the Linux
  distribution from the Microsoft Store. In principle other distributions should
  work, but might require different commands from this point forward.

- You will be prompted to create a Unix username and password. You can use any
  username and password you wish. It has no bearing on your Windows username and
  password (though you are free to re-use those). Do not put a space in your
  username. Do not forget your password. You will need it in the future.

- To enable copy-and-paste, click on the icon on the top left of the shell
  window, click Properties, and make sure “Use Ctrl+Shift+C/V as Copy/Paste” is
  checked. Now Ctrl+Shift+C will copy and Ctrl+Shift+V will paste into the
  terminal. Note that you have to include Shift as part of that keystroke.

[wsl]: https://docs.microsoft.com/en-us/windows/wsl/install-win10
[rh-virt]: https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/virtualization_administration_guide/sect-virtualization-troubleshooting-enabling_intel_vt_and_amd_v_virtualization_hardware_extensions_in_bios

When you've finished installing WSL, open the Ubuntu app.  You will be at
the *Bash prompt*, which looks something like this:

```console
user@machine:$
```

Run the following command to update the *APT package manager*, which is what
helps to install Unix packages:

```console
sudo apt update
```

You will be prompted for the Unix password you chose. The prefix `sudo` means to
run the command as the administrator, aka "super user". In other words, do this
command as super user, hence, "sudo".

```{warning}
Running commands with `sudo` is potentially dangerous and should not be done
lightly. Do not get into the habit of putting `sudo` in front of commands, and
do not randomly try it without reason.
```

Now run this command to upgrade all the APT software packages:

```console
sudo apt upgrade -y
```

WSL has its own filesystem that is distinct from the Windows filesystem, though
there are ways to access each from the other. This is a potentially tricky
concept to master.

- When you launch Ubuntu and get the $ prompt, you are in the WSL filesystem.
  Your home directory there is named `~`, which is a built-in alias for
  `/home/your_user_name`.

- When you use Windows, you are in the Windows filesystem. [Microsoft issued one
  hard-and-fast rule][wsl1-fs]: "Do not under any circumstances access
  [WSL filesystem] files using Windows." You can corrupt the files.

[wsl1-fs]: https://devblogs.microsoft.com/commandline/do-not-change-linux-files-using-windows-apps-and-tools/

We recommend storing your OCaml development work in the WSL filesystem, not the
Windows filesystem.

## Install OPAM

**Linux.** Follow the [instructions for your distribution][opam-install].

**Mac.** If you're using Homebrew, run these commands:

```console
brew install gpatch
brew install opam
```

If you're using MacPorts, run this command:

```console
sudo port install opam
```

[opam-install]: https://opam.ocaml.org/doc/Install.html

**Windows.** Run this command from Ubuntu:

```console
sudo apt install -y m4 zip unzip bubblewrap build-essential opam
```

## Initialize OPAM

**Linux, Mac, and WSL2.**  Run:

```console
opam init --bare -a -y
```

**WSL1.**  Run:

```console
opam init --bare -a -y --disable-sandboxing
```

It is necessary to disable sandboxing because of an [issue involving OPAM and
WSL1][bwrap].

[bwrap]: https://github.com/ocaml/opam-repository/issues/12050

## Create an OPAM Switch

A *switch* is a named installation of OCaml with a particular compiler version
and set of packages. You can have many switches and, well, switch between them
&mdash;whence the name. Create a switch for this semester's CS 3110 by running
this command:

```console
opam switch create cs3110-2021fa ocaml-base-compiler.4.12.0
```

```{tip}
If that command fails saying that the 4.12.0 compiler can't be found, you
probably installed OPAM sometime back in the past and now need to update it. Do
so with `opam update`.
```

You might be prompted to run the next command.  If so, do it. If not, don't.

```console
eval $(opam env)
```

Regardless, continue:

```console
opam install -y utop ounit2 qcheck bisect_ppx menhir \
  ocaml-lsp-server ocamlformat
```

You should now be able to launch utop, the OCaml Universal Toplevel.

```console
utop
```

Enter 3110 followed by two semi-colons. Press return. The # is the utop prompt.

```ocaml
# 3110;;
- : int = 3110
```

Stop to appreciate how lovely `3110` is. Then quit utop. Note that you must
enter the extra # before the quit directive.

```ocaml
# #quit;;
```

## Double Check OCaml

Let's pause to double check whether your installation has been successful. It's
worth the effort!

First, **reboot your computer**. (Really! No matter how silly it might seem, we
want a clean slate for this test.) Second, run utop, and make sure it still
works. If it does not, here are some common issues:

- **Are you in the right Unix prompt?** On Mac, make sure you are in whatever
  Unix shell is the default for your Terminal: don't run bash or zsh or anything
  else manually to change the shell. On Windows, make sure you are in the Ubuntu
  app, not PowerShell or Cmd.

- **Is the OPAM environment set?** Run `eval $(opam env)` then try running utop
  again. If that works, the problem is that your login shell is somehow not
  running the right commands to activate the OPAM environment when you login to
  your Unix prompt. The `opam init` command is what puts those commands in the
  right place. Follow the "redo" instructions below.

- **Is your switch listed?** Run `opam switch list` and make sure a switch named
  `cs3110-2021fa` is listed, that it has the 4.12.0 compiler, and that it is the
  active switch (which is indicated with an arrow beside it). If that switch is
  present but not active, run `opam switch cs3110-2021fa` then see whether utop
  works. If that switch is not present, follow the "redo" instructions below.

**Redo Instructions:** Remove the OPAM directory by running `rm -r ~/.opam`,
then re-run the OPAM initialization command for your OS (given above), then
re-run the switch creation and package installation commands above. Finally,
redo the double check: reboot and see whether utop still works. You want to get
to the point where utop "just works" after a reboot.

## Visual Studio Code

Visual Studio Code is a great choice as a code editor for OCaml. (Though if you
are already a power user of Emacs or Vim those are great, too.)

- Download and install [Visual Studio Code][vscode] (henceforth, VS Code).
  Launch VS Code. Find the extensions pane, either by going to View ->
  Extensions, or by clicking on the icon for it in the column of icons on the
  left.

- **Windows only:** Install the "Remote - WSL" extension. Second, open a WSL
  window by using the command "Remote-WSL: New Window" or by running `code .` in
  Ubuntu. Either way, make sure you see the green "WSL" indicator in the
  bottom-left of the VS Code window. Follow the rest of the instructions in that
  window.

- **Mac only:** Open the Command Palette and type "shell command" to find the
  "Shell Command: Install 'code' command in PATH" command. Run it. Then close
  any open terminals to let the new path settings take effect.

- In the extensions pane, search for and install the "OCaml Platform" extension.
  Be careful to use the extension with exactly the right name. The extensions
  named simply "OCaml" or "OCaml and Reason IDE" are not the right ones. (They
  are both old and no longer maintained by their developers.) **Windows only:**
  make sure you install the extension with the button that says "Install on WSL:
  ...", not with a button that says only "Install". The latter will not
  work.

[vscode]: https://code.visualstudio.com/

## Double Check VS Code

Let's make sure VS Code's OCaml support is working.

- Reboot your computer again. (Yeah, that really shouldn't be necessary. But it
  will detect so many potential mistakes now that it's worth the effort.)

- Open a fresh new Unix shell. **Windows**: remember that's the Ubuntu, not
  PowerShell or Cmd. **Mac**: remember that you shouldn't be manually switching
  to a different shell.

- Navigate to a directory of your choice, preferably a subdirectory of your home
  directory. For example, you might create a directory for your 3110 work inside
  your home directory:
  ```console
  mkdir ~/3110
  cd ~/3110
  ```
  In that directory open VS Code by running:
  ```console
  code .
  ```
  Go to File -> New File. Save the file with the name `test.ml`. VS Code should
  give it an orange camel icon.

- Type the following OCaml code then press Return:
  ```ocaml
  let x : int = 3110
  ```
  As you type, VS Code should colorize the syntax, suggest some completions, and
  add a little annotation above the line of code. Try changing the `int` you
  typed to `string`. A squiggle should appear under `3110`. Hover over it to see
  the error message. Go to View -> Problems to see it there, too. Add double
  quotes around the integer to make it a string, and the problem will go away.

**If you don't observe those behaviors,** something is wrong with your install.
Here's how to proceed:

- Do not hardcode any paths in the VS Code settings file, despite any advice you
  might find online.  That is a band-aid, not a cure of whatever the underlying
  problem really is.

- Make sure that, from the same Unix prompt as which you launched VS Code, you
  can successfully complete the double-check instructions for your OPAM switch:
  can you run utop? is the right switch active? If not, that's the problem you
  need to solve first. Then return to the VS Code issue. It might be fixed now.

- If you're on WSL and VS Code does add syntax highlighting but does not add
  squiggles as described above, and/or you get an error about "Sandbox
  initialization failed", then double-check that you see a green "WSL" indicator
  in the bottom left of the VS Code window. If you do not, make sure you
  installed the "Remote - WSL" extension as described above, and that you are
  launching VS Code from Ubuntu rather than PowerShell or from the Windows GUI.

**If you're still stuck with an issue,** try uninstalling VS Code, rebooting,
and re-doing all the install instructions above from scratch. Pay close
attention to any warnings or errors.

## VS Code Settings

We recommend tweaking a few editor settings. Open the user settings JSON file by
(i) going to View → Command Palette, (ii) typing “settings json”, and (iii)
selecting Open Settings (JSON). Copy and paste these settings into the window:

```json
{
    "editor.tabSize": 2,
    "editor.rulers": [
        80
    ],
    "editor.formatOnSave": true,
}
```

Save the file and close the tab.

## Using VS Code Collaboratively

VS Code's [Live Share][liveshare] extension makes it easy and fun to collaborate
on code with other humans.  You can edit code together like collaborating inside
a Google Doc.  It even supports a shared voice channel, so there's no need to
spin up a separate Zoom call.  To install Live Share:

- Open the Extensions page in VS Code.  Search for "Live Share Extension Pack".
  Install it.

- The first time you use Live Share, you will be prompted to login. If you are a
  Cornell student, choose to login with your Microsoft account, not Github.
  Enter your Cornell NetID email, e.g., your_netid@cornell.edu. That will take
  you to Cornell's login site. Use the password associated with your NetID.

To collaborate with Live Share:

- The *host* starts the Live Share session.  That generates a URL.  Send the
  URL to the *guests* however you like (DM, email, etc.).

- The guest puts that URL into a browser or directly into VS Code, and connects
  to the shared programming session.

[liveshare]: https://code.visualstudio.com/learn/collaboration/live-share
