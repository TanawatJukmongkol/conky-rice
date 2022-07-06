# conky-rice
my custom lua conky widget rice.

# How to install:
  1. Open the terminal, copy and paste.
  ```
  cd $HOME
  sudo apt install conky-all libcairo-dev lm-sensors
  git clone https://github.com/TanawatJukmongkol/conky-rice.git .conky
  ln -s ~/.conky/.conkyrc ~/.conkyrc
  ```
  2. Download the fonts, unzip it, and install it.
  ```
  Download the fonts listed here:
    https://fonts.google.com/noto/specimen/Noto+Sans+JP
    https://github.com/source-foundry/Hack
    https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/AnonymousPro/complete/Anonymice%20Nerd%20Font%20Complete%20Mono.ttf
  ```
  3. Reload font cache:
  `fc-cache -rf`
  4. Run conky, and set it as startup application with `conky -d --pause=3`
# How to install manually:
  0. Install `conky, libcairo, libcairo-dev, lm-sensors` (or the conky-all meta package on Debian based systems)
     and your fonts of choice (Mine's Hack Anonymice for Powerline).
  1. Download the zip file using the green button with the label `code` (or clone it using git command).
  2. Unzip it and then move the contents into `.conky` in the home dirrectory (create one if you don't have).
  3. Open the terminal and run `ln -s ~/.conky/.conkyrc ~/.conkyrc`.
  4. Change the font inside the ~/.conkyrc and or ~/.dashboard.lua to your font of choice.
  5. Run conky (may need to change some fonts in the config file, if not displayed correctly).
