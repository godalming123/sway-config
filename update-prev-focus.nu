#!/bin/nu

mut terminal_ids = []
mut browser_ids = []

while true {
  let event = ^swaymsg -t subscribe '["window"]' | from json
  # A close window event still says that the window is focused
  if ($event | get change) != "close" and ($event | get container.focused) == true {
    let id = $event | get container.id

    # Avoid duplicate items being in the id lists
    $terminal_ids = $terminal_ids | filter {|e| $e != $id}
    $browser_ids = $browser_ids | filter {|e| $e != $id}

    # If there are any items left in the lists, then they must be the previously focused
    # items, since we have just removed the currently focused item
    if ($terminal_ids | length) > 0 {
      swaymsg $"[con_id=($terminal_ids.0)] mark --add _prev_terminal"
    }
    if ($browser_ids | length) > 0 {
      swaymsg $"[con_id=($browser_ids.0)] mark --add _prev_browser"
    }

    # Add the currently focused item to one of the lists if it is a browser or
    # terminal
    match ($event | get conatiner.app_id) {
      # TODO: This does not work for xwayland apps
      "com.mitchellh.ghostty"|"Alacritty"|"org.gnome.Terminal"|"foot" => {
        $terminal_ids = $terminal_ids | prepend $id
      },
      "qutebrowser"|"zen"|"org.mozilla.firefox"|"org.gnome.Epiphany"|
        "chromium-browser" => {
        $browser_ids = $browser_ids | prepend $id
      }
    }
  }
}
