@echo off
title ���wsl�ƻ�����
powershell -Command "& {Start-Process powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File %~dp0\scheduled-task\AddScheduledTask.ps1' -Verb RunAs}"
