#!/bin/env python3

import argparse
import json
import pandas as pd
from typing import List, Dict, Tuple, Literal, Any, Optional
from math import sqrt
from os import path

PATH: str = path.expanduser("~")+"/.local/share/godot3/app_userdata/NML 5/"
RACES: List[str] = ["P", "Z", "T", "R", "rp"]
MINPLAY: int = 8
ELOBASE: int = 400
STARTRANK: int = 1000
UPDATE: int = 32

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

def makeWinLossDict(winLossTable: pd.DataFrame, rankTable: pd.DataFrame) -> Dict:
    winLossDict: Dict = {}
    for lineInd in winLossTable.index:
        name: str = winLossTable.at[lineInd, "name"]
        race: str = winLossTable.at[lineInd, "race"]
        raceInd: int = RACES.index(race)
        rank: Optional[pd.Int64Dtype] = rankTable.at[(name, race), "rank"]
        if name not in winLossDict.keys():
            winLossDict[name] = {
                raceInd: {
                    "results": {}
                }
            }
        else:
            winLossDict[name][raceInd] = {"results": {}}
        if rank is not pd.NA:
            winLossDict[name][raceInd]["rank"] = int(rank)
        tempDict: Dict = winLossDict[name][raceInd]["results"]
        for vsRaceInd, vsRace in enumerate(RACES):
            tempDict[vsRaceInd] = {
                "win": int(winLossTable.at[lineInd, vsRace + "_x"]),
                "loss": int(winLossTable.at[lineInd, vsRace + "_y"]),
            }
    return winLossDict

def isSamePair(
    pairOne: Tuple[Tuple[str, str], Tuple[str, str]],
    pairTwo: Tuple[Tuple[str, str], Tuple[str, str]]
)-> bool:
    if (
        (pairOne[0][0] != pairTwo[0][0] or pairOne[0][1] != pairTwo[0][1]) and
        (pairOne[0][0] != pairTwo[1][0] or pairOne[0][1] != pairTwo[1][1])
    ):
        return False
    if (
        (pairOne[1][0] != pairTwo[0][0] or pairOne[1][1] != pairTwo[0][1]) and
        (pairOne[1][0] != pairTwo[1][0] or pairOne[1][1] != pairTwo[1][1])
    ):
        return False
    return True

def getMatches(
    matchListCut: pd.DataFrame,
    player: Tuple[str, str],
    rankTable: pd.DataFrame
) -> Tuple[pd.DataFrame, pd.DataFrame]:
    name, race = player
    matchListWon = pd.merge(
        (
            matchListCut[
                (matchListCut["wr"]==race) & (matchListCut["wn"]==name)
            ][["lr", "ln"]]
            .rename(columns={"lr": "race", "ln": "name"})
            .set_index(["name", "race"])
        ),
        rankTable[["rank"]],
        left_index=True, right_index=True
    )
    matchListLost = pd.merge(
        (
            matchListCut[
                (matchListCut["lr"]==race) & (matchListCut["ln"]==name)
            ][["wr", "wn"]]
            .rename(columns={"wr": "race", "wn": "name"})
            .set_index(["name", "race"])
        ),
        rankTable[["rank"]],
        left_index=True, right_index=True
    )
    if (
        matchListLost["rank"].notna().sum() +
        matchListWon["rank"].notna().sum() == 0
    ):
        matchListWon = matchListWon.fillna(STARTRANK)
        matchListLost = matchListLost.fillna(STARTRANK)
    else:
        matchListWon = matchListWon[(matchListWon["rank"].notna())]
        matchListLost = matchListLost[(matchListLost["rank"].notna())]
    return matchListWon, matchListLost


def initRanking(
    player: Tuple[str, str],
    rankTable: pd.DataFrame,
    matchList: pd.DataFrame,
    currentLine: int
) -> pd.DataFrame:
    currentRank: Optional[int] = rankTable.at[player, "rank"]
    assert currentRank is pd.NA
    startLine: int = rankTable.at[player, "cleared"] + 1
    matchListCut = matchList[startLine:currentLine+1]
    matchListWon, matchListLost = getMatches(matchListCut, player, rankTable)
    losses: int = len(matchListLost)
    wins: int = len(matchListWon)
    currentRank = int(
        (
            matchListLost["rank"].sum() +
            matchListWon["rank"].sum() +
            ELOBASE * (wins - losses)
        ) / (wins + losses)
    )
    #print(f"  > {player} with {wins} Ws and {losses} Ls gets rank {currentRank}")
    rankTable.at[player, "rank"] = currentRank
    return rankTable

