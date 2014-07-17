// The fisherstruder - a compact 1.75mm filament extruder (direct drive with or without a nema 17 reductor)
// CC-BY-NC jeremie.francois at gmail.com July 2014

// Initially inspired by "Makergear Filament drive goes Bowden" by Luke321 at http://www.thingiverse.com/thing:63674

//include <../configuration.scad>;

// In bash:
// for w in bolt idler; do openscad fisherstruder.scad -o fs_$w.stl; done

print_what="all";
//print_what="bolt";
//print_what="idler";

use <nema17_stand.scad>;

module extruder_feeder_head(what="all")
{
	tol=0.1;

	brg_608_th=7; 
	brg_608_outer_d=22; 
	brg_608_inner_d=8; 
	brg_608_shoulder_d= 8/2 + 2;

	m3_d= 3;
	m3_nut_d= 6;
	m3_head_d= 5.5;
	m3_head_h= 2.2;
	m8_nut_d= 14.6;
	m8_nut_h= 5.5 + 0.1;
	m3_nylock_h= 3.8;

	nema_head_indentation_depth= 2 + 0.8;
	nema_head_indentation_d= 22.5;
	nema_tune_offset= 1.3; // how oblong are the stepper mount holes
	
	hobbed_bolt_d= 12.5;
	hobbed_bolt_h= 11;
	hobbed_bolt_xd= hobbed_bolt_d + 1.5;

	slit_depth= 1.5; // how much the idle can be squeezed further against the filament
	slit_offset_x= 10.5; // where to slice the object (inside)
	slit_offset_depth= 0.6; // how much to shave on top on the idler

	idler_brg_wall_th= 5; // how thick is the wall around the idler axis
	idler_freeplay= 0.8; // space around the idler bearing
	idler_hscrew_extent= 22.9;
	idler_hscrew_start= -2;

	ear_d= m3_d + 6; // diameter of the stepper screw columns

	// we removed the 3mm thickness of the stepper mount wall!
	extruder_height= 21.5 - 3;
	
	filament_offset_z= 8;
	filament_offset_x= hobbed_bolt_d/2 - 0.8;

	// Bowden and pneufit related settings
	bowden_od=4;
	pneufit_support_length= 14;
	pneufit_screw_diameter= 4.6; // 5mm screw diameter
	pneufit_shoulder_diameter= 10;
	pneufit_shoulder_protrude= 0; // additional protrusion may be useful for some

	/*
	// Settings for a pneufit that would be 10mm long and 10mm screw diameter (eg. defaut E3D)
	pneufit_support_length= 14 + 2;
	pneufit_screw_diameter= 4.6*0 + 9;
	pneufit_shoulder_diameter= 10 + 4;
	pneufit_shoulder_protrude= 0 + 10; // additional protrusion may be useful for some
	*/
	
	// Overall roundness
	roundness= 3;
	
	// Computed values

	idler_eccentricity_x= brg_608_outer_d/2 + hobbed_bolt_d/2;
	idler_ear_offset_x= idler_eccentricity_x - 2;
	idler_ear_offset_y= brg_608_outer_d/2 + 3;
	idler_hscrew_y= brg_608_outer_d/2 + m3_d/2 + 1.5;
	idler_hscrew_z= filament_offset_z + bowden_od/2 + m3_d/2;

	// Printing support
	prn_help_nut_head_th=0.8;

	// Generic modules
	module torus(r,rnd)
	{
		translate([0,0,rnd/2])
			rotate_extrude($fs=0.8)
				translate([r-rnd/2, 0, 0])
					circle(r= rnd/2, $fs=0.2);
	}

	module rtower(r, h=extruder_height)
	{
		hull()
		{
			torus(r=r, rnd= roundness);
			translate([0,0,r])
				cylinder(r=r, h= h-r);
		}
	}

	module drop(r, offset=tol, h=extruder_height, rounded_top=false)
	{
		translate([0,0,-offset])
			hull()
		{
			if(rounded_top)
			{
				rtower(r=r, h= h+2*offset);
				translate([-(r-2)*1.414,0,0])
					rtower(r=2, h=h+2*offset, $fs=0.5);
			}
			else
			{
				cylinder(r=r, h= h+2*offset);
				translate([-(r-2)*1.414,0,0])
					cylinder(r=2, h=h+2*offset, $fs=0.5);
			}
		}
	}

