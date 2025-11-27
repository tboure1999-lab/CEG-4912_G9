

Uploading the project on a STM32F429 with a mac: </br>
```  
openocd -f /opt/homebrew/Cellar/open-ocd/0.12.0_1/share/openocd/scripts/board/stm32f429disc1.cfg -c 'program bin/ultrasonic verify reset exit'
