### For ideas
# https://github.com/h-michael/dotfiles/tree/a6642d1903da78bca55ae1bd74a91a6075a99383/.config/fish/conf.d

# This is a hack to prevent this file from being sourced twice
if not status is-interactive
    exit
end

# -l, --local: available only to the innermost block
# -g, --global: available outside blocks and by other functions
# -U, --universal: shared between all fish sessions and persisted across restarts of the shell
# -x, --export: available to any child process spawned in the current session

function check_cli_tools
    # Map tool commands to package names
    set -l tool_packages \
        fzf:fzf \
        fd:fd \
        bat:bat \
        rg:ripgrep \
        eza:eza \
        git:git \
        nvim:neovim

    set -l missing_packages

    # Check each tool
    for item in $tool_packages
        set -l parts (string split : $item)
        set -l tool $parts[1]
        set -l package $parts[2]

        if not type -q $tool
            set -a missing_packages $package
        end
    end

    # If tools are missing, prompt to install
    if test (count $missing_packages) -gt 0
        echo "Missing CLI tools. Packages needed: $missing_packages"
        read -l -P "Install with 'sudo pacman -S $missing_packages'? [y/N] " confirm

        if test "$confirm" = y -o "$confirm" = Y
            sudo pacman -S $missing_packages
        end
    end
end

function setup_environment
    set -gx SHELL (command -s fish)
    set -gx PAGER (command -s less)
    if command --query nvim
        set -gx EDITOR (command -s nvim)
        set -gx VISUAL (command -s nvim)
        set -gx MANPAGER (command -s nvim) +Man!
    else
        set -gx EDITOR (command -s vi)
        set -gx VISUAL (command -s vi)
        set -gx MANPAGER (command -s less)
    end

    set -gx GOPATH "$HOME/dev/golang/go"
    set -gx PATH "$GOPATH/bin" "$PATH"

    set -gx ZK_NOTEBOOK_DIR "$HOME/zk"
end

function setup_fish
    set -g fish_greeting
    set -g fish_prompt_pwd_dir_length 0
    set -g fish_cursor_unknown block
    set -g fish_cursor_default block
    set -g fish_cursor_normal block
    set -g fish_cursor_visual block
    set -g fish_cursor_insert line
    set -g fish_cursor_replace_one underscore
end

function setup_colorscheme_tokio_nigth_night
    # https://github.com/folke/tokyonight.nvim/blob/main/extras/fish/tokyonight_night.fish
    # TokyoNight Color Palette
    set -l foreground c0caf5
    set -l selection 283457
    set -l comment 565f89
    set -l red f7768e
    set -l orange ff9e64
    set -l yellow e0af68
    set -l green 9ece6a
    set -l purple 9d7cd8
    set -l cyan 7dcfff
    set -l pink bb9af7

    # Syntax Highlighting Colors
    set -g fish_color_normal $foreground
    set -g fish_color_command $cyan
    set -g fish_color_keyword $pink
    set -g fish_color_quote $yellow
    set -g fish_color_redirection $foreground
    set -g fish_color_end $orange
    set -g fish_color_option $pink
    set -g fish_color_error $red
    set -g fish_color_param $purple
    set -g fish_color_comment $comment
    set -g fish_color_selection --background=$selection
    set -g fish_color_search_match --background=$selection
    set -g fish_color_operator $green
    set -g fish_color_escape $pink
    set -g fish_color_autosuggestion $comment

    # Completion Pager Colors
    set -g fish_pager_color_progress $comment
    set -g fish_pager_color_prefix $cyan
    set -g fish_pager_color_completion $foreground
    set -g fish_pager_color_description $comment
    set -g fish_pager_color_selected_background --background=$selection

end

function setup_locale
    # https://wiki.archlinux.org/title/locale
    # British like a 24hours!!!
    set -l LANGUAGE "en_GB.UTF-8"
    set -gx LANG "$LANGUAGE"
    set -gx LC_ALL "$LANGUAGE"
    set -gx LC_CTYPE "$LANGUAGE"
    set -gx LC_TIME "$LANGUAGE"
end

function setup_git
    set -gx GIT_EDITOR $EDITOR
    git config --global user.email "sergey.docenko@gmail.com"
    git config --global user.name "Sergii Dotsenko"
    git config --global core.editor nvim
