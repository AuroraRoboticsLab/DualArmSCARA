# DualArmSCARA
3D printable parallel SCARA robot arm assembly, ideally evolving into a long-reach printing add-on for our mobile robots.

Built on the AuroraSCAD library from https://github.com/AuroraRoboticsLab/AuroraSCAD

## Printed parts

From gearbox_arm.scad for each of the two steppers you need to print one frame and one reduction gear. 

From torque_arm.scad you need two armReinforced (the large geared arm), two elbow joint, and one set of tool pivots. 


## Non-printed parts

Driven by two NEMA17 stepper motors, and 14 tooth 32 pitch (0.8 module) gears.

Reduction gear axle pin is a 4mm bolt. 

Shoulder axle pin is a 5/16" steel rod.

Elbow axle pins are 8mm aluminum rod. 

Elbow rods are 9.3mm composite rod. 

(FIXME: should collect all the parameters for these non-printed parts, and keep them in one interface.scad so they can be easily changed.)

## Gcode control
Can be driven by Marlin firmware with arm degrees via these gcode commands.
 
Steps per unit is from:
 (200 steps/rev * 21.75 gear ratio * 16 substep * 1 degree / 360 degrees)

Startup gcode:
```
   M92 X193.33 Y193.33 Z1511.79 E519.11
   M203 X100.00 Y100.00 Z8.00 E100.0
   M201 X1000 Y1000 Z100 E5000
   G92 X90 Y90
```
 
Motion is now in degrees of arm movement:
```
   G1 X90 Y90 F600000
   G1 X0 Y0
   G1 X180 Y180
   G1    Y90
   G1 X90 Y0
   G1 X180 Y90
```



