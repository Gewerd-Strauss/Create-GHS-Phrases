# Create-GHS-Phrases
A small script for automatically inserting Hazard-, Precautionary- and EUH-phrases according from file.

# How to use this

1. Write down all Phrase-Keys (`H202`,`P304`,etc) of a chemical below each other. Combinations are connected by `+`:

```
Stannous Octaoate:
H317
H318
H361
H412
P273
P280
P305+P351+P338
```

Then, highlight all the phrases you want to translate, and press <kbd>Alt</kbd> + <kbd>0</kbd>

```
Stannous Octaoate:

H317: May cause an allergic skin reaction.
H318: Causes serious eye damage.
H361: Suspected of damaging fertility or the unborn child <state specific effect if known> <state route of exposure if it is conclusively proven that no other routes of exposure cause the hazard>.
H412: Harmful to aquatic life with long lasting effects.
P273: Avoid release to the environment.
P280: Wear protective gloves/protective clothing/eye protection/face protection.
P305+P351+P338: IF IN EYES: Rinse cautiously with water for several minutes. Remove contact lenses, if present and easy to do. Continue rinsing.


ERROR LOG (REMOVE AFTERWARDS)
-----------------
-----------------
```

The error-log gives information on phrases whose Key (that is the `H317`, for instance could not be found in the library file). See [Errors](#errors)

# Errors