end

function setup_ssh
    set -l SSH_DITHUB_KEY "$HOME/.ssh/github"
    if not pgrep --full ssh-agent | string collect >/dev/null
        eval (ssh-agent -c) >/dev/null
        ssh-add -D >/dev/null 2>&1
        ssh-add "$SSH_DITHUB_KEY" >/dev/null 2>&1
        set -gx SSH_AGENT_PID $SSH_AGENT_PID
        set -gx SSH_AUTH_SOCK $SSH_AUTH_SOCK
    end
end

function setup_aliases
    if type -q exa
        set -l exa_command "exa --header --git --time-style=iso --modified --created"
        alias l="$exa_command"
        alias ls="$exa_command --icons"
        alias ll="$exa_command --icons --long"
        alias la="$exa_command --icons --long --all"
        alias lt="$exa_command --icons --tree --git-ignore"
        alias llt="$exa_command --icons --tree --long"
        alias lat="$exa_command --icons --tree --long --all"
    end
    if type -q helix
        alias hx="helix"
    end
end

function setup_fzf
    if not type -q fzf
        echo "Error: fzf not installed"
        exit
    end
    set -l PREVIEWCMD "cat {}"
    if type -q bat
        set PREVIEWCMD "bat --color=always --style=plain --line-range :500 {}"
    else
        echo "'bat' not installed, fallback to 'cat'..."
    end
    set -l PREVIEWWINDOW sharp
    set -l KEYBINDS "alt-j:down,alt-k:up"
    set -l KEYBINDS "$KEYBINDS,ctrl-u:preview-half-page-up,ctrl-d:preview-half-page-down"
    set -l EXCLUDE_PATTERN ".cache,.cargo,.local,.git,.vscode,node_modules,.mozzila"
    set -gx FZF_DEFAULT_COMMAND "fd . --hidden --exclude={$EXCLUDE_PATTERN}"
    set -gx FZF_DEFAULT_OPTS "--bind '$KEYBINDS' --preview '$PREVIEWCMD' --preview-window '$PREVIEWWINDOW'"

    function fzf_history
        set current_cmd (commandline)
        set cmd (history | fzf --query "$current_cmd" --preview-window 'up:50%:wrap:hidden' --bind "alt-j:down,alt-k:up")

        if test -z "$cmd"
            commandline -f repaint
            return
        end

        commandline "$cmd"
        commandline -f repaint
        commandline -C (string length -- "$cmd")
    end

    # bind -M insert \ec fzf_history
    # bind \ec fzf_history

    bind -M insert \e\r fzf_history
    bind \e\r fzf_history
end

function setup_keybinds
    bind \ev edit_command_buffer
end

function setup_zoxide
    if type -q zoxide
        set -gx _ZO_FZF_OPTS "--bind 'alt-j:down,alt-k:up'"
        zoxide init fish | source
        zoxide init --cmd cd fish | source

        function zr
            set -l _zoxide_result (zoxide query -i -- $argv)
            and zoxide remove $_zoxide_result
        end

        function _zoxide_with_query
            set -l query $argv[2..-1]
            set -l func $argv[1]
            set -gx _ZO_FZF_OPTS "--bind 'alt-j:down,alt-k:up' --query='$query'"
            eval $func
            set -gx _ZO_FZF_OPTS "--bind 'alt-j:down,alt-k:up'"
            commandline ""
            commandline -f repaint
        end

        bind -M insert \ec 'set -l cmd (commandline); _zoxide_with_query zi $cmd; commandline -f repaint'
        bind \ec 'set -l cmd (commandline); _zoxide_with_query zi $cmd; commandline -f repaint'

        bind -M insert \eC 'set -l cmd (commandline); _zoxide_with_query zr $cmd; commandline -f repaint'
        bind \eC 'set -l cmd (commandline); _zoxide_with_query zr $cmd; commandline -f repaint'
    else
        echo "zoxide not installed..."
    end
end

function setup_lazygit
    if type -q lazygit
        bind -M insert \eg lazygit
        bind \eg lazygit
    end
end

setup_environment
setup_fish
setup_colorscheme_tokio_nigth_night
setup_locale
check_cli_tools
setup_git
setup_ssh
setup_aliases
setup_keybinds
setup_fzf
setup_zoxide
setup_lazygit