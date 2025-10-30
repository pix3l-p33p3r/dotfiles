{ pkgs, ... }:
{
  xdg.configFile."rmpc/themes/catppuccin_mocha.ron" = {
    enable = true;
    force = true;
    text = ''
      (
        name: "Catppuccin Mocha",
        foreground: "#cdd6f4",
        background: "#1e1e2e",
        accent:     "#89b4fa",
        selection:  "#313244",
        success:    "#a6e3a1",
        warning:    "#f9e2af",
        error:      "#f38ba8",
      )
    '';
  };

  xdg.configFile."rmpc/notify" = {
    enable = true;
    force = true;
    executable = true;
    text = ''
      #!/usr/bin/env bash
      artist="$1"
      title="$2"
      album="$3"
      if command -v notify-send >/dev/null 2>&1; then
        t="$title"; a="$artist"; b="$album"
        if [[ -z "$t" ]]; then t="Unknown Title"; fi
        if [[ -z "$a" ]]; then a="Unknown Artist"; fi
        if [[ -z "$b" ]]; then b="Unknown Album"; fi
        notify-send -a rmpc "$t" "$a — $b" -i audio-x-generic
      fi
    '';
  };

  xdg.configFile."rmpc/increment_play_count" = {
    enable = true;
    force = true;
    executable = true;
    text = ''
      #!/usr/bin/env bash
      artist="$1"; title="$2"; album="$3"; file="$4"; elapsed_ms="$5"; duration_ms="$6"; state="$7"
      log_dir="$HOME/.local/state/rmpc"
      mkdir -p "$log_dir"
      log_file="$log_dir/play.log"
      printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$(date -Is)" "$artist" "$title" "$album" "$file" "$elapsed_ms" "$duration_ms" >> "$log_file"
    '';
  };

  home.file.".local/bin/tag_music.sh" = {
    enable = true;
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -eo pipefail
      if ! command -v eyeD3 >/dev/null 2>&1; then
        echo "eyeD3 is required. Install python3Packages.eyed3."
        exit 1
      fi
      ARTIST=""''${ARTIST-}
      ALBUM=""''${ALBUM-}
      DIR=""''${DIR-}"."
      if [[ -z "$ARTIST" || -z "$ALBUM" ]]; then
        echo "Usage: ARTIST=... ALBUM=... DIR=path $0"
        exit 1
      fi
      shopt -s nullglob
      for f in "$DIR"/*.mp3; do
        eyeD3 --artist "$ARTIST" --album "$ALBUM" "$f" >/dev/null
      done
    '';
  };

  home.file.".local/bin/tag_genres.sh" = {
    enable = true;
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -eo pipefail
      if ! command -v eyeD3 >/dev/null 2>&1; then
        echo "eyeD3 is required. Install python3Packages.eyed3."
        exit 1
      fi
      dir="$1"; if [[ -z "$dir" ]]; then dir="."; fi
      for f in "$dir"/*.mp3; do
        read -rp "Genres for '$f' (e.g. Electronic;House): " GENRES
        eyeD3 --genre "$GENRES" "$f" >/dev/null
      done
    '';
  };

  home.file.".local/bin/fetch_album_lyrics.sh" = {
    enable = true;
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail
      dir="$1"; if [[ -z "$dir" ]]; then dir="."; fi
      for f in "$dir"/*.mp3; do
        base="$(basename "$f" .mp3)"
        out="$(dirname "$f")/$base.lrc"
        if [[ -f "$out" ]]; then continue; fi
        echo "; TODO: fetch lyrics for '$f'" > "$out"
      done
    '';
  };

  home.file.".local/bin/inspect_log.sh" = {
    enable = true;
    executable = true;
    text = ''
      #!/usr/bin/env bash
      log_file="$HOME/.local/state/rmpc/play.log"
      if [[ ! -f "$log_file" ]]; then
        echo "No log found at $log_file"
        exit 0
      fi
      column -t -s $'\t' "$log_file" | less -S
    '';
  };
  xdg.configFile."rmpc/config.ron" = {
    enable = true;
    force = true;
    text = ''
      #![enable(implicit_some)]
      #![enable(unwrap_newtypes)]
      #![enable(unwrap_variant_newtypes)]
      (
          address: "127.0.0.1:6600",
          password: None,
          theme: Some("catppuccin_mocha"),
          cache_dir: None,
          on_song_change: Some([
            (path: "$HOME/.config/rmpc/notify", args: []),
            (path: "$HOME/.config/rmpc/increment_play_count", args: []),
          ]),
          volume_step: 5,
          max_fps: 30,
          scrolloff: 0,
          wrap_navigation: false,
          enable_mouse: true,
          enable_config_hot_reload: true,
          status_update_interval_ms: 1000,
          rewind_to_start_sec: None,
          reflect_changes_to_playlist: false,
          select_current_song_on_change: false,
          browser_song_sort: [Disc, Track, Artist, Title],
          directories_sort: SortFormat(group_by_type: true, reverse: false),
          album_art: (
              method: Auto,
              max_size_px: (width: 1200, height: 1200),
              disabled_protocols: ["http://", "https://"],
              vertical_align: Center,
              horizontal_align: Center,
          ),
          keybinds: (
              global: {
                  ":":       CommandMode,
                  ",":       VolumeDown,
                  "s":       Stop,
                  ".":       VolumeUp,
                  "<Tab>":   NextTab,
                  "<S-Tab>": PreviousTab,
                  "1":       SwitchToTab("Queue"),
                  "2":       SwitchToTab("Directories"),
                  "3":       SwitchToTab("Artists"),
                  "4":       SwitchToTab("Album Artists"),
                  "5":       SwitchToTab("Albums"),
                  "6":       SwitchToTab("Playlists"),
                  "7":       SwitchToTab("Search"),
                  "q":       Quit,
                  ">":       NextTrack,
                  "p":       TogglePause,
                  "<":       PreviousTrack,
                  "f":       SeekForward,
                  "z":       ToggleRepeat,
                  "x":       ToggleRandom,
                  "c":       ToggleConsume,
                  "v":       ToggleSingle,
                  "b":       SeekBack,
                  "~":       ShowHelp,
                  "u":       Update,
                  "U":       Rescan,
                  "I":       ShowCurrentSongInfo,
                  "O":       ShowOutputs,
                  "P":       ShowDecoders,
                  "R":       AddRandom,
              },
              navigation: {
                  "k":         Up,
                  "j":         Down,
                  "h":         Left,
                  "l":         Right,
                  "<Up>":      Up,
                  "<Down>":    Down,
                  "<Left>":    Left,
                  "<Right>":   Right,
                  "<C-k>":     PaneUp,
                  "<C-j>":     PaneDown,
                  "<C-h>":     PaneLeft,
                  "<C-l>":     PaneRight,
                  "<C-u>":     UpHalf,
                  "N":         PreviousResult,
                  "a":         Add,
                  "A":         AddAll,
                  "r":         Rename,
                  "n":         NextResult,
                  "g":         Top,
                  "<Space>":   Select,
                  "<C-Space>": InvertSelection,
                  "G":         Bottom,
                  "<CR>":      Confirm,
                  "i":         FocusInput,
                  "J":         MoveDown,
                  "<C-d>":     DownHalf,
                  "/":         EnterSearch,
                  "<C-c>":     Close,
                  "<Esc>":     Close,
                  "K":         MoveUp,
                  "D":         Delete,
                  "B":         ShowInfo,
              },
              queue: {
                  "D":       DeleteAll,
                  "<CR>":    Play,
                  "<C-s>":   Save,
                  "a":       AddToPlaylist,
                  "d":       Delete,
                  "C":       JumpToCurrent,
                  "X":       Shuffle,
              },
          ),
          search: (
              case_sensitive: false,
              mode: Contains,
              tags: [
                  (value: "any",         label: "Any Tag"),
                  (value: "artist",      label: "Artist"),
                  (value: "album",       label: "Album"),
                  (value: "albumartist", label: "Album Artist"),
                  (value: "title",       label: "Title"),
                  (value: "filename",    label: "Filename"),
                  (value: "genre",       label: "Genre"),
              ],
          ),
          artists: (
              album_display_mode: SplitByDate,
              album_sort_by: Date,
          ),
          tabs: [
              (
                  name: "Queue",
                  pane: Split(
                      direction: Horizontal,
                      panes: [(size: "40%", pane: Pane(AlbumArt)), (size: "60%", pane: Pane(Queue))],
                  ),
              ),
              (
                  name: "Lyrics",
                  pane: Pane(Lyrics),
              ),
              (
                  name: "Directories",
                  pane: Pane(Directories),
              ),
              (
                  name: "Artists",
                  pane: Pane(Artists),
              ),
              (
                  name: "Album Artists",
                  pane: Pane(AlbumArtists),
              ),
              (
                  name: "Albums",
                  pane: Pane(Albums),
              ),
              (
                  name: "Playlists",
                  pane: Pane(Playlists),
              ),
              (
                  name: "Search",
                  pane: Pane(Search),
              ),
          ],
      )
    '';
  };
}


