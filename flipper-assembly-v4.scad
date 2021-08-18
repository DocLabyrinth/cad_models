echo(version=version());

very_long = 100000000;

base_plate_length	= 125;
base_plate_width	= 60;
base_plate_depth	= 8;

coil_space_length = 58;
coil_plate_base_height = 10;
coil_plate_base_width = 38;
coil_plate_height = 40;
coil_plate_peg_hole_top_height = 34.15;
coil_plate_peg_hole_diameter = 5.6;
coil_plate_snap_count = 3;
coil_plate_snap_height = 2;
coil_plate_snap_peg_margin = coil_plate_base_width/5;

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
eos_switch_peg_spacing = 9;
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

$fn=50;

module flipper_shaft_hole() {
    translate([
        base_plate_length/2 - flipper_shaft_holder_base_x_margin,
        base_plate_width/2 - flipper_shaft_holder_outer_diameter/2 - flipper_shaft_holder_base_y_margin,
        -base_plate_depth*2
    ])
        cylinder(h=very_long, r=flipper_shaft_holder_hole_diameter/2);
}

module snap_peg(
    col_width=10,
    col_height=4,
    snap_width=3,
    snap_height=2,
    mini_col_height=5,
    tolerance=0.5,
    // the arrow doesn't quite fit all the way so the column needs to be
    // slightly shorter to avoid the piece having a gap with whatever
    // it is attaching to
    col_reduce=0.1,
    // peg holes are similar objects to pegs they just don't reduce the
    // column size, don't apply size tolerance and don't render the cut
    // in the arrow head
    is_peg_hole=false
) {
    $fn = 100;
    mini_col_width = is_peg_hole ? col_width : col_width-tolerance;
    mini_col_height = is_peg_hole ? col_height : col_height - col_reduce;

    difference(){
        union() {
            cylinder(r=mini_col_width, h=mini_col_height - col_reduce); //mini column
            translate([0, 0, mini_col_height]) cylinder(r1=snap_width, r2=snap_width/2, h=snap_height); //arrow head  
        }
        if(!is_peg_hole) {
            translate([-snap_width/6, -snap_width, mini_col_height]) cube([snap_width/3, snap_width*2, snap_height + mini_col_height]); //cut in snap fit
        }
    }
}

module snap_pegs(
    peg_area_base_width,
    peg_margin,
    initial_translation,
    peg_width,
    peg_count=3,
    initial_rotation=[0, 180, 0],
    tolerance=0.2,
    fill_color="blue",
    render_as_peg_holes=false
) {
    room_for_pegs = peg_area_base_width - peg_margin * 2;

    use_color = render_as_peg_holes == true ? "grey" : fill_color;
    
    color(use_color)
    for (snap_peg_iter=[0:1:peg_count-1])       
        rotate(initial_rotation)
        translate(initial_translation) 
            translate([0, peg_margin + (room_for_pegs/(peg_count-1) * snap_peg_iter), 0])
            snap_peg(
                col_width=peg_width,
                col_height=base_plate_depth-coil_plate_snap_height,
                snap_width=peg_width,
                snap_height=coil_plate_snap_height,
                mini_col_height=base_plate_depth - coil_plate_snap_height,
                tolerance=tolerance,
                is_peg_hole=render_as_peg_holes
            );
}

// base plate
difference() {
    cube(center = true, size = [
        base_plate_length,
        base_plate_width,
        base_plate_depth
    ]);

    flipper_shaft_hole();

    /*
    ***
    *** Snap peg holes for different replaceable components
    *** which snap onto the base plate
    ***
    */

    // coil plate  
    snap_pegs(
        peg_width=coil_plate_base_height/4,
        peg_area_base_width=coil_plate_base_width,
        peg_margin=coil_plate_snap_peg_margin,
        initial_translation=[
            base_plate_length/2 - coil_plate_base_height/2,
            -base_plate_width/2,
            -base_plate_depth/2
        ],
        render_as_peg_holes=true
    );

    // coil_front_plate
    snap_pegs(
        peg_width=coil_plate_base_height/4,
        peg_area_base_width=coil_plate_base_width,
        peg_margin=coil_plate_snap_peg_margin,
        initial_translation=[
            base_plate_length/2 - coil_plate_base_height - coil_space_length - coil_front_plate_base_height/2,
            -base_plate_width/2,
            -base_plate_depth/2
        ],
        render_as_peg_holes=true
    );   
}



