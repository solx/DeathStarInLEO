{{
''***********************************************************************************
''*  Title:                                                                         *
''*  DeathStarDriver.spin                                                           *
''*  With a 3D printed Death Star shell from PongSat Parts (PSP) LLC, you can       *
''*  become Darth Vader and control a fully opertional space station.               *
''*  Author: Blaze Sanders                                                          *
''*  Copyright (c) 2015 PongSat Parts LLC                                           *
''*  See end of file for terms of use.                                              *
''***********************************************************************************
''*  Brief Description:                                                             *
''*  Number of cogs/CPU's used: ?5? out of 8                                        *
''*                                                                                 *   
''*  This code controls the open source hardware of the PSP Death Star station      *
''*  creating a high level API for the control of the following pieces of hardware: *
''*  1) One CMU Camera - VGA resolution (640x480) at 30 fps                         *    
''*  2) Four laser diodes - 850 nm, 1.5 mW and upto 2.5 Gbps                        *
''*  3) Three reaction wheels - Nominal Momentum of 7 mNm-sec @ 4460 RPM            *
''*  4) One Anarean AIR wireless Transceiver - 2.4 GHz @ distances up to 300 meters *
''*  5) ??? solar panels for sun tracking and trickle recharging @ ?? V and ?? mA   *
''*  6) One IMU - 9 axis, 850 Hz with quaternion-based QCOMP AHRS                   *
''*  7) One EMIC2 - Text to voice conversion with custom and 9 static voices types  *                                                              *
''*  8) One S-Band Transceiver - ???                                                *
''*  The Death Star circuit diagram can be found at:                                *
''*  www.???                                                                        * 
''*  The Death Star plans / datasheet can be found at:                              *
''*  www.???                                                                        *
 ''**********************************************************************************                                                        
}}
VAR 'Global variables  

'Stores the number of the cog / CPU running this object (0 to 7) 
byte  cog

'Temporary memory, to hold operational data such as call stacks, parameters and intermediate expression results.
'Use an object like "Stack Length" to determine the optimal length and save memory. http://obex.parallax.com/object/574 
long  DeathStarStackPointer[128]

'Boolean variable that determines wheter debug text is displayed on the Parallax Serial Terminal 
byte DEBUG_MODE

'Boolean variable with the status of Planet Alderan 
byte targetDestoryed

CON 'Global Constants

'----General useful constants---- 
HIGH = 1
LOW = 0

OUTPUT = 1
INPUT = 0
 
'----Propeller pin configuration for Death Star Mark I----

'--I2C bus pins--
I2C_SCL = 28
I2C_SDA = 29


'--CMU Camera hardware pins--
''CAMERA_RX_PIN 
''CAMERA_TX_PIN
''CAMERA_BAUD_RATE


'--Program debugging pins and constants--x`
SURFACE_SERIAL_BUS = 31   'Only usable when Prop Plug is NOT plugged in  
DEBUG_OUTPUT_PIN = 31     'Only usable when Prop Plug is NOT plugged in
DEBUG_INPUT_PIN = 30      'Only usable when Prop Plug is NOT plugged in
DEBUG_BAUD_RATE = 1000000 'Make sure this matches Parallax Serial Terminal setting
LF = 10 'LINE_FEED - Move cursor down one line, but not to the beginning of line
CR = 13 'CARRIAGE_RETURN - Move cursor down one line and to the beginning of line


OBJ 'Additional files you would like imported / included   

'Used to output debugging statments to the Serial Terminal
'Custom PSP file updating http://obex.parallax.com/object/521 
DEBUG            : "GDB-SerialMirror"

'Used to perform color detection, motion detection, and color classification 
TRACKING_CAMERA  : "CMUCamera2"

'Used to control the current and thus power flowing through a OPV300 laser diode
LASER            : "OPV300"

'Used to command & receive telemetry from the Sinclair Interplanetary Picosatellite Reaction Wheel 
REACTION_WHEEL   : "RW-0.007-4"

'Used to collect 9-axis (triaxial gyroscope, accelerometer, and compass sensors) data 
IMU              : "YEI-3Space"

'Used to generate Darth Vader like audio output from text strings
TEXT_TO_VOICE    : "EMIC2"

'Used to stream video and images between Earth dish and LEO 
WIRELESS_SBAND   : "n2420"

'Used to stream video and images between two objects in LEO 
WIRELESS_MESHNET : "AnareanAIR"


PUB Main 'First method called, like in JAVA

''     Action: Initializes all the Death Star hardware and software  
'' Parameters: None                                 
''    Results: Prepares the Death Star for action                   
''+Reads/Uses: None                                               
''    +Writes: None
'' Local Vars: None                                  
''      Calls: ???
''        URL: http://www.solarsystemexpress.com/death-star-in-leo.html

InitializeDeathStar

TEXT_TO_VOICE.Speek(STRING("Luke I'm your father"))

'Fire laser at 100% for 1 second using channel #10
targetDestoryed := LASER.Fire(100, 1, 10)

PRI InitializeDeathStar | OK 'Initializes all the Death Star hardware and firmware     

if (DEBUG_MODE)
  DEBUG.start(DEBUG_OUTPUT_PIN, DEBUG_INPUT_PIN, 0, DEBUG_BAUD_RATE)
  
IMU.Initialize
REACTION_WHEEL.Initialize


TRACKING_CAMERA.CameraPower(TRUE) 
''TRACKING_CAMERA.Start(CAMERA_RX_PIN, CAMERA_TX_PIN, CAMERA_BAUD_RATE)
TRACKING_CAMERA.SetBufferMode(FALSE)
TRACKING_CAMERA.SetFrameRate(30)

TRACKING_CAMERA.GetMean ''Gets the Mean Color for the selected window

PRI Reset

TRACKING_CAMERA.ResetCamera
IMU.ResetIMU
