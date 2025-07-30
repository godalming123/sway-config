#!/bin/env nu
let gammastepProcesses = (ps | where $it.name == "gammastep")
if ($gammastepProcesses | length) > 0 {
  $gammastepProcesses | each {|proc| kill $proc.pid}
} else {
  gammastep -m wayland -O 3500 -b 0.3
}
