if status is-interactive
    # Commands to run in interactive sessions can go here
end

# Greeting
 
set -U fish_greeting (set_color normal)"✨ Welcome," (set_color green)"linux mint enjoyer!"(set_color normal)



# Show neofetch

if type -q neofetch
	neofetch
end


# Shows the date

echo (set_color yellow)"Today is: "(date "+%A, %B %d, %Y")	

# Adding yazi as an Abbreviations


abbr --add yazi flatpak run io.github.sxyazi.yazi

# Adding Neovim to path

export PATH="$PATH:/opt/nvim-linux-x86_64/bin"

# Adding Abbreviations for Neovim

abbr --add vim nvim
abbr --add vi nvim

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH
