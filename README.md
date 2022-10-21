# conky-rice
<p align="center">
  <table>
        <tr>
          <td><img src="https://github.com/TanawatJukmongkol/conky-rice/blob/f78ca6e52726d9a6ca2936aa55b68ac665bd657d/conky.gif" width="270"></td>
          <td><img src="https://github.com/TanawatJukmongkol/conky-rice/blob/10291b51d1846136f86d03ec80814cfb8fcfacc7/assets/desktop.png"></td>
        </tr>
  </table>
</p>
<table>
  <tr>
    <td>
      <h1> How to install: </h1>
      <ul>
        <li> open the terminal, copy and paste. </li>
        <li>
          <code>cd $HOME</code>
        </li>
        <li>
          <code>sudo apt install conky-all libcairo-dev lm-sensors</code>
        </li>
        <li>
          <code>git clone https://github.com/TanawatJukmongkol/conky-rice.git .conky</code>
        </li>
        <li>
          <code>ln -s ~/.conky/.conkyrc ~/.conkyrc</code>
        </li>
        <h2> download the fonts, unzip it, and install it. </h2>
        <ul>
          <li> https://fonts.google.com/noto/specimen/Noto+Sans+JP </li>
          <li> https://github.com/source-foundry/Hack </li>
          <li> https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/AnonymousPro/complete/Anonymice%20Nerd%20Font%20Complete%20Mono.ttf </li>
        </ul>
        <h2> Reload font cache: </h2>
        <ul>
          <li>
            <code>fc-cache -rf</code>
          </li>
          <li> Run conky, and set it as startup application with <code>conky -d --pause=3</code>
          </li>
        </ul>
      </ul>
      <h1> How to install manually: </h1>
      <ul>
        <li> Install dependencies: <code>conky libcairo libcairo-dev lm-sensors</code> (or the <code>conky-all</code> meta package on Debian based systems) and your fonts of choice (Mine's Hack Anonymice for Powerline). </li>
        <li> Download the zip file using the green button with the label <code>code</code> (or clone it using git command). </li>
        <li> Unzip it and then move the contents into <code>.conky</code> in the home dirrectory (create one if you don't have). </li>
        <li> Open the terminal and run <code>ln -s ~/.conky/.conkyrc ~/.conkyrc</code>. </li>
        <li> Change the font inside the <code>~/.conkyrc</code> and or <code>~/.dashboard.lua</code> to your font of choice. </li>
        <li> Run conky (may need to change some fonts in the config file, if not displayed correctly). </li>
      </ul>
    </td>
  </tr>
</table>
