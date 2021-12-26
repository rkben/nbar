import std/[os, json, times, strutils, strformat, osproc, parseopt]
import system/io

proc cpuSpeed(): int =
  var line: string = readFile("/sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq")
  result = toInt(parseInt(line.strip()) / 1000)

proc cpuTemp(): float =
  let o = execProcess("sensors -j")
  let j = parseJson(o)
  result = j["coretemp-isa-0000"]["Package id 0"]["temp1_input"].getFloat()

proc runJson(): bool =
    let speed = cpuSpeed()
    var speedcolor = "#FFFFFF"
    let temp = cpuTemp()
    var tempcolor = "#FFFFFF"
    let time = now().format("dd-MM-yyyy :: HH:mm:ss")
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
  let speed = cpuSpeed()
  let temp = cpuTemp()
  let time = now().format("dd-MM-yyyy :: HH:mm:ss")
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
      
        
