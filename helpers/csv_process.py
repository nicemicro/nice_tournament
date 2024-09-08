#!/bin/env python3

import argparse
import json
import pandas as pd
from typing import List, Dict, Any
from os import path

PATH: str = path.expanduser("~")+"/.local/share/godot3/app_userdata/NML 5/"
RACES: List[str] = ["P", "Z", "T", "R", "rp"]

def makeTable(
    matchList: pd.DataFrame,
    primaryCols: list[str],
    secondaryCol: str
) -> pd.DataFrame:
    winners = (
        matchList.groupby(by=primaryCols)
        .count()
        .reset_index(drop=False)
    )[primaryCols]
    winners["num"] = range(len(winners))
    winnersMatches = pd.merge(winners, matchList, on=primaryCols)
    table = pd.merge(
        pd.crosstab(
            index=winnersMatches["num"],
            columns=winnersMatches[secondaryCol]
        ),
        winners,
        on="num"
    )
    for colname in RACES:
        if colname not in table.columns:
            table[colname] = 0
        table[colname] = table[colname].astype("Int64")
    table = table[primaryCols + RACES]
    table["sum"] = table[RACES].sum(axis=1)
    return table

def makeLoserTable(matchList: pd.DataFrame) -> pd.DataFrame:
    return (
        makeTable(matchList, ["lr", "ln"], "wr")
        .rename(columns={"lr": "race", "ln": "name"})
    )

def makeWinnerTable(matchList: pd.DataFrame) -> pd.DataFrame:
    return (
        makeTable(matchList, ["wr", "wn"], "lr")
        .rename(columns={"wr": "race", "wn": "name"})
    )

def makeWinLossTable(matchList: pd.DataFrame) -> pd.DataFrame:
    results = pd.merge(
        makeWinnerTable(matchList),
        makeLoserTable(matchList),
        on=["name", "race"],
        how="outer"
    ).fillna(0)
    return results.sort_values(by=["name", "race"])

def makeWinLossDict(winLossTable: pd.DataFrame) -> Dict:
    winLossDict: Dict = {}
    for lineInd in winLossTable.index:
        name: str = winLossTable.at[lineInd, "name"]
        race: str = winLossTable.at[lineInd, "race"]
        raceInd: int = RACES.index(race)
        if name not in winLossDict.keys():
            winLossDict[name] = {raceInd: {}}
        else:
            winLossDict[name][raceInd] = {}
        tempDict: Dict = winLossDict[name][raceInd]
        for vsRaceInd, vsRace in enumerate(RACES):
            tempDict[vsRaceInd] = {
                "win": int(winLossTable.at[lineInd, vsRace + "_x"]),
                "loss": int(winLossTable.at[lineInd, vsRace + "_y"]),
            }
    return winLossDict

def processCsv(filename: str) -> None:
    matchList = pd.read_csv(filename)
    winLossTable = makeWinLossTable(matchList)
    winLossDict = makeWinLossDict(winLossTable)
    with open('previous_games.json', 'w') as fp:
        json.dump(winLossDict, fp)

def arguments() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(exit_on_error=True)
    parser.add_argument("filename")
    return parser

def main() -> None:
    try:
        cmd_args = arguments().parse_args()
    except:
        return
    processCsv(cmd_args.filename)

if __name__ == "__main__":
    main()
