# Virtual Machine

A *virtual machine* is what the name suggests: a machine running virtually
inside another machine. With virtual machines, there are two operating systems
involved: the *host* operating system (OS) and the *guest* OS. The host is your
own native OS (maybe Windows). The guest is the OS that runs inside the host.

The virtual machine (VM) we provide here has OCaml pre-installed in an Ubuntu
guest OS. Ubuntu is a free Linux OS, and is an ancient African word meaning
"[humanity to others][ubuntu]". The process we use to create the VM is
[documented here][vmrepo].

[ubuntu]: https://ubuntu.com/about
[vmrepo]: https://github.com/cs3110/vm

## Installing the VM

- Download and install Oracle's free [VirtualBox][virtualbox] for your host OS.
  Or, if you already had it installed, make sure you update to the latest
  version of VirtualBox before proceeding.

- Download [our VM][3110vm]. Don’t worry about the “We’re sorry, the preview
  didn’t load” message you see. Just click the Download button and save the
  `.ova` file wherever you like. It’s about a 6GB file, so the download might
  take awhile.

- Launch VirtualBox, select File → Import Appliance, and choose the `.ova` file
  you just downloaded. Click Next, then Import.

[virtualbox]: https://www.virtualbox.org/wiki/Downloads
[3110vm]: https://cornell.box.com/v/cs3110-2022fa-ubuntu


## Starting the VM

- Select cs3110-2022fa-ubuntu from the list of machines in VirtualBox. Click
  Start. At this point various errors can occur that depend on your hardware,
  hence are hard to predict.

  - If you get an error about “VT-x/AMD-V hardware acceleration”, you most
    likely need to access your computer’s BIOS settings and enable
    virtualization. The details of that will vary depending on the model and
    manufacturer of your computer. Try googling "enable virtualization
    [manufacturer] [model]", substituting for the manufacturer and model of your
    machine. This [Red Hat Linux][rh-virt] page might also help.

  - If the machine just freezes or blacks out or aborts, you might need to
    adjust the memory provided to it by your host OS. Select the VM in Virtual
    Box, click Settings, and look at the System and Display settings. You might
    need to adjust the Base Memory (under System → Motherboard) or the Video
    Memory (under Display → Screen). Those sliders have color coding underneath
    them to indicate what good amounts might be on your computer. Make sure
    nothing is in the red zone, and try some lower or higher settings to see if
    they help. If the sliders are greyed out and won't permit adjustment, it
    means the VM is still running: you can't change the amount of memory while
    the guest OS is active; so, shut down the VM (see below) and try again.

  - If you have a monitor with high pixel density (e.g., an Apple Retina
    display), the VM window might be incredibly tiny. In VirtualBox go to
    Settings → Display → Scale Factor and increase it as needed, perhaps to 200%.

- The VM will log you in automatically. The username is `camel` and the password
  is `camel`. To change your password, run `passwd` from the terminal and follow
  the prompts. If you’d rather have your own username, you are welcome to go to
  Settings → Users to create a new account. Just be aware that OPAM and VS Code
  won’t be installed for that user. You'll need to follow the
  [install instructions](../preface/install.md) to add them.

## Stopping the VM

You can use Ubuntu's own menus to safely shutdown or reboot the VM. But more
often you will likely use VirtualBox to close the VM by clicking the VM window’s
"X" icon in the host OS. Then you will be presented with three options that
VirtualBox doesn't explain very well:

- *Save the machine state.* This option is what you normally want. It’s like
  closing the lid on your laptop: it puts it to sleep, and it can quickly wake.

- *Send the shutdown signal.* This option is like shutting down a machine you
  don’t intend to use for a long time, or before unplugging a desktop machine
  from the wall. When you start the machine again later, it will have to boot
  from scratch, which takes longer.

- *Power off the machine.* **This option is dangerous.** It is the equivalent of
  pulling the power cord of a desktop machine from the wall while the machine is
  still running: it causes the operating system to suddenly quit without doing
  any cleanup. Doing this even just a handful of times could cause the file
  system to become corrupted, which will cause you to lose all your work and
  have to reinstall the VM from scratch. You will be very unhappy. So, avoid
  this option.

## Using the VM

- There are **icons** provided for the terminal, VS Code, and the Firefox web
  browser. They are in the left-hand launcher bar.

- It can be helpful to set up a **shared folder** between the host and guest OS,
  so that you can easily copy files between them. With the VM shutdown (i.e.,
  select “send the shutdown signal”), click Settings, then click Shared Folders.
  Click the little icon on the right that looks like a folder with a plus sign.
  In the dialog box for Folder Path, select Other, then navigate to the folder
  on your host OS that you want to share with the guest OS. Let’s assume you
  created a new folder named `vmshared` inside your Documents folder, or
  wherever you like to keep files. The Folder Name in the dialog box will
  automatically be filled with `vmshared`. This is the name by which the guest
  OS will know the folder. You can change it if you like. Check Auto-mount; do
  not check Read-only. Make the Mount Point `/home/camel/vmshared`. Click OK,
  then click OK again. Start the VM again. You should now have a subdirectory
  named `vmshared` in your guest OS home directory that is shared between the
  host OS and the guest OS.

- You might be able to improve the **performance** of your VM by increasing the
  amount of memory or CPUs allocated to it, though it depends on how much your
  actual machine has available and what else you have running at the same time.
  With the VM shut down, try going in Virtual Box to Settings → System, and
  tinkering with the Base Memory slider on the Motherboard tab, and the
  Processors slider on the Processor tab. Then bring up the VM again and see how
  it does. You might have to play around to find a sweet spot. Later, after you
  are satisfied the VM is working properly hence you won't have to re-import it,
  you can safely delete the `.ova` file you downloaded to free up some space.

[rh-virt]: https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/virtualization_administration_guide/sect-virtualization-troubleshooting-enabling_intel_vt_and_amd_v_virtualization_hardware_extensions_in_bios
