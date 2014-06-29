

//============================================================================== MOTOR PLATE



module extruder_mount()
{
	tol=0.1;
	$fa=0.1;
	$fs=1;


	csth= 3.2; // wall and bottom thickness
	csm= 3; // margin around plate holes

	space_below_stepper= 0.15; //-// csth+0.15

	motor_side= 42;
	motor_axis_z= csth + motor_side/2;

	motor_shaft_d= 5 - 0.2;
	m3_d= 3;

	motor_height= 35.4;
	motor_diag_screws= 46.5 - 2.7;

	plate_len= motor_height + 4;
	arm_reduced_h= 3;


	module tolz()
	{
		translate([0,0,-tol]) child(0);
	}


	module debug_motor()
	{
		%translate([-1,-motor_side/2,space_below_stepper])
		{
			cube([motor_height, motor_side, motor_side]);
			translate([0,motor_side/2,motor_side/2]) rotate([0,90,0]) cylinder(r=motor_shaft_d/2,h=80);
		}
	}

	module base_holes(inner_delta_x=0, inner_delta_y=0)
	{
		for(y=[-1,+1])
			for(x=[-1,+1])
				translate([x*(plate_len/2 - csm/2 - inner_delta_x-2) - 2,y*(29 - inner_delta_y),0])
					for (a = [0:$children-1]) child(a);
	}

	module motor_walls()
	{
		for(y=[-1,+1])
			translate([-plate_len/2,y*(motor_side/2 + csth),0])
					translate([arm_reduced_h,0,0])
				difference()
				{
					hull()
					{
						cylinder(r=csth/2, h=tol);
						translate([plate_len+csth/2-arm_reduced_h,0,0]) cylinder(r=csth/2 - 0.1, h=plate_len-arm_reduced_h);
					}
					// lateral holes
					translate([plate_len*0.9,-tol,motor_side*0.15]) rotate([-90,0,0]) cylinder(r=plate_len*0.5,h=csth+4*tol,center=true, $fn=4);
				}
	}

	translate([-plate_len/2 - csth, 0, -motor_side/2 - space_below_stepper]) // centered the view on the motor shaft
	{

		// Bottom
		difference()
		{
			union()
			{
				//-// hull() base_holes() cylinder(r=m3_d/2+csm,h=csth);
				for(y=[-1,+1])
					hull()
						for(x=[-1,+1])
							translate([x*(plate_len/2 - csm/2),y*(29),0])
								for (a = [0:$children-1]) { cylinder(r=m3_d/2+csm,h=csth); translate([0,-y*2,0]) cylinder(r=m3_d/2+csm,h=csth); }

				motor_walls();
			}
			// Remove screw holes
			base_holes() tolz() cylinder(r=m3_d/2,h=csth+2*tol);
			// And remove the central hole in the floor (faster print)
			//-//		hull() base_holes(inner_delta_x=8, inner_delta_y=11.8) tolz() cylinder(r=m3_d/2+csm,h=csth+2*tol);
		}

		// Mounting wall
		translate([plate_len/2+csm/2,0,0])
			intersection()
			{
				// Front wall
				translate([0,0,space_below_stepper])
				difference()
				{
					difference()
					{
						// Front wall between the two outer columns
						hull()
							for(y=[-1,+1])
								translate([0, y*(motor_side/2 + csth ), -space_below_stepper])
									hull()
									{
										translate([0,y*4,0]) cylinder(r=csth/2, h=tol); // corners
										translate([0, 0, motor_side]) cylinder(r=csth/2, h=tol);
									}
						translate([0,0,motor_side/2])
						{
							// Motor axis shoulder
							rotate([0,90,0]) cylinder(r=22.3/2+1,h= csth+2*tol, center=true);
							// Motor holes
							for(r=[0:90:359])
								rotate([0,90,0])
									rotate([0,0,r+45])
										translate([0,motor_diag_screws/2,0])
											cylinder(r=m3_d/2, h=csth*2+2*tol, center=true);
						}
					}
				}
				union() // cosmetic round top :p
				{
					hull() for(z=[0,26]) translate([-csth,0,z+space_below_stepper]) scale([1,1,0.4]) rotate([0,90,0]) cylinder(r=motor_side, h=csth*3);
				}
			}

		%translate([-plate_len/2,0,0]) debug_motor();
	}

}

//============================================================================== ALL COMPONENTS

extruder_mount();