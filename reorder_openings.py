#!/usr/bin/env python3

"""Guess: `combined_input.pgn` is just the line-wise concatenation of some .pgn
files.
"""

MAX_GAMES = 1000000
split_str = '[Event "'
with open("combined_output.pgn", "w") as fp_out:
    author_dict = {}
    author_no = 0
    game_lst = []
    for game in open("combined_input.pgn").read().split(split_str):
        if not game:
            continue
        game = split_str + game
        l = game.split()
        author = l[l.index("{") + 1]
        print(author)
        if author not in author_dict:
            author_dict[author] = author_no
            author_no += 1
        else:
            author_dict[author] += MAX_GAMES
        key = author_dict[author]
        game_lst.append((key, game))
    game_lst.sort()
    for key, game in game_lst:
        fp_out.write(game)
    print(f"{len(author_dict)} authors, {len(game_lst)} openings")
