import std/[os, json, times, strutils, strformat]
import system/io


proc cpuSpeed(): string =
  var line: string = readFile("/sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq")
  let clock = toInt(parseInt(line.strip()) / 1000)
  result = fmt"{clock}MHz"

proc cpuTemp(): string =
  var line: string = readFile("/sys/class/hwmon/hwmon0/temp1_input")
  let temp = parseInt(line.strip()) / 1000
  result = fmt"{temp}°C"


when isMainModule:
  echo ("{\"version\": 1}\n[\n[]")
  while true:
    echo ","
    echo %*[{"full_text": cpuSpeed()},
            {"full_text": cpuTemp()},
            {"full_text": now().format("dd-MM-yyyy :: HH:mm:ss")}]
            # echo ",[{\"name\":\"time\",\"full_text\":\"status:\", \"separator\": false},  {\"full_text\":\"not-fucked\",\"color\": \"#00ff00\"}]"
    sleep 1000
