@ECHO OFF
"C:\Program Files (x86)\Atmel\AVR Tools\AvrAssembler2\avrasm2.exe" -S "D:\avr\labels.tmp" -fI -W+ie -o "D:\avr\Test.hex" -d "D:\avr\Test.obj" -e "D:\avr\Test.eep" -m "D:\avr\Test.map" "D:\avr\Test.asm"
