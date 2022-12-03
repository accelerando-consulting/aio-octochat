/* [Parameters] */

item="base"; // ["base","key","button","mat","mat2d", "assembly"]
dia=58;
outer_height=15;
pcb_height=3;
pcb_rim = 3.5;

button_stride = 105;

/* [Keyswitch] */

key_type="cherry"; //["cherry","kailh"]
kailh_key_height=5.5;
kailh_key_stroke=3;
cherry_key_height=11;
cherry_key_stroke=4;

/* [Advanced] */

pcb_thickness=1.6;
show_pcb=false;
invert=true;
key_clearance=1.2;

i2c_height=5-pcb_thickness;
i2c_width = 7;

fpc_width =10;
fpc_height=0;
fpc_thickness=pcb_height-0.5;

/* [Hidden] */

$fn=60;
fuz=0.1;fuzz=2*fuz;


// A regular octogon is cylinder($fn=8) but KiCad doesn't do regular polygons so an APPROXIMATE octogon is drawn

module bogoctogon20() {
    translate([-25,-25])
	polygon(points=[[15,0],[35,0],[50,15],[50,35],[35,50],[15,50],[0,35],[0,15]]);
}

module bogoctogon(side) {
    scale([side/20,side/20])
	translate([-25,-25])
	polygon(points=[[15,0],[35,0],[50,15],[50,35],[35,50],[15,50],[0,35],[0,15]]);
}

module bogoctoprism(side,height) {
    linear_extrude(height=height) { bogoctogon(side); }
}

module roundover(l=20,r=5) {
    difference() {
	cube([r,r,l]);
	translate([0,0,-fuz]) cylinder(r=r,h=l+fuzz);
    }
}

module tube(d,h,wall=5) {
    difference() {
	cylinder(d=d,h=h);
	translate([0,0,-fuz])cylinder(d=d-2*wall,h=h+fuzz);
    }
}

module bogoctobutton(side,height,radius) {
    difference() {
	bogoctoprism(side,height);
	for (i=[0:7]) {
	    //color("red") rotate([0,0,i*360/8]) translate([side*1.25,0,height]) rotate([90,0,0]) translate([0,0,-side*0.6]) cylinder(r=radius,h=side*1.2);
	    color("green") rotate([0,0,i*360/8]) translate([side*1.25-radius,0,height-radius]) rotate([90,0,0]) translate([0,0,-side*0.6]) roundover(l=side*1.2,r=radius);
	}
    }
}

//bogoctoprism(20,5);

module cylinder_roundover(d=20,r=5) {
    rotate_extrude() {
	translate([d/2-r,0,0]) {
	    difference() {
		square([r,r]);
		circle(r=r);
	    }
	}
    }
}

module bollard(d,h,r=5,n=0) {
    difference() {
	if (n) {
	    rotate([0,0,1.5*(360/n)]) cylinder(d=d,h=h,$fn=n);
	}
	else {
	    cylinder(d=d,h=h);
	}
	translate([0,0,h-r]) cylinder_roundover(d=d,r=r);
    }
    //color("red") translate([0,0,h-r]) cylinder_roundover(d=d,r=r);
}


module drills(h=30,d=1.6) {
    for (i=[0:7]) {
	rotate([0,0,(i+0.5)*360/8]) translate([24.4,0,0]) cylinder(d=d,h=h);
    }
}

module fpc_slots() {
    for (i=[0:7]) {
	rotate([0,0,i*360/8]) translate([dia/2,0,fpc_height+fpc_thickness/2]) cube([20,fpc_width,fpc_thickness],center=true);
    }
}

module fpc_clearance() {
    for (i=[0:7]) {
	rotate([0,0,i*360/8]) translate([dia/2,0,fpc_height+fpc_thickness/2]) cube([20,fpc_width,fpc_thickness],center=true);
    }
}

module pcb() {
    color("green",0.5) bogoctoprism(20.5,pcb_thickness);
}

module base(pcb=false) {
    difference() {
	//color("yellow", 0.6) cylinder(d=dia,h=outer_height);
	bollard(d=dia,h=outer_height,r=3,n=8);
	tube(d=dia,h=outer_height,wall=0.5);
	translate([0,0,-fuz]) {
	    bogoctoprism(20.5,pcb_height+pcb_thickness);
	    bogoctoprism(20.5-pcb_rim,outer_height+fuzz);
	    drills(h=pcb_height+8,d=1.6);
	    fpc_slots();
	    translate([dia/2,0,pcb_height+pcb_thickness+i2c_height/2]) cube([20,i2c_width,i2c_height],center=true);
	}
    }
    if (pcb) {
	translate([0,0,pcb_height]) {
	    %pcb();
	    translate([0,0,pcb_thickness]) %keyswitch();
	}
    }
}


