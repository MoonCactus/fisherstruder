// Ring holder for a nema17 reductor
// E.g.: http://www.omc-stepperonline.com/gear-ratio-51-planetary-gearbox-with-nema-17-bipolar-stepper-17hs151684spg5-p-143.html
// CC-BY-NC jeremie.francois at gmail.com July 2014
// Use two M3 16 mm screws when your support is 6 mm thick

tol= 0.05;
reduc_d= 36;
reduc_d_tol= 0.4;
wall_d_th= 2.2;
reduc_len= 14; // 23 max
nema_side_len= 42+2; // nema side len (minimum 42)
slit_th=1.2;

m3= 3;
m3_len= 8;
base_th1= 1.8;
base_th2= 3;

rounding=2.2;

dist_b_screws= nema_side_len-7;

m3_d= 3;
m3_nut_d= 6;
m3_nut_dtol= 0.3;
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
					torus(r= reduc_d/2 + wall_d_th, rnd=rounding);
					translate([0,0,reduc_len-rounding])
						torus(r= reduc_d/2 + wall_d_th, rnd=rounding);
				}
		}
		
		translate([-tol,0,reduc_d/2 + (nema_side_len-reduc_d)/2])
			rotate([0,90,0])
			{
				%cylinder(r= reduc_d/2, h= reduc_len + 2*tol);
				cylinder(r= reduc_d/2 + reduc_d_tol/2, h= reduc_len + 2*tol);
			}

		// Holes for the attachment screws
		for(y=[-1,+1]) scale([1,y,1])
		{
			translate([reduc_len/2, dist_b_screws/2, 0])
			{
				if(y>0)
					translate([0,0,-tol]) cylinder(r=m3/2, h=m3_len);
				else
				{
					// onblong hole for the nylock
					translate([0,0,-tol])
					hull()
					for(sdy=[-1,+1]) scale([1,sdy,1]) translate([0,0.6,0])
					{
						cylinder(r=m3/2+0.1, h=m3_len, $fs=0.8);
					}
				}
				translate([0,0,base_th1+base_th2+slit_th]) hull()
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
			translate([-tol,-nema_side_len/2 + 10, base_th1]) cube([reduc_len+2*tol,slit_th,slit_th]);
			translate([-tol,-nema_side_len/2 + 10, 10]) cube([reduc_len+2*tol,slit_th,slit_th]);
		}
		hull()
		{
			translate([-tol,-nema_side_len/2 + 10, base_th1]) cube([reduc_len+2*tol,slit_th,slit_th]);
			translate([-tol,-nema_side_len/2 - 10, base_th1]) cube([reduc_len+2*tol,slit_th,slit_th]);
		}
		
	}
}


ring_body();
