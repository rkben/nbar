import std/[os, json, times, strutils, strformat, osproc, parseopt]
import system/io


proc cpuSpeed(): string =
  var line: string = readFile("/sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq")
  let clock = toInt(parseInt(line.strip()) / 1000)
  result = fmt"{clock}MHz"

proc cpuTemp(): string =
  let o = execProcess("sensors -j")
  let j = parseJson(o)
  let temp = j["coretemp-isa-0000"]["Package id 0"]["temp1_input"].getFloat()
  result = fmt"{temp}°C"

proc runJson(): bool =
    echo ","
    echo %*[{"full_text": cpuSpeed()},
            {"full_text": cpuTemp()},
            {"full_text": now().format("dd-MM-yyyy :: HH:mm:ss")}]

proc runTty(): bool =
  let speed = cpuSpeed()
  let temp = cpuTemp()
  let time = now().format("dd-MM-yyyy :: HH:mm:ss")
  echo fmt"{speed} | {temp} | {time}"

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
      
        
