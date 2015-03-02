{{
''***********************************************************************************
''*  Title:                                                                         *
''*  EMIC2.spin                                                                     *
''*  The object creates high-quality speech synthesis for English & Spanish         * 
''*  Author: Blaze Sanders [blaze.sanders@solarsystemexpress.com]                   *
''*  Copyright (c) 2015 PongSat Parts LLC                                           *
''*  See end of file for terms of use.                                              *
''***********************************************************************************
''*  Brief Description:                                                             *
''*  Number of cogs/CPU's used: 1 out of 8                                          *
''*                                                                                 *   
''*  This code controls the open source hardware of the EMIC2 Text to Voice         *
''*  multi-language voice synthesizer that converts a stream of digital text into   *
''*  natural sounding speech. Please refer to the Emic 2 product manual for full    *
''*  details of functionality and capabilities.                                     *   
''*                                                                                 * 
''*  EMIC 2 circuit diagram can be found at:                                        *
''*  www.???                                                                        *

SIN     ────── P6
SOUT    ────── P7
VCC     ────── +5V (VDD)
GND     ──────┐
               
              GND (VSS)

              
''*  EMIC 2 datasheets can be found at:                                             *
''*  http://www.parallax.com/product/30016                                          *
''*                                                                                 *  
''*  Based off the EMIC2_Demo file by Joe Grand of Grandidea Studio                 *
''*  http://www.grandideastudio.com/portfolio/emic-2-text-to-speech-module/         *
''*  Revisions:                                                                     *
''*  - Mark I (March 15, 2012): Initial release                                     * 
 ''**********************************************************************************                                                        
}}

CON 'Global Constants

DARTH_VADER = 0
LUKE_SKYWALKER = 1
PRINCESS_LEIA = 2
HAN_SOLO = 3
 
VAR

'Boolean variable that determines wheter debug text is displayed on the Parallax Serial Terminal 
byte DEBUG_MODE

'Temporary memory, to hold operational data such as call stacks, parameters and intermediate expression results.
'Use an object like "Stack Length" to determine the optimal length and save memory. http://obex.parallax.com/object/574 
long EMIC2StackPointer[100] 
    
OBJ
PST      : "Parallax Serial Terminal"                   ' Debug Terminal
DEBUG    : "GDB-SerialMirror"                           ' Full Duplex Serial

'Use instead of DEBBUG serial    : "FullDuplexSerial"                           ' Full Duplex Serial  
  
PUB Initialize(voice, EMIC_RX, EMIC_TX)

'PST.Start(DEBUG_BAUD_RATE)   ' Set Parallax Serial Terminal to 115.2 kBPS          
PST.Str(@InitHeader)          ' Print header; uses string in DAT section.

'Set-up serial port for communication with the Emic 2 in normal mode at 9600 BPS
DEBUG.Start(EMIC_RX, EMIC_TX, %0000, 9_600)

{{
   When the Emic 2 powers on, it takes about 3 seconds for it to successfully
   intialize. It then sends a ":" character to indicate it's ready to accept
   commands. If the Emic 2 is already initialized, a CR will also cause it
   to send a ":"
}}

PST.Str(String("Waiting for Emic 2..."))
DEBUG.TX(PST#NL)                                     ' Send a CR in case the system is already up
repeat until serial.RxCheck == ":"                   ' When the Emic 2 has initialized and is ready, it will send a single ':' character, so wait here until we receive it
PST.Str(String("Ready!", PST#NL))

waitcnt(clkfreq / 100 + cnt)                          ' Delay 10mS
DEBUG.RxFlush                                        ' Flush the receive buffer
 
SetVoice(voice)

Stop

return (cog := cognew(Speek, @EMIC2StackPointer)+1)

PUB Stop                                                '' Stop the cogs
  if cog
    ser.Stop
    cogstop(cog~ - 1)

PUB Speek


PUB SpeekStoredQuote(quoteNumber)

' Send string to convert to speech (stored in the DAT section below) 
case quoteNumber
  0: 'Darth Vader "I find your lack of faith disturbing"  
     DEBUG.Str(@Vader0)     
  1: 'Darth Vader "No Luke I am your father"
     DEBUG.Str(@Vader1)    
  2: 'Darth Vader "The ability to destroy a planet is insignificant next to the power of the force"           
     DEBUG.Str(@Vader2   
  3: 'Darth Vader "You underestimate the power of the dark side"
     DEBUG.Str(@Vader3) 

' Wait here until the Emic 2 responds with a ":" indicating it's ready to accept the next command 
DEBUG.TX(PST#NL)
repeat until serial.RxCheck == ":"
PST.Str(String("Done!", PST#NL))
waitcnt(clkfreq >> 1 + cnt)        ' Delay 1/2 second   


PUB SpeekStoredSoundFile(fileNumber)
    
PRI SetVoice(voice)


case voice
  0: 'Darth Vader 
                
    'Stop 
  1: 'Luke Sky Walker 
      
    'Stop     
  2: 'Princess Leia

  3: 'Han Solo     

PRI UnitTest

PST.Str(String("Waiting for Emic 2..."))
DEBUG.TX(PST#NL)                                     ' Send a CR in case the system is already up
repeat until serial.RxCheck == ":"                   ' When the Emic 2 has initialized and is ready, it will send a single ':' character, so wait here until we receive it
PST.Str(String("Ready!", PST#NL))   

waitcnt(clkfreq / 100 + cnt)                          ' Delay 10mS
DEBUG.RxFlush                                        ' Flush the receive buffer

PST.Str(String("Speaking some text..."))
DEBUG.TX("S")
DEBUG.Str(@TextString)                               ' Send the desired string to convert to speech (stored in the DAT section below)
DEBUG.TX(PST#NL)
repeat until serial.RxCheck == ":"                    ' Wait here until the Emic 2 responds with a ":" indicating it's ready to accept the next command
PST.Str(String("Done!", PST#NL))  

waitcnt(clkfreq >> 1 + cnt)                           ' Delay 1/2 second

PST.Str(String("Singing a song..."))
DEBUG.Str(String("D1", PST#NL))                      ' Play the built-in demonstration song. See the product manual for exact settings used to create this song.
repeat until serial.RxCheck == ":"                    ' Wait here until the Emic 2 responds with a ":" indicating it's ready to accept the next command
PST.Str(String("Done!", PST#NL))
 
DAT
InitHeader    byte "Emic 2 Text-to-Speech Module starting up", PST#NL, PST#NL, 0
Vader0        byte "I find your lack of faith disturbing", 0
Vader1        byte "No Luke I am your father", 0
Vader2        byte "The ability to destroy a planet is insignificant next to the power of the force", 0
Vader3        byte "You underestimate the power of the dark side", 0


{{
┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                   TERMS OF USE: MIT License                                                  │                                                            
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    │ 
│files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,    │
│modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software│
│is furnished to do so, subject to the following conditions:                                                                   │
│                                                                                                                              │
│The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.│
│                                                                                                                              │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          │
│WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         │
│COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   │
│ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
}}     


PUB Initialize | OK


PUB Speek(StringPTR)