# "agkozak/agkozak-zsh-prompt"
AGKOZAK_MULTILINE=0
AGKOZAK_LEFT_PROMPT_ONLY=1
AGKOZAK_PROMPT_DIRTRIM=2
AGKOZAK_BLANK_LINES=1
AGKOZAK_SHOW_STASH=1
AGKOZAK_SHOW_BG=1
AGKOZAK_BG_STRING='j'

# Catppuccin Mocha Colors for agkozak prompt
# Using terminal color numbers that match Catppuccin Mocha
AGKOZAK_COLORS_EXIT_STATUS=red          # color1: #f38ba8 (red)
AGKOZAK_COLORS_USER_HOST=blue           # color4: #89b4fa (blue)
AGKOZAK_COLORS_PATH=green               # color2: #a6e3a1 (green)
AGKOZAK_COLORS_BRANCH_STATUS=yellow     # color3: #f9e2af (yellow)
AGKOZAK_COLORS_PROMPT_CHAR=white        # color7: #bac2de (white/foreground)
AGKOZAK_COLORS_CMD_EXEC_TIME=cyan       # color6: #94e2d5 (teal)
AGKOZAK_COLORS_VIRTUALENV=magenta       # color5: #cba6f7 (mauve)
AGKOZAK_COLORS_BG_STRING=magenta        # color5: #cba6f7 (mauve)

# Additional agkozak customization for better Catppuccin integration
AGKOZAK_PROMPT_CHAR='❯'               # Modern prompt character
AGKOZAK_PROMPT_CHAR_OK='❯'            # Success prompt character
AGKOZAK_PROMPT_CHAR_FAIL='✗'          # Error prompt character
AGKOZAK_SHOW_EXIT_STATUS=1             # Show exit status
AGKOZAK_SHOW_EXEC_TIME=1               # Show command execution time
AGKOZAK_EXEC_TIME_THRESHOLD=3          # Show time for commands > 3 seconds


# "zsh-users/zsh-history-substring-search"
# Catppuccin Mocha colors for history search
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='bg=transparent,fg=green,bold'    # color2: #a6e3a1
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND='bg=transparent,fg=red,bold'  # color1: #f38ba8
HISTORY_SUBSTRING_SEARCH_FUZZY=1
HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1
HISTORY_SUBSTRING_SEARCH_PREFIXED=1

# "zsh-users/zsh-autosuggestions"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