	// The RM extruder
	module nema_screws(dx, dy, carve=false)
	{
		translate([dx*31/2,dy*31/2,carve?-tol:0])
			for (a = [0:$children-1])
				child(a);

		// Second set of mount positions for reductor-equipped nema motors
		if(dx<0)
			translate([dx*28/(1.414*2),dy*28/(1.414*2),carve?-tol:0])
				for (a = [0:$children-1])
					child(a);
				
	}

	module hex_nut_carve()
	{
		rotate([0,0,30])
			cylinder(r=m8_nut_d/2 + 0.3,h=m8_nut_h+2*tol, $fn=6);
	}

	module nema_carve()
	{
		//gearhead indentation
		translate([0,0,extruder_height-nema_head_indentation_depth+tol])
			drop(h=nema_head_indentation_depth, r=nema_head_indentation_d/2);

		// mounting holes (twice, so that it is compatible with NEMA 17 and planetary gearbox)
		for(y=[-1,+1])
		{
			nema_screws(dx=-1, dy=y, carve=true)
			{
				hull()
					for(x=[-1,+1])
						translate([x*nema_tune_offset/2,0,0])
							cylinder(r=m3_d/2, h= extruder_height + 2*tol, $fn=12);
			}

			// Carve also pockets for the heads of the two other
			// M3 stepper screws (these only hold the stepper).
			nema_screws(dx=+1, dy=y, carve=true)
				hull() for(dx=[-1,+1])
					translate([dx*(slit_depth/2 + nema_tune_offset + 0.2),0,extruder_height-m3_head_h-0.1])
						cylinder(r1=m3_head_d/2+0.1, r2=m3_head_d/2+0.8, h= m3_head_h + 0.1+2*tol, $fs=1);
		}
	}
	
	module idler_axis_carve()
	{
		// M8 bearing axis, and the hexagonal nut head
		translate([idler_eccentricity_x,0,-tol])
		{
			cylinder(r=brg_608_inner_d/2 + 0.1, h=extruder_height-(m8_nut_h)+2*tol, $fs=1);
			translate([0, 0, extruder_height-m8_nut_h])
			{
				difference()
				{
					hull() for(dx=[-1,0])
						translate([dx*(slit_depth/2+0.1),0,0])
							hex_nut_carve();
					if(prn_help_nut_head_th>0) // helps printing the nut overhang
						translate([-m8_nut_d/2,-prn_help_nut_head_th/2,0.3])
							cube([m8_nut_d,prn_help_nut_head_th,m8_nut_h+tol]);
				}
			}
		}
	}

	module hobbed_bolt_carve()
	{
		drop(r=hobbed_bolt_xd/2);
		%translate([0,0,filament_offset_z]) difference()
		{
			// position and diameter of the internal hobbed bolt groove
			cylinder(r=10.65/2,h=0.4,center=true);
		}
	}

	module tight_hscrew()
	{
		for(y=[-1,+1])
			scale([1,y,1])
				translate([0, idler_hscrew_y, idler_hscrew_z])
					rotate([0,90,0])
						for (a = [0:$children-1])
							child(a);
	}

