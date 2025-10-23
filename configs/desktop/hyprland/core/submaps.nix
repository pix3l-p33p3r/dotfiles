{ variables, ... }:
let
  inherit (variables) snapfull snaparea hyprctl;
in
''
  bind=ALT, p, submap, snapshot

  submap=snapshot
  bind=, f, exec, ${snapfull} && ${hyprctl} dispatch submap reset
  bind=, a, exec, ${snaparea} && ${hyprctl} dispatch submap reset
  bind=, escape, submap, reset 
  submap=reset


  bind=ALT, r, submap, resize

  submap=resize
  binde=, $right, resizeactive,15 0
  binde=, $left, resizeactive,-15 0
  binde=, $up, resizeactive,0 -15
  binde=, $down, resizeactive,0 15
  bind=, escape, submap, reset 
  submap=reset

  bind=ALT, m, submap, move

  submap=move
  binde=, $right, moveactive,20 0
  binde=, $left, moveactive,-20 0
  binde=, $up, moveactive,0 -20
  binde=, $down, moveactive,0 20
  bind=, escape, submap, reset 
  submap=reset



  env = QT_AUTO_SCREEN_SCALE_FACTOR,2
  env = QT_QPA_PLATFORM,wayland;xcb
  env = QT_WAYLAND_DISABLE_WINDOWDECORATION,1
  env = QT_QPA_PLATFORMTHEME,qt5ct

  env = GDK_BACKEND,wayland,x11,*
  env = QT_QPA_PLATFORM,wayland;xcb
  env = SDL_VIDEODRIVER,wayland
  env = CLUTTER_BACKEND,wayland

  decoration:blur:enabled = false
  decoration:shadow:enabled = false
  misc:vfr = true
''
