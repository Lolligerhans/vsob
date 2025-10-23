<!-- markdownlint-disable line-length -->
<!-- markdownlint-disable no-inline-html -->

# VSOB PGN sorting

<!--toc:start-->
- [VSOB PGN sorting](#vsob-pgn-sorting)
  - [PGN data format](#pgn-data-format)
  - [Processing steps](#processing-steps)
    - [Remove empty lines](#remove-empty-lines)
    - [Join lines](#join-lines)
    - [Remove metadata](#remove-metadata)
    - [Format move notation](#format-move-notation)
    - [Add data columns](#add-data-columns)
    - [Sort](#sort)
    - [Misc](#misc)
<!--toc:end-->

## PGN data format

<details>
  <summary>Example</summary>

```text
[Event "?"]
[Site "?"]
[Date "????.??.??"]
[Round "?"]
[White "?"]
[Black "?"]
[Result "*"]
[ECO "A06"]

1.Nf3 d5 2.b3 c5 3.Bb2 Nc6 4.g3 Nf6 5.Bg2 d4 6.c3 e5 7.cxd4 exd4 8.d3 Nd5
9.O-O Be7 10.Nbd2 O-O 11.Qc1 Bg4 12.Re1 Qd7 13.Bh1 Rfe8 14.Rb1 Bf8 15.a3 b6
16.Qc4 Rad8 17.Ra1 a5 18.Rab1 *
{ Unknown }

[Event "?"]
[Site "?"]
[Date "????.??.??"]
[Round "?"]
[White "?"]
[Black "?"]
[Result "*"]
[ECO "B00"]

1.e4 b6 2.d4 g6 3.Nf3 { soid

 —

08/04/2024 5:52 AM } *

[Event "Viewer Submitted Openings Bonus 22"]
[Site "?"]
[Date "????.??.??"]
[Round "?"]
[White "?"]
[Black "?"]
[Result "*"]
[ECO "B00"]
[Opening "Pirc"]

1. e4 d6 2. d4 Nf6 3. f3 a6 { Ove — 10/22/2021

New for TCEC! dbcn: +0.38

3 lichess games

wv=0.5, wdl=109 878 13, mt=303476, n=157497371, d=40, pv=4. Be3 e6 5. c4 Be7 6. Nc3 O-O 7. Be2 b5 8. cxb5 axb5 9. Bxb5 c6 10. Bd3 Qb6 11. Qd2 d5 12. Nge2 dxe4 13. Nxe4 Nbd7 14. O-O Ba6 15. Bxa6 Qxa6 16. N2c3 Rfb8 17. Bf2 Nd5 18. Rfc1 N7b6 19. b3 Ba3 20. Rd1 Nxc3 21. Qxc3 Nd5 22. Qc2 Nb4 23. Qc4 Qxc4 24. bxc4 } *
```

</details>

Relevant structure

1. We ignore (remove) empty all lines
1. PGN metadata
    - enclosed in square brackets `[]` without nesting
    - is the start of an entry
    - Always begins with `[Event`
        - separates games from each other
1. Comment
    - Is always present
    - Enclosed in curly braces `{}`
        - The first opening curly brace per game `{` belongs to the comment
    - Always contains the name
        - The name does not contain the special dash `—`
        - The name does not contain closing curly brace `}`
    - After joining lines, begins with one of
        - Regular pattern `{ JohnDoe —` (note the special not-ASCII dash `—`)
        - Special case when name is not known `{ JohnDoe }` (when the name is `Unknown`)
1. PGN moves
    - Move numbering matches pattern `/[[:digit:]]\+\./`

## Processing steps

1. Remove empty lines
1. Join games into single lines
1. Remove PGN metadata for readability
1. Format spaces in move notation
1. Add data into grep-able columns at the start of each line
1. Sort

> [!TIP]
> Below are (n)vim commands. Yank line into `"0` by `yy` and apply with `@0`.

### Remove empty lines

```vim
:g/^$/d
```

### Join lines

Add a single empty line at the end beforehand.

```vim
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

### Normalize spaces in move notation

Only needed when intending to sort on moves.

```vim
" Use single whitespace after move number
:%s/\d\.\zs\s*/ /g
```

### Add data columns

Prepend author names. Prepend the line number. Convert line numbers into game
numbers. Use the grep-able non-ASCII character `┃` (digraph `VV`) as delimiter.

1. Line numbers are formatted to make them sort correctly lexicographically.
1. Game numbers grep for `#[[:digit:]]*` (line numbers), but drop leading `0`s.
1. Length of book line (whole moves).
1. Names are grepped to be between the first `{` and the non-ASCII character `—` (or `}` as fallback for the special case `{ Unknown }`). Conversion to lower case ensures consistent sorting between different upper/lower case spellings of the same names.

> [!NOTE]
> The game numbering need to be done before sorting. It uses the text line
> number.

```vim
:%s/^/\=printf('#%04d', line('.')).' ┃ '/
:%s/\#0*\(\d\{-}\) \zs/\=printf('(♚ %04d ♔ %04d) ', submatch(1) * 2 - 1, submatch(1) * 2)/
" Grep for last '\d\.' followed by '{'
:%s/^\ze.*\<\(\d\+\)\..\{-}{/[\1] ┃ /
:%s/^.\{-}{\s*\(.\{-}\)\s*\%(—\|}\).*$/\L\1\E ┃ \0/
```

### Sort

> [!TIP]
> Sort when the intended criterion is at the beginning of the line, or use
> a pattern anchoring at non-ASCII '┃'.

```vim
:sort
" Sort by book line when not the first segment.
:sort i /┃ 1\./
" Sort by book length when not the first segment.
:sort! n /┃ \[/
```

### Misc

```vim
" Move last segment to front
:%s/\(.*\)┃ \(.*\)/\2 ┃ \1
```

<!-- Maybe useful later -->
<!-- :s/\w\+/\=len(submatch(0))/g -->
