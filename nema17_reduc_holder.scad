tol= 0.05;
reduc_d= 36;
wall_th= 2;
reduc_len= 14; // 23 max
nema_side_len= 42;
slit_th=0.8;

m3= 3;
m3_len= 8;
base_th= 2.8;

dist_b_screws= 36;

m3_d= 3;
m3_nut_d= 6;
m3_nut_dtol= 0.4;
m3_head_d= 5.5;
m3_head_h= 2.2;
m3_nylock_h= 3.8;

$fa=1;
$fs=1;

module torus(r,rnd)
{
	translate([0,0,rnd/2])
		rotate_extrude($fs=0.8)
			translate([r-rnd/2, 0, 0])
				circle(r= rnd/2, $fs=0.3);
}


module ring_body()
{
	difference()
	{
		hull()
		{
			translate([0,-nema_side_len/2,0]) cube([reduc_len, nema_side_len, tol]);
			translate([0,0,reduc_d/2 + (nema_side_len-reduc_d)/2])
				rotate([0,90,0])
					hull()
				{
					torus(r= reduc_d/2 + wall_th, rnd=2);
					translate([0,0,reduc_len-2])
						torus(r= reduc_d/2 + wall_th, rnd=2);
				}
		}
		
		translate([-tol,0,reduc_d/2 + (nema_side_len-reduc_d)/2])
			rotate([0,90,0])
				cylinder(r= reduc_d/2, h= reduc_len + 2*tol);

		// Holes for the attachment screws
		for(y=[-1,+1]) scale([1,y,1])
		{
			translate([reduc_len/2, dist_b_screws/2, 0])
			{
				translate([0,0,-tol]) cylinder(r=m3/2, h=m3_len, $fs=0.8);
				translate([0,0,base_th*2+slit_th]) hull()
				{
					% rotate([0,0,30]) cylinder(r=m3_nut_d/2, h=m3_nylock_h, $fn=6); // nylock ghost
					for(dy=[0,1])
						translate([0,dy*5,0])
							hull()
							{
								rotate([0,0,30]) cylinder(r=m3_nut_d/2+m3_nut_dtol, h=m3_nylock_h+0.4, $fn=6);
								translate([0,8,0])
									rotate([0,0,30]) cylinder(r=m3_nut_d/2+m3_nut_dtol, h=m3_nylock_h+5, $fn=6);
							}
				}
			}
		}

		// Slit on one side
		hull()
		{
			translate([-tol,-nema_side_len/2 + 10, base_th]) cube([reduc_len+2*tol,slit_th,slit_th]);
			translate([-tol,-nema_side_len/2 + 10, 10]) cube([reduc_len+2*tol,slit_th,slit_th]);
		}
		hull()
		{
			translate([-tol,-nema_side_len/2 + 10, base_th]) cube([reduc_len+2*tol,slit_th,slit_th]);
			translate([-tol,-nema_side_len/2 - 10, base_th]) cube([reduc_len+2*tol,slit_th,slit_th]);
		}
		
	}
}


ring_body();
