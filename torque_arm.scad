/*
  Example robot arm link, demonstrating 3D design with a "shrink" approach.
  Driven by the gearbox in gearbox_arm.scad
  
   v1: Basic shape and reinforcing ribs
   v2: Gear drive
   v3: Lighten hole 
  
  Dr. Orion Lawlor, lawlor@alaska.edu, 2023-09-14 (Public Domain)
*/
include <AuroraSCAD/gear.scad>; // from https://github.com/AuroraRoboticsLab/AuroraSCAD
$fs=0.2; $fa=5; // fine render
//$fs=0.5; $fa=15; // coarse render

inch=25.4; // file units are mm

armThick=25; // thickness of entire arm, bottom to top

wall=0.8; // thickness of outer skin (two passes)
ribZ=2.5;
ribWall=wall;
ribSpacing=20;

// These gear parameters need to match the gearbox:
shoulderGearZ=10;
shoulderDriveGT=geartype_create(1.75,shoulderGearZ);
shoulderDriveG=gear_create(shoulderDriveGT,42,1);
gearWall=2.0; // plastic around outside of gear
shoulderOutsideR=gear_OR(shoulderDriveG)+gearWall;
shoulderScale=[1,1,0.5]; // scale factor on shoulder sphere

axleR=5/16*inch/2;


armLength = 180; // shoulder-to-elbow

shoulderR=shoulderOutsideR; // size of shoulder circle
shoulderCenter=[0,0,0];
shoulderSphereCenter=shoulderCenter + [0,0,shoulderGearZ];

elbowR=axleR+3; // elbow cylinder outside radius
elbowZ=25; // elbow pin height
elbowCenter=[armLength,0,0];
elbowAngle=-atan2(elbowCenter[2],elbowCenter[0]); // Y axis rotate


/* Shrinkable ellipse: radius r, but scaled by nonuniform scale factor s, *then* shrunk */
module shrinkableEllipse(r,s,shrink=0)
{
    shrinkScale=[r*s[0]-shrink,r*s[1]-shrink,r*s[2]-shrink]/r;
    scale(shrinkScale) sphere(r=r);
}

/* Shrinkable cylinder: radius and height grow/shrink by a distance */
module shrinkableCylinder(r,h,shrink=0)
{
    translate([0,0,+shrink])
        cylinder(r=r-shrink,h=h-2*shrink);
}

/* Axle holes through arm */
module armHoles(shrink=0)
{
    // Axle holes
    for (hole=[elbowCenter,shoulderCenter]) 
        translate(hole) translate([0,0,-5])
            shrinkableCylinder(axleR,armThick+10,-shrink);
    
}

/* 3D outside profile of arm */
module armOutside(shrink=0,gearHole=1)
{
    difference() {
        hull() {
            translate(shoulderSphereCenter)
                shrinkableEllipse(shoulderR,shoulderScale,shrink);
            translate(elbowCenter)
                shrinkableCylinder(elbowR,elbowZ,shrink);
            
        }
        
        // Double-thick walls around axle holes
        armHoles(2*shrink);
        
        // Space for shoulder drive gear (and its mounting bolt)
        gearHoleR=1;
        if (gearHole) 
        rotate_extrude() offset(r=shrink) 
        hull() {
            // Rounded top part
            translate([shoulderR*0.6,armThick-1.5*wall-gearHoleR])
                circle(r=gearHoleR);
            // Flat bottom
            translate([3*axleR,-0.1])
                square([shoulderR-3*axleR-3,0.1]);
            
            // Space around gear
            translate([shoulderOutsideR-2,0])
                square([1,shoulderGearZ]);
        }
        
            
        // Hole to make arm lighter (does it though?)
        translate((elbowCenter+shoulderCenter)/2) 
            shrinkableEllipse(22,[2.3,0.7,2.0],-shrink);
            
        // Trim bottom flat
        translate([0,0,0+shrink-500]) cube([1000,1000,1000],center=true);
        // Trim top flat (extra thickness)
        translate([0,0,armThick-1.5*shrink+500]) cube([1000,1000,1000],center=true);
    }
}

/* Inset to drive this part */
module armDriveable(shrink=0) {
    difference() {
        armOutside(shrink);
        // Space for motor
        if (0) scale([1,1,-1]) 
            translate([0,0,-shrink])
                cylinder(r=shoulderOutsideR+shrink,h=100);
    }
}

/* Hollow part */
module armHollow(outsideShrink,insideShrink)
{
    difference() {
        armDriveable(outsideShrink); // outside
        armDriveable(insideShrink); // inside
    }
}

