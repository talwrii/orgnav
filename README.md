# orgnav

Quickly navigate and search your emacs org trees; use this navigation to capture and organize.
Built with the help of helm.

## Motivational introduction

This library allows you navigate your org tree interactively with helm.
As an example using this library you might:

* Start searching your org tree at the top-level
* Increase the depth you are displaying a few times with `M-l`
* Filter to tasks that are in progress by searching for "INPROGRESS"
* Find a task that you are interested in using `M-j` and `M-k`
* Look at the ancestors of this task with `M-a`
* Find an interesting ancestor and look at all its descendents with `M-.`

To get a summary of how to use this library, run `M-x orgnav-search-root` and press `TAB`.
This will display a list of keybindings. Using these keybindings is very much encouraged.

Run `M-x orgnav<TAB>` for a list of functions: functions without `--`s in them
are public functions that you might like to call.

## Installing

Place this repository on your `load-path`. Add

```
(require `orgnav)
```

to your `init.el`.

Run some functions with `M-x`.

You may well want to set up some keybindings using
`define-key` and `global-set-key`. No defaults are provided since users
of this library likely have strong opinions about such things.

## Debugging

Try setting the `orgnav-log` variable and reviewing the `*Messages*` buffer:

```
(setq orgnav-log 't)
```

## Advanced-use features
### Extensibility
Functions are moderately flexible and you can call them yourself from elisp.
Whenever you want to find org nodes to operate on from elisp this library can be useful. The synchronuos variants of functions are very relevant here.

#### Specific-purpose convenience functions
The core of this library is the navigation interface that can be used extensibly from elisp. However some common (or obvious) examples are included:


* Clocking into items (`orgnav-clock-in`)
* Refiling (`orgnav-refile`, `orgnav-refile-ancestors` and friends)
* Use with `org-capture` to select your capture target (`orgnav-capture-function-relative` and `orgnav-capture-function-global`)

## Alternatives

# helm-org
`helm-org` has the feeling of a proof-of-concept library. `orgnav` is more complete, and
intends to be more of a complete navigation tool than a searching library.
However, for simple use cases, `helm-org` may be good enough and is likely more stable.
You may be able to use `narrowing` to work around some of the limitations.

### Judicious use of `org-capture`, `org-refile`, and `org-find-olp`
Though initially slightly cryptic if you are willing to do some
scripting these functions are very powerful. This is particularly the case if
your workflow is quite consistent.

The general purpose functionality of `orgnav` may be unnecessary for you:
hacking up some elisp that supports a very limited workflow might work better.
Specifically, this is likely to be the case if you are rarely creating new nesting
in your org file.

### org-sparse-tree
In some ways, `org-sparse-tree` overlaps with this library, as well as providing
a number of orthogonal searching criteria. The downsides of `org-sparse-tree` are
that it changes the folding of your buffer, and can show a lot of intermediate nodes
slowing down reading.
You can avoid problems related to "losing your place" by using `clone-indirect-buffer`
to create multiple views of your buffer.
`org-sparse-tree` also has the benefit of allowing in-place editing.
`helm` does not support this, but similar types of actions can be achieved in `orgnav` through
`org-capture`.

## Caveats

* This software is not very mature
* Operations can be slow for large trees (e.g a file with 13 thousand lines)
* Sometimes pressing keys too quickly can break `helm`.
* The tree is based on character offsets, which can interfere with `helm-resume`. This could be addressed using *olp*s rather than offsets
* Some of the keybindings here almost certainly shadow `helm` defaults
* There is very limited testing at present

## Contributing

Contributions are welcome.

Testing helm is hard. This may prove to be an issue for accepting contributions, but I can deal with
this if anyone actually contributes anything. It's probably possible to script helm for testing.

You can do some basic linting, and ensure that installation works using `test.sh`.
