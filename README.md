# VSOB PGN sorting

## PGN data format

Per game:

1. PGN metadata `[]`
1. chess opening line `1. Nf3 ...`
    - may span multiple text lines
1. The line is followed by a comment in curly braces.
    - typically on the same line without newline
    - may be on a newline (?)
    - the Comm has the format `{ John Does ... } *`
        - The name comes first
        - `*` is PGN notation outside the comment to say that the chess line ends but
          the game did not

## Processing steps

1. Remove obsolete lines
    - empty lines
    - PGN metadata: `[Event]`, `[Date]`
2. Join games into single lines
    - excluding the deleted metadata, all entries begin with `/^1\./`
3. Add data into greppable columns at the start of each line

> [!TIP]
> Below are (n)vim commands. Yank line into `"0` by `yy` and apply with `@0`.

### Remove obsolete lines

```vim
:g/^$/d
:g/\V\^[/d
```

### Join lines

Some lines in VSOB28 did not start with `/^1\./` but with a range like `89-90`.
Probably and accident. Maybe the indices of white/black opening? Removing all
instances by hand, found by verifying that all lines start with `1.` after
joining.

The join command greps for a `1.` at the start of a line until the next `} *` at
the end of a line and joins all these lines.

```vim
:g/^1\./;/\} \*$/join
:v/^1\./p
```

### Add data columns

Prepend the line number. Prepend author names. Convert line numbers into game
numbers.

1. Line numbers are formatted to make them sort correctly lexicographically. Long
enough that all values start with digit 0, resulting in `#0` at the start.
1. Names are grepped to be between the first `{` and the non-ASCII character `—`. Conversion to lower case ensures consistent sorting between different upper/lower case spelligns of the same names.
1. Game numbers grep for `#0` from line numbers.

```vim
:%s/^/\=printf('#%04d', line('.')).' ┃ '/
:%s/^.\{-}{ \(.\{-}\) —.*$/\L\1\E ┃ \0/
:%s/\#0*\(\d\{-}\) \zs/\=printf('(♚ %04d ♔ %04d) ', submatch(1) * 2 - 1, submatch(1) * 2)/
```
