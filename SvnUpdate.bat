@echo off

@set Asset=".\Assets"

if exist %Asset% (
	TortoiseProc /command:update /path:%Asset% /closeonend:0
)

echo ok