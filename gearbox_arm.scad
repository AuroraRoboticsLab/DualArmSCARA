/*
 Gearbox that holds a NEMA 17 stepper motor, and bolts to a robot arm joint.
 
 Can be driven by Marlin firmware with arm degrees via:
 
 Steps per unit is from:
 (200 steps/rev * 21.75 gear ratio * 16 substep * 1 degree / 360 degrees)

 Startup gcode:
   M92 X193.33 Y193.33 Z1511.79 E519.11
   M203 X100.00 Y100.00 Z8.00 E100.0
   M201 X1000 Y1000 Z100 E5000
   G92 X90 Y90
 
 Motion:
   G1 X90 Y90 F600000
   G1 X0 Y0
   G1 X180 Y180
   G1    Y90
   G1 X90 Y0
   G1 X180 Y90
 
*/
include <AuroraSCAD/gearbox.scad>; // https://github.com/AuroraRoboticsLab/AuroraSCAD
include <AuroraSCAD/motor.scad>;

inch=25.4; // file units are mm

axleOD=5/16*inch;

gearbox = gearbox_create(
    // Geartypes for each stage
    [ geartype_create(1.75,10), /* geartype_create(1.25,8), */ geartype_create(inch/32,10) ],

    // Tooth counts for big and little gears at each stage
    [ [ -42, 8 ], [ 58, 14 ] ], // [58, 14] ],
     
    // Angles between each stage
    [ 0, 90, 90 ],
    
    // axleODs: thru-gear axle diameters for the big gear of each stage
    [ axleOD, 4.0, 4.0 ],
    
    // Thru-frame hole diameters at each stage (here, for tapped threads)
    [ axleOD, 3.6, 3.6 ],
    
    // Clearances
    [ 0.05, 1, -1 ]
 );


motortype = motortype_NEMA17;
motorZ=[0,0,-14];
motorplate=5;

module gearbox_illustrate() {
    gearbox_draw_all(gearbox,0);
    echo("Total ratio: ",gearbox_ratio(gearbox));

    frame_printable();
    
    #gearbox_motor_transform(gearbox) translate(motorZ) {
        motor_3D(motortype);
        translate([0,0,motorplate]) motor_bolts(motortype);
    }
}
module frame_printable() {
    difference() {
        union() {
            gearbox_frame(gearbox);
            gearbox_motor_transform(gearbox) translate(motorZ)
                linear_extrude(height=motorplate,convexity=6)
                    motor_face_2D(motortype);
            
            // Extra material around drive bolt
            drivestack=25;
            translate([0,0,-drivestack]) union() {
                cylinder(d=16,h=drivestack);
                //cylinder(d1=20,d2=12,h=5);
                //cylinder(d=axleOD+0.1,h=100,center=true);
            }
            
            // Extra material for mounting
            gearbox_motor_transform(gearbox) translate(motorZ)
            {
                translate([-10,0,0])
                scale([-1,1,1]) cube([20,30,20]);
                sz=motor_square(motortype)/2;
                
                translate([+sz+motorplate/2,+sz+motorplate/2]) 
                scale([-1,-1,1]) {
                    cube([motorplate,2*sz+2*motorplate,20]); // base
                    cube([2*sz,motorplate,20]); // connect up to side
                }
            }
        }
        
        // Leave space for gears and shafts
        gearbox_clearance(gearbox);
        gearbox_frame_shafts(gearbox);
        
        
        gearbox_motor_transform(gearbox) translate(motorZ)
        {
            // Cut center boss
            cylinder(d=motor_boss_diameter(motortype),h=100,center=true);
            
            // Motor mounting holes
            translate([0,0,5]) motor_bolts(motortype,extra_head=25);
            
            // Trim bottom flat (for printability)
            translate([0,0,-200]) cube([400,400,400],center=true);
            
            // Bottom mounting options
            sz=motor_square(motortype)/2;
            for (dy=[0:15:30])
            translate([sz,sz-10-dy,15]) {
                rotate([0,90,0]) cylinder(d=5,h=40,center=true);
            }
        }
    }
}

gearbox_illustrate();

//frame_printable();
//gearbox_reduction3D(gearbox,1);