/* Stacks of reinforcing plates */
module setOfRibs() {
    // Angled stacks along X axis:
    for (x=[-6*ribSpacing:ribSpacing:armLength+elbowR])
        translate([x,0,0])
        for (slant=[-45,+45]) rotate([0,0,slant])
            cube([ribWall,200,200],center=true);
    
    // Extra centerline plates:
    cube([500,wall,500],center=true); // reinforce XZ
    cube([wall,500,500],center=true); // reinforce YZ
    translate([0,0,armThick/2])
        cube([500,500,wall],center=true); // reinforce XY
}


/* Reinforcing ribbed arm */
module armReinforced(ribs=1) 
{
    // Outer skin
    armHollow(0,wall);
    // Ribs
    intersection() {
        armHollow(wall/2,ribZ);
        setOfRibs();
    }
    
    // Drive ribs
    intersection() {
        armOutside(wall/2,0);
        for (a=[-90:45:+90]) rotate([0,0,a]) 
            translate([axleR+0.1,0,shoulderGearZ+5])
                cube([100,2*wall,100]);
    }
    
    // Extra material around shoulder drive gear
    difference() {
        cylinder(r=shoulderOutsideR,h=shoulderGearZ-0.02);
        translate([0,0,-0.01]) ring_gear_cut(shoulderDriveG);
    }
}

/* Elbow-to-rod joint */
rodOD=9.3; // composite rods hold the elbow to the tool
rodWall=1.5; // plastic around rods
rodThick=rodOD+2*rodWall; // thickness of plastic part
rodZ=rodOD/2+rodWall; // height of rod centerline
rodL=armLength; // joint-to-joint length
rodGrab=36; // length of rod held in joint
echo("Rod length ",rodL-rodGrab);
elbowPivot=8.0; // diameter of aluminum elbow pivot axle pin
elbowPivotLen=armThick+elbowPivot; // length of axle pin
elbowCaps=elbowPivot/2+rodWall; // plastic over endcaps
echo("Pivot length ",elbowPivotLen);

module elbowJoint2D() {
    round=1;
    offset(r=+round) offset(r=-round)
    difference() {
        hull() {
            translate([0,armThick/2])
                square([rodThick,armThick+2*elbowCaps],center=true);
            translate([rodGrab/2,rodZ])
                square([rodGrab,rodThick],center=true);
        }
        translate([0,armThick/2]) hull() {
            translate([-25,0]) square([1,armThick],center=true);
            translate([elbowR,0]) scale([1,1,1]) circle(d=armThick);
        }
    }
}
module elbowJoint3D() {
    difference() {
        linear_extrude(height=rodThick,center=true,convexity=4) 
            elbowJoint2D();
        
        // Rod
        translate([rodGrab/2,rodZ]) rotate([0,90,0]) cylinder(d=rodOD,h=50);
        // Elbow pivot axle
        translate([0,armThick/2]) rotate([90,0,0]) cylinder(d=elbowPivot,h=elbowPivotLen,center=true);
        
        // Clearance for arm
        translate([0,armThick/2]) 
            for (angle=[+1,-1]) rotate([0,angle*45,0]) cube([2*elbowR,armThick,100],center=true);
    }
}


//toolOD=16.1; // diameter of hole for hotend, extruder, etc
toolOD=11.3; // diameter of sharpie
toolZ=rodThick;
toolWall=1.64; // plastic around toolOD
toolClear=0.2; // distance between cylinder walls
toolPivotOD=toolOD+2*toolWall; // pivot point between tool segments

module toolPivot(ID=toolOD,uprightOD=0) {
    rodStart = [rodGrab/2,0,rodZ];
    
    difference() {
        union() {
            hull() {
                translate(rodStart+[0,-rodThick/2,-rodThick/2]) 
                    cube([rodGrab/2,rodThick,rodThick]);
                cylinder(d=ID+2*toolWall,h=toolZ);
            }
            if (uprightOD) 
                cylinder(d=uprightOD,h=2*toolZ);
        }
        // Tool
        cylinder(d=ID,h=100,center=true);
        
        // Rod
        translate([rodGrab/2,0,rodZ]) rotate([0,90,0]) cylinder(d=rodOD,h=50);
    }
}


difference() {
    //armReinforced(1);
    
    //cube([200,200,200]); // cutaway
}

//elbowJoint3D();

toolPivot(toolPivotOD); // outer segment
translate([0,25,0])
//translate([0,0,-rodThick-1])
    toolPivot(toolOD,toolPivotOD-2*toolClear);