// coil plate with hole for plastic peg on Williams coil
difference() {
    // coil plate
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
    
    // peg hole
    rotate([0, 90, 0])
    translate([
        -(base_plate_depth/2 + coil_plate_peg_hole_top_height),
        -base_plate_width/2 +coil_plate_base_width /2,
        -base_plate_length-1
    ])    
        cylinder(h=very_long, r=coil_plate_peg_hole_diameter/2); 
}

snap_pegs(
    peg_width=coil_plate_base_height/4,
    peg_area_base_width=coil_plate_base_width,
    peg_margin=coil_plate_snap_peg_margin,
    initial_translation=[
        base_plate_length/2 - coil_plate_base_height/2,
        -base_plate_width/2,
        -base_plate_depth/2
    ]
);


// coil stopper pad on the coil plate to take the main impact from the magnetized flipper rod
rotate([0, 90, 0])
translate([
    -(base_plate_depth/2 + coil_stopper_pad_height),
    -base_plate_width/2 +coil_plate_base_width /2,
    -base_plate_length/2 + coil_plate_base_height
])    
    cylinder(h=coil_stopper_pad_depth, r=coil_stopper_pad_diameter/2);



// coil front plate to guide the metal rod and spring
difference() {
    // front plate
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

    // gap for metal rod + spring
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

    snap_pegs(
        peg_width=coil_plate_base_height/4,
        peg_area_base_width=coil_plate_base_width,
        peg_margin=coil_plate_snap_peg_margin,
        initial_translation=[
            base_plate_length/2 - coil_plate_base_height - coil_space_length - coil_front_plate_base_height/2,
            -base_plate_width/2,
            -base_plate_depth/2
        ],
        fill_color="blue"
    );  


// holder block for EOS switch
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
    
    // peg closest to the flipper shaft holder
    rotate([90, 0, 0])
    translate([
        first_peg_x,
        eos_switch_peg_box_height + eos_switch_peg_hole_y_margin, 
        -base_plate_width/2 + eos_switch_peg_box_base_width
    ])    
        cylinder(h=eos_switch_peg_length, r=eos_switch_peg_diameter/2);
    
    // next peg is spaced with a constant width so it will fit the standard EOS switch size
    rotate([90, 0, 0])
    translate([
        first_peg_x - eos_switch_peg_spacing,
        eos_switch_peg_box_height + eos_switch_peg_hole_y_margin,        
        -base_plate_width/2 + eos_switch_peg_box_base_width
    ]) 
        cylinder(h=eos_switch_peg_length, r=eos_switch_peg_diameter/2);

// snap_pegs(
//     peg_area_base_width=coil_plate_base_width,
//     peg_margin=coil_plate_snap_peg_margin,
//     initial_translation=[
//         -base_plate_length/2 + eos_switch_x_offset,
//         base_plate_width/2 - eos_switch_peg_box_base_width,
//         base_plate_depth/2 
//     ],
//     fill_color="blue"
// );


// outer flipper shaft holder base with cylinder-shaped hole cut through it
difference() {
    translate([
        base_plate_length/2 - flipper_shaft_holder_base_x_margin,
        base_plate_width/2 - flipper_shaft_holder_outer_diameter/2 - flipper_shaft_holder_base_y_margin,
        base_plate_depth/2
    ])
        // holder base
        cylinder(h=flipper_shaft_holder_base_depth, r=flipper_shaft_holder_outer_diameter/2);

    flipper_shaft_hole();
}
// flipper shaft holder cylinder with cylinder-shaped hole to cut through it
difference() {
    translate([
        base_plate_length/2 - flipper_shaft_holder_base_x_margin,
        base_plate_width/2 - flipper_shaft_holder_outer_diameter/2 - flipper_shaft_holder_base_y_margin,
        base_plate_depth/2 + flipper_shaft_holder_base_depth
    ])
        cylinder(h=flipper_shaft_holder_holder_height, r=flipper_shaft_holder_diameter/2);   

    flipper_shaft_hole();
};



// spring stopper plate to stop the flipper springing too far out
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



// feet with holes for screws
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
