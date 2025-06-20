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

1. Remove empty lines
2. Join games into single lines
1. Remove PGN metadata for readability
1. Add data into greppable columns at the start of each line

> [!TIP]
> Below are (n)vim commands. Yank line into `"0` by `yy` and apply with `@0`.

### Remove empty lines

```vim
:g/^$/d
" Deprecated: Needed for joining"
:g/\V\^[/d
```

### Join lines

Add a single empty line at the end beforehand.

```vim
" Deprecated: Pattern not guaranteed
:g/^1\./;/\} \*$/join
" Join by grepping for '[Event'. Needs an empty line at end of file.
:g/^\[Event/;/^\[Event\|\%$/-1join
" Sanity check
:v/^\[Event/p
```

### Remove metadata

```vim
" Remove PGN metadata
:%s/\[.\{-}\]\s*//gp
" Sanity check
:v/^1\./p
```

### Add data columns

Prepend the line number. Prepend author names. Convert line numbers into game
numbers.

1. Line numbers are formatted to make them sort correctly lexicographically. Long
enough that all values start with digit 0, resulting in `#0` at the start.
1. Names are grepped to be between the first `{` and the non-ASCII character `—` (or `}` as fallback for the special case `{ Unknown }`). Conversion to lower case ensures consistent sorting between different upper/lower case spellings of the same names.
1. Game numbers grep for `#0` from line numbers.

```vim
:%s/^/\=printf('#%04d', line('.')).' ┃ '/
:%s/^.\{-}{ \(.\{-}\) \%(—\|}\).*$/\L\1\E ┃ \0/
:%s/\#0*\(\d\{-}\) \zs/\=printf('(♚ %04d ♔ %04d) ', submatch(1) * 2 - 1, submatch(1) * 2)/
```
