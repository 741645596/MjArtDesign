@echo off

@set Asset=".\Assets"

if exist %Asset% (
 TortoiseProc /command:commit /path:%Asset% /closeonend:0
)


echo ok