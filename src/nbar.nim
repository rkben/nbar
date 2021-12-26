import std/[os, json, times, strutils, strformat, osproc, parseopt]
import system/io

const delay = 5
var lastTime: float = 0.0
var lastTemp: float = 0.0
var lastSpeed: int = 0
proc cpuSpeed(): int =
  var line: string = readFile("/sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq")
  result = toInt(parseInt(line.strip()) / 1000)
  lastSpeed = result

proc cpuTemp(): float =
  let o = execProcess("sensors -j")
  let j = parseJson(o)
  result = j["coretemp-isa-0000"]["Package id 0"]["temp1_input"].getFloat()
  lastTemp = result

proc runJson(): bool =
  # TODO clean up delay handling
  var speed = lastSpeed
  var temp = lastTemp
  var time = now().format("dd-MM-yyyy :: HH:mm:ss")
  if (epochTime() - lastTime) >= delay:
    speed = cpuSpeed()
    temp = cpuTemp()
    lastTime = epochTime()
  var speedcolor = "#FFFFFF"
  var tempcolor = "#FFFFFF"
  var timecolor = "#FFFFFF"
  if temp >= 60:
      tempcolor = "#A73333"
  if speed <= 2000:
      speedcolor = "#959595"
  echo ","
  echo %*[{"full_text": fmt"{speed}MHz", "color": speedcolor},
          {"full_text": fmt"{temp}°C", "color": tempcolor},
          {"full_text": time, "color": timecolor}]

proc runTty(): bool =
  # TODO clean up delay handling
  var speed = lastSpeed
  var temp = lastTemp
  var time = now().format("dd-MM-yyyy :: HH:mm:ss")
  echo epochTime()
  if (epochTime() - lastTime) >= delay:
    speed = cpuSpeed()
    temp = cpuTemp()
    lastTime = epochTime()
  echo fmt"{speed}MHz | {temp}°C | {time}"

proc runHelp(): bool =
  echo "--help,-h\n--json,-j output JSON for i3\ndefault is tty"
  quit()

when isMainModule:
  let cmd = commandLineParams()
  var params = initOptParser(cmd)
  var tty = true
  for ki,ke,val in params.getopt():
    case ki
    of cmdLongOption, cmdShortOption:
      case ke
      of "help", "h":
        discard runHelp()
      of "json", "j":
        tty = false
      else:
        discard runHelp()
    else:
        discard runHelp()

  if tty == false:
    echo ("{\"version\": 1}\n[\n[]")
  while true:
    if tty == true:
      discard runTty()
    else:
      discard runJson()
    sleep 1000
      
        
