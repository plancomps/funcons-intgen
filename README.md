# funcons-intgen

## Installation

To install, a local installation of `uu-cco` version `>= 0.1.0.6` is required, as provided [here](https://github.com/ltbinsbe/uu-cco), taking the following steps:

1. download and unpack zip
2. enter folder `uu-cco` and run `cabal sdist`
3. within the `funcons-intgen` repository folder:  
`cabal get <UU-CCO/dist-newstyle/sdist/uu-cco-<VERSION>.tar.gz`  
where `<UU-CCO>` is the path to the `uu-cco` folder of the previous step and `<VERSION>` is the version of the package (`>= 0.1.0.6`)

After these steps, install the `cbsc` executable  (CBS compiler) by running:

```cabal install```

## Translating funcon definitions

After installation, running `cbsc` should produce following output with usage instructions:

```
version CBS-beta
usage: cbsc <CBS-PATH> <SRC-DIR> <LANG>
CBS-PATH: path to the .cbs file
            for which code is to be generated.
            The file should be within a directory named "Funcons".
SRC-DIR: the source-directory in which the code is to be generated.
LANG: the language for which the .cbs file contains a specification.

```

As an example usage, consider the following, executed within the local copy of [Funcons-beta](https://github.com/plancomps/CBS-beta/tree/master/Funcons-beta):

```
cbsc Computations/Abnormal/Abrupting/Abrupting.cbs /tmp/cbs/ Core
Generating Computations/Abnormal/Abrupting/Abrupting.cbs
Generated Main.hs
Generated /tmp/cbs/Funcons/Core/Computations/Abnormal/Abrupting/Abrupting.hs
```

The file `Abrupting.hs` contains the Haskell functions, referred to as micro-interpreter within a 'funcon library' in [Executable Component-Based Semantics](https://doi.org/10.1016/j.jlamp.2018.12.004), generated for each of the funcon definitions in `Abrupting.cbs`. 
The file `Main.hs` imports this funcon library and provides a funcon term interpreter (the `main` function) capable of evaluating funcon terms constructed through the applications of the funcons within `Abrupting.cbs` (and no others, in this example).
Funcon term interpreters are described [here](https://hackage.haskell.org/package/funcons-tools/docs/Funcons-Tools.html) together with functions for composing funcon libraries, entity defaults and (data)type definitions (also generated from `.cbs` files). 
Funcon libraries are modular and support 'separate compilation' in that only `.cbs` files with updated Funcon definitions need to be recompiled in order to build the funcon term interpreter with the new semantics for the updated funcon. 

Although the example here shows the compilation of a `.cbs` file from Funcons-beta, the CBS compiler can be used in the same way to generate micro-interpreters for language-specific funcons.
