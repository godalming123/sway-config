#!/bin/env nu

def get_window_type [container] {
  match $container.app_id {
    "com.mitchellh.ghostty"|"Alacritty"|"org.gnome.Terminal"|"foot" => {return "terminal"}
    "org.qutebrowser.qutebrowser"|"zen"|"org.mozilla.firefox"|"org.gnome.Epiphany"|"chromium-browser" => {return "web_browser"}
  }
  match $container.window_properties?.class? {
    "Chromium-browser" => {return "web_browser"}
  }
  match $container.name {
    "gf2" => "debugger"
    _ => "other"
  }
}

swaymsg -m -t subscribe '["window"]' | lines | reduce --fold [] {
  |line recently_used_windows|
  let event = $line | from json

  # Set $out (the recently used windows for the next iteration of reduce)
  let window_details = {
    id: $event.container.id,
    type: (get_window_type $event.container),
  }
  let out = match $event.change {
    # See the window section of the events section of the `man 7 sway-ipc`
    # command output for a full list of events.
    "new"   => ($recently_used_windows | prepend $window_details)
    "close" => ($recently_used_windows | filter {|e| $e.id != $event.container.id})
    "focus" => ($recently_used_windows | filter {|e| $e.id != $event.container.id} | prepend $window_details)
    _       => {return $recently_used_windows}
  }

  # Set the _prev flags based on $out
  $out | skip 1 | (reduce --fold [] {|window, handled_types|
    if $window.type in $handled_types { $handled_types } else {
      swaymsg $"[con_id=($window.id)] mark --add _prev_($window.type)"
      $handled_types | append $window.type
    }
  })

  # Return $out (the recently used windows for the next iteration of reduce)
  return $out
}
