@echo off
title 添加wsl计划任务
powershell -Command "& {Start-Process powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File %~dp0\scheduled-task\AddScheduledTask.ps1' -Verb RunAs}"
