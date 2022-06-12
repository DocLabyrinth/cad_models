main_height = 18;
large_pipe_diameter = 26.25;
small_pipe_diameter = 16;
small_pipe_inner_diameter = 8.8;
wall_thickness = 3;
tolerance = 0.1;

holder_gap = 1.5;
holder_height = 6;

$fn = 100;

outer_diameter = large_pipe_diameter + wall_thickness;
inner_diameter = large_pipe_diameter + tolerance;
holder_bite_width = 4.5;
holder_bite_height = large_pipe_diameter/2 - small_pipe_diameter/2 + holder_gap;
holder_bite_count = 6;

foot_height = 15;
foot_end_width = 6.5;
foot_end_height = 3;
foot_extend_width = 3.3;
foot_extend_height = 11;
foot_offset = 4;

pipe_support_depth = 5;

module holder_bite() {
 linear_extrude(height=holder_height)
     translate([0,-holder_bite_width/2,0])
     union() {
        square([holder_bite_height, holder_bite_width]);
        polygon(points=[[0,0],[0,-holder_bite_width/2],[holder_bite_height,0]]);
        polygon(points=[[0,holder_bite_width],[0,holder_bite_width + (holder_bite_width/2)],[holder_bite_height,holder_bite_width]]);
    };
}

module band_holder() {
    foot_tip_height = foot_height / 8;

    translate([-foot_end_width/2,0,0]) difference() {
        linear_extrude(height=foot_height) {
            offset(1) offset(-1) square([foot_end_width, foot_end_height]);
            translate([foot_end_width/2 - foot_extend_width/2,0,0]) square([foot_extend_width,foot_extend_height]);
        }
        rotate([0, 90, 0]) translate([-foot_height - foot_tip_height,-foot_extend_height/8,-foot_end_width/2]) cylinder(h=foot_end_width*2, r=foot_extend_height);
    }
}

module cutter_back() {
    union() {  
        difference() {
            cylinder(h=main_height, r=outer_diameter/2);
            cylinder(h=main_height+1, r=inner_diameter/2);
        }
        difference() {
            cylinder(h=holder_height, r=inner_diameter/2);
            cylinder(h=holder_height+2, r=small_pipe_diameter/2);
            for (rotation_iter = [0: holder_bite_count - 1]) {
                rotate([0, 0, (360/holder_bite_count) * rotation_iter]) 
                translate([outer_diameter/2 - holder_bite_height - holder_gap, 0, 0]) rotate([0,0,0]) holder_bite();
            }
        }
        translate([0,-foot_extend_height-inner_diameter/2,0]) band_holder();
        rotate([0,0,180]) translate([0,-foot_extend_height-inner_diameter/2,0]) band_holder();
}
}

main_cone_height = main_height * 0.8;
main_cone_width = outer_diameter/2;
nozzle_wall_thickness = 1.7;
pipe_inner_width = 7;
gardena_inner_width = 9.5;
nozzle_grip_count = 3;
nozzle_grip_offset = 8;
nozzle_grip_gap = 2.7;

support_cross_width = 1;
support_cross_height = pipe_inner_width * 1.2;
support_cross_depth = 16;

gardena_outer_diameter = 13.25;

module cone(lower_width, upper_width, height) {
    rotate_extrude(angle=360)
        polygon(points=[[0,0],[lower_width,0],[upper_width,height], [upper_width, 0]]);
}

module support_cross(width, height, depth) {
    translate([-width/2, -height/2, 0])
    cube([width, height, depth]);
    translate([-height/2, -width/2, 0])
    cube([height, width, depth]);
}

module regular_nozzle(inner_width, wall_thickness) {
    difference() {
        union() {
            cone(lower_width=pipe_inner_width, upper_width=0, height=main_cone_height*1.2);

            // wider grips to hold the hose in place
            for(nozzle_grip_iter = [0:nozzle_grip_count-1]) {
                translate([0,0,(nozzle_grip_iter * nozzle_grip_gap) + nozzle_grip_offset])
                cone(lower_width=inner_width/2 + wall_thickness, upper_width=0, height=main_cone_height * 0.6);
            }
        };
    }
}

module gardena_nozzle(inner_width, wall_thickness) {
    cylinder(h=main_cone_height, r=gardena_outer_diameter/2);
    translate([0,0,main_cone_height/2]) cone(lower_width=gardena_outer_diameter/2 + 1, upper_width=0, height=main_cone_height * 0.6);
}

module cutter_front(inner_width, pipe_inner_width, wall_thickness, use_gardena_nozzle=false) {
    union() {
        difference() {
            cylinder(h=main_height, r=outer_diameter/2);
            cylinder(h=main_height+1, r=inner_diameter/2);
        }
        difference() {
            cylinder(h=holder_height, r=inner_diameter/2);
            translate([0,0,-1]) cylinder(h=holder_height+2, r=inner_diameter/2);
        }
    }

    difference() {
        union() {
            translate([0,0,main_height])
                cone(lower_width=main_cone_width, upper_width=0, height=main_cone_height);

            if(use_gardena_nozzle == true) {
                translate([0,0,main_height + main_cone_height * 0.5]) gardena_nozzle(inner_width=gardena_inner_width, wall_thickness=wall_thickness);
            } else {
                translate([0,0,main_height + main_cone_height * 0.5]) {
                    regular_nozzle(pipe_inner_width=inner_width, wall_thickness=wall_thickness);
                }
            }
        };

        // cut a gap through the nozzle so water can flow through
        translate([0,0,-main_cone_height/2 - 1]) cylinder(r=small_pipe_inner_diameter/2, h=100);

    }

    translate([0,0,main_height*0.8]) support_cross(width=support_cross_width, height=support_cross_height, depth=support_cross_depth);

    translate([0,0,main_height*0.6]) cylinder(r=small_pipe_diameter/2 + 1, h=pipe_support_depth);
    translate([0,0,main_height*0.6 - pipe_support_depth]) cylinder(r=small_pipe_inner_diameter/2 + 1, h=pipe_support_depth);
}

// cutter_back();
cutter_front(inner_width=inner_diameter, pipe_inner_width=pipe_inner_width, wall_thickness=nozzle_wall_thickness, use_gardena_nozzle=true);