def updateRanking(
    player1: Tuple[str, str],
    player2: Tuple[str, str],
    rankTable: pd.DataFrame,
    matchList: pd.DataFrame,
    currentLine: int
) -> pd.DataFrame:
    currentRank1: Optional[int] = rankTable.at[player1, "rank"]
    currentRank2: Optional[int] = rankTable.at[player2, "rank"]
    assert currentRank1 is not pd.NA and currentRank2 is not pd.NA
    matchListWon1, matchListLost1 = getMatches(
        matchList[rankTable.at[player1, "cleared"]+1:currentLine+1],
        player1,
        rankTable
    )
    matchListWon2, matchListLost2 = getMatches(
        matchList[rankTable.at[player2, "cleared"]+1:currentLine+1],
        player2,
        rankTable
    )
    wins1: int = len(matchListWon1)
    wins2: int = len(matchListLost1)
    games: int = wins1 + wins2
    if not (wins1 == len(matchListLost2) and wins2 == len(matchListWon2)):
        #print(rankTable)
        assert False
    expected: float = games/(1+10**((currentRank2-currentRank1)/ELOBASE))
    updateVal: int = int(UPDATE * (wins1 - expected) / sqrt(games))
    #print(f"  > {player1} rank {currentRank1} wins {wins1} (exp {expected})")
    #print(f"  > {player2} rank {currentRank2} wins {wins2}")
    #print(f"    > update: {currentRank1+updateVal}, {currentRank2-updateVal}")
    rankTable.at[player1, "rank"] += updateVal
    rankTable.at[player2, "rank"] -= updateVal
    return rankTable

def calculateRanking(
    matchList: pd.DataFrame,
    winLossTable: pd.DataFrame,
    saveHistory: bool = False,
) -> pd.DataFrame:
    rankTable = winLossTable[["name", "race"]].copy()
    rankTable = rankTable.set_index(["name", "race"])
    rankHistory = rankTable.transpose()
    rankTable["rank"] = pd.NA
    rankTable["rank"] = rankTable["rank"].astype("Int64")
    rankTable["played"] = 0
    rankTable["cleared"] = -1
    for matchNum in matchList.index:
        winner: Tuple[str, str] = (
            matchList.at[matchNum, "wn"], matchList.at[matchNum, "wr"]
        )
        loser: Tuple[str, str] = (
            matchList.at[matchNum, "ln"], matchList.at[matchNum, "lr"]
        )
        #print(f"Match {matchNum}, {winner} beat {loser}")
        rankTable.at[winner, "played"] += 1
        rankTable.at[loser, "played"] += 1
        if (
            matchNum + 1 in matchList.index and
            isSamePair(
                (
                    (
                        matchList.at[matchNum+1, "wn"],
                        matchList.at[matchNum+1, "wr"]
                    ),
                    (
                        matchList.at[matchNum+1, "ln"],
                        matchList.at[matchNum+1, "lr"]
                    )
                ),
                (winner, loser)
            )
        ):
            continue
        # If you playe against someone with no ranking, you don't get anything
        if (
            rankTable.at[winner, "rank"] is not pd.NA and
            rankTable.at[loser, "rank"] is pd.NA
        ):
            #print(f"    > {winner} clrd at ", rankTable.at[winner, "cleared"])
            rankTable.at[winner, "cleared"] = matchNum
        if (
            rankTable.at[loser, "rank"] is not pd.NA and
            rankTable.at[winner, "rank"] is pd.NA
        ):
            #print(f"    > {loser} clrd at ", rankTable.at[loser, "cleared"])
            rankTable.at[loser, "cleared"] = matchNum
        # If you isn't ranked yet but cleared the req games you get your rank
        if (
            rankTable.at[winner, "played"] >= MINPLAY and
            rankTable.at[winner, "rank"] is pd.NA
        ):
            rankTable = initRanking(winner, rankTable, matchList, matchNum)
            rankTable.at[winner, "cleared"] = matchNum
            rankHistory.loc[matchNum, winner] = rankTable.at[winner, "rank"]
        if (
            rankTable.at[loser, "played"] >= MINPLAY and
            rankTable.at[loser, "rank"] is pd.NA
        ):
            rankTable = initRanking(loser, rankTable, matchList, matchNum)
            rankTable.at[loser, "cleared"] = matchNum
            rankHistory.loc[matchNum, loser] = rankTable.at[loser, "rank"]
        # If both players were already ranked, their rank gets updated
        # (we don't update you if you just got ranked after this round)
        if (
            rankTable.at[winner, "rank"] is not pd.NA and
            rankTable.at[winner, "cleared"] != matchNum and
            rankTable.at[loser, "rank"] is not pd.NA and
            rankTable.at[loser, "cleared"] != matchNum
        ):
            rankTable = updateRanking(
                winner, loser, rankTable, matchList, matchNum
            )
            #print(f"    > {loser} clrd at ", rankTable.at[loser, "cleared"])
            rankTable.at[loser, "cleared"] = matchNum
            rankHistory.loc[matchNum, loser] = rankTable.at[loser, "rank"]
            #print(f"    > {winner} clrd at ", rankTable.at[winner, "cleared"])
            rankTable.at[winner, "cleared"] = matchNum
            rankHistory.loc[matchNum, winner] = rankTable.at[winner, "rank"]
    if saveHistory:
        rankHistory.astype("Int64").to_csv("rankhistory.csv")
    return rankTable

def processCsv(filename: str) -> None:
    matchList = pd.read_csv(filename)
    winLossTable = makeWinLossTable(matchList)
    rankTable = calculateRanking(matchList, winLossTable)
    winLossDict = makeWinLossDict(winLossTable, rankTable)
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
