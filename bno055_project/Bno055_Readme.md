run on command on mac to flash the card: 
openocd -f /opt/homebrew/Cellar/open-ocd/0.12.0_1/share/openocd/scripts/board/stm32f429disc1.cfg -c 'program bin/main verify reset exit'
