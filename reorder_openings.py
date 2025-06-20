#!/usr/bin/env python3

"""
- Input : 'combined_input.pgn'  line-wise concatenation of some .pgn files
- Output: 'combined_output.pgn' sorted by number of openings from each author
"""

import chess
import chess.pgn

# https://python-chess.readthedocs.io/en/latest/pgn.html
pgn = open("combined_input.pgn")

# Games are counted as millions. The low decimals encode the author number. The
# 3rd author having 21 openings becomes 21'000'003.
MAX_GAMES = 1000000

with open("combined_output.pgn", "w") as fp_out:
    author_dict = {}
    game_lst = []
    while True:
        game_obj = chess.pgn.read_game(pgn)
        if game_obj == None:
            break
        game_string = str(game_obj)
        word_split = game_string.split()

        # When no { is found there is no author
        index = word_split.index("{") if "{" in word_split else -1
        # Cannot be followed by a name if last word
        if index == len(word_split): index = -1
        # BUG: Does not allow for multi-word names
        author = word_split[index + 1] if index != -1 else "unknown_author"
        if author not in author_dict.keys():
            author_dict[author] = len(author_dict.keys())
        else:
            author_dict[author] += MAX_GAMES
        key = author_dict[author]
        game_lst.append((key, game_string))
    game_lst.sort()
    for key, game_string in game_lst:
        fp_out.write(game_string)
    print(f"{len(author_dict)} authors, {len(game_lst)} openings")
    [print(f"{a}: {author_dict[a]} openings") for a in author_dict.keys()]
