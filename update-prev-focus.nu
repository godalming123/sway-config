#!/bin/nu

mut recently_used_windows = []

def get_window_type [app_id] {
  match $app_id {
    "com.mitchellh.ghostty"|"Alacritty"|"org.gnome.Terminal"|"foot" => "terminal"
    "qutebrowser"|"zen"|"org.mozilla.firefox"|"org.gnome.Epiphany"|"chromium-browser" => "browser"
    _ => "other"
  }
}

while true {
  # Setup variables
  let event = ^swaymsg -t subscribe '["window"]' | from json
  let id = $event | get container.id
  let window_details = {
    id: $id,
    type: (get_window_type ($event | get container.app_id)),
  }

  # Update $recently_used_windows
  $recently_used_windows = match ($event | get change) {
    "title"|"mark" => {continue}
    "close" => ($recently_used_windows | filter {|e| $e.id != $id})
    "focus" => ($recently_used_windows | filter {|e| $e.id != $id} | prepend $window_details)
    "new"   => ($recently_used_windows | prepend $window_details)
  }

  # Set the _prev flags based on $recently_used_windows
  $recently_used_windows | skip 1 | (reduce --fold [] {|window, accumulator| 
    if ($accumulator | filter {|type| $type == $window.type} | length) > 0 {
      $accumulator
    } else {
      swaymsg $"[con_id=($window.id)] mark --add _prev_($window.type)"
      $accumulator | append $window.type
    }
  })
}
