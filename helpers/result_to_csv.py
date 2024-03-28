#!/bin/env python3

import json
import pandas as pd
from typing import List, Dict, Any
from os import path

PATH: str = path.expanduser("~")+"/.local/share/godot3/app_userdata/NML 5/"
RACES: List[str] = ["P", "Z", "T", "R", "rp"]

def get_json(filename: str) -> Dict[str, Any]:
    with open(PATH + filename) as json_file:
        return json.load(json_file)
    return {}

players: pd.DataFrame = pd.DataFrame(columns=["id", "name", "race"])
for playerid, playerdata in get_json("players.json").items():
    race: int = -1
    for racevs, race_played in playerdata["races"].items():
        if race == -1:
            race = race_played
            continue
        if race == race_played:
            continue
        if race == 4:
            break
        race = 4
    players = pd.concat([
        players,
        pd.DataFrame([{
            "id": playerid,
            "name": playerdata["name"],
            "race": RACES[race]
        }])
    ])
players = players.set_index("id")

maps: pd.DataFrame = pd.DataFrame(columns=["id", "name"])
for mapid, mapdata in get_json("maps.json").items():
    maps = pd.concat([
        maps,
        pd.DataFrame([{
            "id": mapid,
            "name": mapdata["name"]
        }])
    ])
maps = maps.set_index("id")

matches: pd.DataFrame = pd.DataFrame(columns=["winner_id", "loser_id", "map_id"])
for game_round in get_json("tournament.json").values():
    for pair in game_round.values():
        for matchdata in pair["matches"].values():
            player_one = matchdata["playerOne"]
            player_two = matchdata["playerTwo"]
            for index in matchdata["results"]:
                if matchdata["results"][index] == "1":
                    matches = pd.concat([
                        matches,
                        pd.DataFrame([{
                            "winner_id": player_one,
                            "loser_id" : player_two,
                            "map_id"   : matchdata["mapPool"][index]
                        }])
                    ])
                else:
                    matches = pd.concat([
                        matches,
                        pd.DataFrame([{
                            "winner_id": player_two,
                            "loser_id" : player_one,
                            "map_id"   : matchdata["mapPool"][index]
                        }])
                    ])

final = pd.merge(matches, players, how="left", left_on="winner_id", right_on="id")
final = final.rename({"name": "w_name", "race": "w_race"}, axis=1)
final = pd.merge(final, players, how="left", left_on="loser_id", right_on="id")
final = final.rename({"name": "l_name", "race": "l_race"}, axis=1)
final = pd.merge(final, maps, how="left", left_on="map_id", right_on="id")
final = final.rename({"name": "map"}, axis=1)

final = final[["w_race", "w_name", "l_name", "l_race", "map"]]

final.to_csv("nml5.csv", index=False)

