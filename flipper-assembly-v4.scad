echo(version=version());

very_long = 100000000;

base_plate_length	= 125;
base_plate_width	= 60;
base_plate_depth	= 5;

coil_space_length = 58;
coil_plate_base_height = 10;
coil_plate_base_width = 38;
coil_plate_height = 40;
coil_plate_peg_hole_top_height = 34.15;
coil_plate_peg_hole_diameter = 5.2;

coil_front_plate_base_height = 5;
coil_front_plate_gap_width = 17;
coil_front_plate_gap_until = 14;

eos_switch_peg_box_base_width = 9;
eos_switch_peg_box_base_height = 18.9;
eos_switch_x_offset = 27;

eos_switch_peg_hole_x_margin = 4;
eos_switch_peg_hole_y_margin = 2;
eos_switch_peg_diameter = 3.4;
eos_switch_width = 10;
eos_switch_height = 20;
eos_switch_peg_box_height = 9.55;
eos_switch_peg_box_depth = 6.75;
eos_switch_peg_spacing = 6;
eos_switch_peg_length = 4;

flipper_shaft_holder_outer_diameter = 24;
flipper_shaft_holder_hole_diameter = 7.2;
flipper_shaft_holder_holder_height = 8;
flipper_shaft_holder_diameter = 20;
flipper_shaft_holder_base_depth = 2;
flipper_shaft_holder_base_x_margin = 27;
flipper_shaft_holder_base_y_margin = 3;

coil_stopper_pad_height = 17.8;
coil_stopper_pad_diameter = 10;
coil_stopper_pad_depth = 2;

spring_stopper_height = 30;
spring_stopper_base_length = 4;

feet_block_length = 15;
feet_block_width = 14;
feet_block_depth = 5;
feet_screw_hole_diameter = 3;

/* 
NOTE: Any shape which is cutting into another one is slightly nudged over so that it's not directly on the face of the other shape and instead it cuts straight through. If it's positioned on the face of the other shape it leaves a 1mm thick sheet at the edge of the other shape
*/

$fn=50;

module flipper_shaft_hole() {
    translate([
        base_plate_length/2 - flipper_shaft_holder_base_x_margin,
        base_plate_width/2 - flipper_shaft_holder_outer_diameter/2 - flipper_shaft_holder_base_y_margin,
        -base_plate_depth*2
    ])
        cylinder(h=very_long, r=flipper_shaft_holder_hole_diameter/2);
}


/* base plate */
difference() {
    cube(center = true, size = [
        base_plate_length,
        base_plate_width,
        base_plate_depth
    ]);
    flipper_shaft_hole();
}

/* coil plate with hole for plastic peg on Williams coil */
 difference() {
    /* coil plate */
    translate([
        -base_plate_length/2,
        -base_plate_width/2,
        base_plate_depth/2
    ])
        cube([
            coil_plate_base_height,
            coil_plate_base_width,
            coil_plate_height
        ]);
    
    /* peg hole */ 
    rotate([0, 90, 0])
    translate([
        -(base_plate_depth/2 + coil_plate_peg_hole_top_height),
        -base_plate_width/2 +coil_plate_base_width /2,
        -base_plate_length-1
    ])    
        cylinder(h=very_long, r=coil_plate_peg_hole_diameter/2); 
}

/* coil stopper to take the main impact from the magnetized flipper rod */
rotate([0, 90, 0])
translate([
    -(base_plate_depth/2 + coil_stopper_pad_height),
    -base_plate_width/2 +coil_plate_base_width /2,
    -base_plate_length/2 + coil_plate_base_height
])    
    cylinder(h=coil_stopper_pad_depth, r=coil_stopper_pad_diameter/2);

/* coil front plate to guide the metal rod and spring */
difference() {
    /* front plate */
    translate([
            -base_plate_length/2 + coil_plate_base_height + coil_space_length,
            -base_plate_width/2,
            base_plate_depth/2
    ])
        cube([
            coil_front_plate_base_height,
            coil_plate_base_width,
            coil_plate_height
        ]);

    /* gap for metal rod + spring */
    translate([
        -base_plate_length/2 + coil_plate_base_height + coil_space_length -1,
        -base_plate_width/2 + coil_plate_base_width/2 - coil_front_plate_gap_width/2,
        base_plate_depth/2 + coil_front_plate_gap_until
    ]) 
        cube([
            coil_front_plate_base_height+10,
            coil_front_plate_gap_width,
            coil_plate_height
        ]);
}