module post(l,w,h) {
    translate([-l/2,-w/2,0]) cube([l,w,h]);
}

module rounded_post(l,w,h,r=2) {
    translate([-l/2,-w/2,0]) {
	minkowski() {
	    cube([l,w,h]);
	    cylinder(r=r,h=1);
	}
    }
}

module kailh_keycap_pins() {
    translate([-3.5,-1.5,0]) cube([1,2.5,3]);
    translate([3.5-1.2,-1.5,0]) cube([1,2.5,3]);
}


module cherry_keycap_cross(h=4) {
    cube([4+2*fuz,1.3+2*fuz,h], center=true);
    cube([1.1+2*fuz,4+2*fuz,h], center=true);
}


module keypost(h) {
    post(10,5,h);
    translate([0,0,h]) kailh_keycap_pins();
}

module cherry_keypost(h) {
    difference() {
	post(6,4,h);
	translate([0,0,h]) cherry_keycap_cross(h=10);
    }		      
}

module kailh_keyswitch() {
}

module cherry_keyswitch() {
    translate([0,0,11/2]) color("white",0.5) cube([15.6,15.6,11],center=true);
    translate([0,0,11+2]) color("red",0.5) cherry_keycap_cross();
}

module keyswitch() {
    if (key_type=="cherry") cherry_keyswitch();
    if (key_type=="kailh") kailh_keyswitch();
}

module kailh_button() {
    button_height = outer_height+10-pcb_height;
    difference() {
	bogoctobutton(20.5-pcb_rim-key_clearance,button_height,3);
	translate([0,0,-fuz]) bogoctobutton(19.5-pcb_rim-key_clearance,button_height-1,2);
    }
    keycap_height = button_height-key_height;
    translate([0,0,button_height]) scale([1,1,-1]) keypost(keycap_height);
}

module cherry_button() {
    button_height = outer_height-pcb_height;
    difference() {
	bogoctobutton(20.5-pcb_rim-key_clearance,button_height,3);
	translate([0,0,-fuz]) bogoctobutton(19.3-pcb_rim-key_clearance,button_height-1.2,2);
    }
    keycap_height = button_height-cherry_key_height+cherry_key_stroke;
    translate([0,0,button_height]) scale([1,1,-1]) cherry_keypost(keycap_height);
}

module button() {
    if (key_type=="cherry") cherry_button();
    if (key_type=="kailh") kailh_button();
}

module kailh_button_assembly() {
    base(show_pcb);
    translate([0,0,pcb_height+pcb_thickness+kailh_key_stroke]) kailh_button();
}
module cherry_button_assembly() {
    base(show_pcb);
    translate([0,0,pcb_height+pcb_thickness+cherry_key_stroke+0]) cherry_button();
}

module button_assembly() {
    if (key_type=="cherry") cherry_button_assembly();
    if (key_type=="kailh") kailh_button_assembly();
}

module button_set() {
    translate([0,-button_stride/2,-fuz]) children();
    translate([button_stride,-button_stride/2,-fuz]) children();
    translate([-button_stride,-button_stride/2,-fuz]) children();
    translate([0,button_stride /2,-fuz]) children();
}

module mat(buttons=false) {
    difference() {
	translate([0,0,6]) cube([3*button_stride,2*button_stride,12],center=true);
	button_set() bollard(d=dia,h=outer_height,r=5,n=8);
    }
    if (buttons) button_set() button_assembly();
}

/*
  scale([1,1,-1]) {
  intersection() {
  base();
  cylinder(d=dia,h=pcb_height+1);
  }
  translate([0,0,pcb_height]) intersection() {
  button();
  cylinder(d=dia,h=1);
  }
  }
*/


//keypost(4);

//mat();


//bollard(d=50,h=100,r=5);

difference() {
    //rotate([0,invert?180:0,0])
    union() {
	if (item=="base") translate([0,0,invert?outer_height:0]) rotate([0,invert?180:0,0]) base(show_pcb/*&&!invert*/);
	if (item=="key") translate([0,0,invert?(outer_height-pcb_height):0]) rotate([0,invert?180:0,0]) /*translate([0,0,pcb_height])*/ cherry_button();
	if (item=="mat") mat();
	if (item=="mat2d") projection() mat();
	if (item=="button") button_assembly();
	if (item=="assembly") mat(buttons=true);
    }
    //translate([-50,-50,0]) cube([100,50,50]);
}

