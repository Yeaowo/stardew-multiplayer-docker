#!/bin/sh

echo "-- SMAPI Log: Starting"

logFile="${XDG_CONFIG_HOME}/StardewValley/ErrorLogs/SMAPI-latest.txt"

# Wait for SMAPI log and tail infinitely
until [ -f "$logFile" ]; do
  echo "-- SMAPI Log: Waiting for log to appear"
  sleep 5
done

echo "-- SMAPI Log: Tailing"
tail -f "$logFile"