/* holder block for EOS switch */
first_peg_x = -base_plate_length/2 + eos_switch_x_offset + eos_switch_peg_box_base_height - eos_switch_peg_hole_x_margin;

translate([
    -base_plate_length/2 + eos_switch_x_offset,
    base_plate_width/2 - eos_switch_peg_box_base_width,
    base_plate_depth/2 
])
    // pegs to hold the EOS switch in place
    cube([
        eos_switch_peg_box_base_height,        
        eos_switch_peg_box_base_width,
        base_plate_depth/2 + eos_switch_peg_box_height
    ]);
    
    /* peg closest to the flipper shaft holder */
    rotate([90, 0, 0])
    translate([
        first_peg_x,
        eos_switch_peg_box_height + eos_switch_peg_hole_y_margin, 
        -base_plate_width/2 + eos_switch_peg_box_base_width
    ])    
        cylinder(h=eos_switch_peg_length, r=eos_switch_peg_diameter/2);
    
    /* next peg is spaced with a constant width so it will fit the standard EOS switch size */
    rotate([90, 0, 0])
    translate([
        first_peg_x - eos_switch_peg_spacing,
        eos_switch_peg_box_height + eos_switch_peg_hole_y_margin,        
        -base_plate_width/2 + eos_switch_peg_box_base_width
    ]) 
        cylinder(h=eos_switch_peg_length, r=eos_switch_peg_diameter/2);

/* flipper shaft holder base with cylinder-shaped hole cut through it  */
difference() {
    translate([
        base_plate_length/2 - flipper_shaft_holder_base_x_margin,
        base_plate_width/2 - flipper_shaft_holder_outer_diameter/2 - flipper_shaft_holder_base_y_margin,
        base_plate_depth/2
    ])
        /* holder base */
        cylinder(h=flipper_shaft_holder_base_depth, r=flipper_shaft_holder_outer_diameter/2);

    flipper_shaft_hole();
}
/* flipper shaft holder cylinder with cylinder-shaped hole to cut through it */
difference() {
    translate([
        base_plate_length/2 - flipper_shaft_holder_base_x_margin,
        base_plate_width/2 - flipper_shaft_holder_outer_diameter/2 - flipper_shaft_holder_base_y_margin,
        base_plate_depth/2 + flipper_shaft_holder_base_depth
    ])
        cylinder(h=flipper_shaft_holder_holder_height, r=flipper_shaft_holder_diameter/2);   

    flipper_shaft_hole();
};

/* spring stopper plate to stop the flipper springing too far out */
translate([
    base_plate_length/2 - spring_stopper_base_length,
    -base_plate_width/2,
    base_plate_depth/2,
]) 
    cube([
        spring_stopper_base_length,
        coil_plate_base_width,
        spring_stopper_height
    ]);

/* feet with holes for screws */
difference() {
    translate([
        base_plate_length/2 - feet_block_length,
        base_plate_width/2,
        -base_plate_depth/2
    ])
        cube([feet_block_length, feet_block_width, feet_block_depth]);

    translate([
        base_plate_length/2 - feet_block_length/2,
        base_plate_width/2 + feet_block_width/2,
        -base_plate_depth
    ])
        cylinder(h=very_long, r=feet_screw_hole_diameter/2);
}

difference() {
    translate([
        base_plate_length/2 - feet_block_length,
        -base_plate_width/2 - feet_block_width,
        -base_plate_depth/2
    ])
        cube([feet_block_length, feet_block_width, feet_block_depth]);

    translate([
        base_plate_length/2 - feet_block_length/2,
        -base_plate_width/2 - feet_block_width/2,
        -base_plate_depth
    ])
        cylinder(h=very_long, r=feet_screw_hole_diameter/2);
}

difference() {
    translate([
        -base_plate_length/2,
        -base_plate_width/2 - feet_block_width,
        -base_plate_depth/2
    ])
        cube([feet_block_length, feet_block_width, feet_block_depth]);

    translate([
        -base_plate_length/2 + feet_block_length/2,
        -base_plate_width/2 - feet_block_width/2,
        -base_plate_depth
    ])
        cylinder(h=very_long, r=feet_screw_hole_diameter/2);
}

difference() {
    translate([
        -base_plate_length/2,
        base_plate_width/2,
        -base_plate_depth/2
    ])
        cube([feet_block_length, feet_block_width, feet_block_depth]);

    translate([
        -base_plate_length/2 + feet_block_length/2,
        base_plate_width/2 + feet_block_width/2,
        -base_plate_depth
    ])
        cylinder(h=very_long, r=feet_screw_hole_diameter/2);
}
