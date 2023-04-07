@echo off

@set Doc=".\Doc"

if exist %Doc% (
	TortoiseProc /command:update /path:%Doc% /closeonend:0
)

echo ok