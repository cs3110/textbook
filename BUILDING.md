# How to Create the Conda Textbook Environment

- Install
  [Miniconda3 for Python 3.9](https://docs.conda.io/en/latest/miniconda.html).
- Run `conda update -n base -c defaults conda` to upgrade that base install to
  latest versions.
- Proceed with one of the next two options.

Automatic option (recommended for quality of life):

- Install [conda-auto-env](https://github.com/introkun/conda-auto-env). All you
  have to do is clone the repo and source the script.
- Now any time you `cd` into the root of the textbook repo you'll have the right
  environment active. You lose the environment by cd'ing below it though.

Manual option:

- Run `conda env create -f environment.yml` to create the `textbook`
  environment.
- Run `conda activate textbook` to activate the environment **every time** you
  want to work on the textbook.

# How to Create the OCaml Jupyter Kernel

- Create an OPAM switch for the textbook.  This should be a switch with
  minimal packages installed. E.g.,
  `opam switch create textbook ocaml-base-compiler.4.12.0`
- Install Ocaml-Jupyter with `opam install jupyter`.
- Also install the packages needed by the textbook:
  `opam install ounit2 qcheck menhir`.
- Run `ocaml-jupyter-opam-genspec`. Note in the output where it generated
  the kernelspec. Edit that file and change the `display_name` to just "OCaml".
  **That's important.** The display name will be hardcoded in each chapter
  that uses code cells, unfortunately, so we need a name that is consistent
  and independent of the name of the switch in the current semester.
- Make sure you've already done the above Conda environment install and have
  that environment active.
- Run `jupyter kernelspec install --user --name ocaml-jupyter "$(opam var share)/jupyter"`
- If your `~/.ocamlinit` has `#use "topfind";;` consider surrounding that with
  ```
  Sys.interactive := false;;
  #use "topfind";;
  Sys.interactive := true;;
  ```
  That will reduce the amount of output you see when building the textbook.

# How to Build the Textbook

- Run `make build` or just `make` to build the HTML version.
- Run `make view` (currently supported on Mac only) to conveniently open the
  generated HTML in your browser.
- Run `make deploy` to deploy the textbook to GitHub Pages. Before doing that,
  you need to have a git remote set up. You can do so with
  `git remote add public git@github.com:cs3110/textbook.git`. The name of the
  remote, `public` in that example command, can be configured at the top of
  `Makefile` if you want to use a different name.