	difference()
	{
		// Body
		union()
		{
			// Positive shape
			hull()
			{
				// Central body
				drop(r=28/2, offset=0, rounded_top=true);

				// Protruding junction to the idler bearing axis
				translate([idler_eccentricity_x,0,0]) // body around the bearing axis
					rtower(r=brg_608_inner_d/2 + idler_brg_wall_th + 2);

				// ears around the idler bearing
				for(y=[-1,1])
					translate([idler_ear_offset_x, y*idler_ear_offset_y, 0])
						rtower(r=m3_head_d/2, $fs=1);
			}
			
			// Ears (stepper atachment holes)
			for(y=[-1,+1]) hull()
			{
				cylinder(r=15/2, h= extruder_height);
				nema_screws(dx=-1, dy=y)
					hull()
					for(x=[-1,+1])
						translate([x*nema_tune_offset/2,0,0])
							rtower(ear_d/2);
			}

			// Cylindrical lateral bodies for the idler tightening screws
			tight_hscrew()
			{
					hull()
					{
						translate([0,0,idler_hscrew_extent])
						{
							translate([0,-3,-(idler_hscrew_extent-idler_hscrew_start)/2]) cylinder(r=m3_head_d/2 + 3, h=tol);
							cylinder(r= m3_head_d/2 + 0.8, h=tol, $fs=1);
						}
						// Thightener head (inside)
						translate([0, 0, idler_hscrew_start]) cylinder(r=m3_head_d/2 + 1.8 , h=tol, $fs=1);
					}
			}

			// Side flats for the the pushfit connector and bowden output
			intersection()
			{
				for(y=[-1,1]) scale([1,y,1]) // y>0 for the output side
				translate([filament_offset_x, 0, filament_offset_z])
					rotate([-90,0,0])
						translate([0, 0, pneufit_support_length-6])
							cylinder(r1=pneufit_shoulder_diameter/2+1, r2=pneufit_shoulder_diameter/2, h= 6 + 5 + tol + (y>0 ? pneufit_shoulder_protrude : 0));
				translate([0,0,extruder_height/2]) cube([60,60,extruder_height], center = true); // chop anything that protrudes top & bottom
			}
		}
		
		// Negative shapes now on

		// Carve filament passage
		translate([filament_offset_x, 0, filament_offset_z])
			rotate([-90,0,0])
		{
				cylinder(r=bowden_od/2, h=100, center = true, $fs=0.5);
				//pushfit/pneufit mount
				translate([0, 0, pneufit_support_length])
					cylinder(r=pneufit_screw_diameter/2, h=5+2*tol + pneufit_shoulder_protrude, $fn=12);
		}

		// Carve the horizontal screw that tightens the idler
		tight_hscrew()
		{
			// nylock slot
			translate([0, 0, - m3_nylock_h + idler_hscrew_start + 1])
				cylinder(r1=m3_nut_d/2+0.8, r2=m3_nut_d/2-0.1, h=m3_nylock_h + 2, $fn=6);

			hull()
			{
				translate([0, 0, -10.5]) cylinder(h=tol, r=m3_d/2-0.1, $fn=6);
				cylinder(h=tol, r=m3_d/2+0.1, $fn=8);
				translate([0, 0, 31.5]) cylinder(h=tol, r=m3_d/2 + 0.15, $fs=0.5); // the diameter on the idler side is a bit larger
			}
		}

		// side opening for the idler bearing
		translate([idler_eccentricity_x,0,filament_offset_z])
		{
			difference()
			{
				hull()
				{
					for(x=[-1,+1])
						translate([x*slit_depth/2,0,0])
							cylinder(r= brg_608_outer_d/2 + idler_freeplay, h=brg_608_th + 2*idler_freeplay, center = true);
				}
				for(y=[-1,+1]) scale([1,1,-1])
					translate([slit_depth/2,0,y*(brg_608_th/2)])
						scale([1,1,y])
							cylinder(r1= brg_608_shoulder_d, r2= brg_608_shoulder_d+ idler_freeplay, h=idler_freeplay+tol);
			}
			%cylinder(r= brg_608_outer_d/2, h=brg_608_th, center = true); // bearing ghost
		}

		// More negative shapes
		nema_carve();
		idler_axis_carve();
		hobbed_bolt_carve();
		
		// Carve a hole in the butt of the fish - to clean the hobbed bolt after removing the bearing, eg.
		translate([0, 0, (filament_offset_z/2+brg_608_th/2+idler_freeplay/2)])
			rotate([0,-90,0])
					cylinder(r=brg_608_th/2+1, h=20, $fs=1); // drop motor 

		// Slit (break the whole in two parts)
		translate([slit_offset_x,0,0])
		{
			// Optional: shave some material so as not to touch the stepper
			translate([0,-20, extruder_height-slit_offset_depth]) cube([20,40,slit_offset_depth+tol]);
			// Slit towards the hinge
			translate([-slit_depth/2.0,-40,-tol])
				cube([slit_depth,80,extruder_height+2*tol]);
			
			// Actually chop the whole in two when required
			translate([0,-40,-extruder_height/2])
			{
				if(what=="bolt")
					scale([1,1,1]) cube([80,80,extruder_height*2]);
				else if(what=="idler")
					scale([-1,1,1]) cube([80,80,extruder_height*2]);
			}
		}
	}
}

module extruder(print_what="all")
{
	if(print_what=="all")
		extruder_feeder_head(print_what);
	else if(print_what=="bolt")
		rotate([0,90,0]) extruder_feeder_head(print_what);
	else if(print_what=="idler")
		rotate([0,-90,0]) extruder_feeder_head(print_what);
}

extruder(print_what);
