# Virtual Machine

A *virtual machine* is what the name suggests: a machine running virtually
inside another machine. With virtual machines, there are two operating systems
involved: the *host* operating system (OS) and the *guest* OS. The host is your
own native OS (maybe Windows). The guest is the OS that runs inside the host.

The virtual machines (VM) we provide here have OCaml pre-installed in an Ubuntu
guest OS. Ubuntu is a free Linux OS, and is an ancient African word meaning
"[humanity to others][ubuntu]". The process we use to create the VM is
[documented here][vmrepo].

[ubuntu]: https://ubuntu.com/about
[vmrepo]: https://github.com/cs3110/vm

## Starting the Installation on Windows

- Download and install [VMware Workstation Pro][vmware]. It is currently free for personal use, though you will have to create an account with Broadcom.

- Download our [AMD64-based VM][3110vms]. Save the ".ova" file wherever you like.

- Launch VMware Workstation, select File → Open, and select the ".ova" file you just downloaded into the window. Click Open. Choose your own name for the VM (perhaps "CS 3110") and click Import. Click "Power on this virtual machine". It can take about 2 minutes for all the jobs to launch and the GUI to appear.

- Skip down to "Finishing the Installation" below.

## Starting the Installation on Mac

- Download and install [VMware Fusion Pro][vmware]. It is currently free for personal use, though you will have to create an account with Broadcom.

- If you have an Apple Silicon (M1, M2, or M3) Mac, download our [ARM-based VM][3110vms]. If you have an Intel Mac, download our [AMD64-based VM][3110vms]. Save the ".ova" file wherever you like.

- Launch VMware Fusion, select File → New, and drag the ".ova" file you just downloaded into the window. Click Continue. Choose your own name for the VM (perhaps "CS 3110") and click Save. When the import is done, click Customize Settings → System Settings → OS → Linux → Ubuntu 64-bit ARM. Close the settings. Click the play icon in the middle of the black window. It can take about 2 minutes for all the jobs to launch and the GUI to appear.

- Continue with "Finishing the Installation" below.

## Finishing the Installation

The VM will log you in automatically. The username is `camel` and the password is `camel`. There are icons provided for the Terminal, VS Code, and the Firefox web browser. They are in the left-hand launcher bar.

- Open Terminal and update Ubuntu and OPAM:

  ```console
  $ sudo apt update
  $ sudo apt upgrade
  $ sudo opam update
  $ sudo opam upgrade
  ```

- If you are a student in CS 3110, create an OPAM switch for the current semester as described in the [install instructions](../preface/install.md). Otherwise there is already a default OPAM switch you can use.

- Launch VS Code and update it to the most recent version. OCaml Platform is already installed for you.

Optionally, if you want to change your password, run `passwd` from the terminal and follow the prompts. And if you’d rather have your own username, you are welcome to go to Settings → Users to create a new account. Just be aware that OPAM and VS Code won’t be installed for that user. You'll need to follow the [install instructions](../preface/install.md) to add them.

[vmware]: https://www.vmware.com/products/desktop-hypervisor/workstation-and-fusion
[3110vms]: https://cornell.box.com/v/cs3110-virtual-machines
