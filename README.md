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


