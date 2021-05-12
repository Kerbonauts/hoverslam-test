set throttle to 1.
rcs on.
gear on.
print "staging at" + missionTime.
stage.
set runmode to 1.
set radarOffset to 9.184.	 			
lock trueRadar to alt:radar - radarOffset.			
lock g to constant:g * body:mass / body:radius^2.		
lock maxDecel to (ship:availablethrust / ship:mass) - g.
lock stopDist to ship:verticalspeed^2 / (2 * maxDecel).		
lock idealThrottle to stopDist / trueRadar.			
lock impactTime to trueRadar / abs(ship:verticalspeed).

until runmode = 0{
    sas on.
    if(ship:altitude > 300){
        lock throttle to 0.
    
parameter defaultRadarOffset is 7, gearDeployTime is 6.

clearscreen.

if defaultRadarOffset <> 7
{
	set radarOffset to defaultRadarOffset.
}

if abs(ship:verticalspeed) < 1
{
	set radarOffset to alt:radar.	 							
} else if radarOffset = 0 {
	set radarOffset to defaultRadarOffset.
	print "Warning : pilot engaged while in flight, radar offset will be set to 7 (XASR-3).".
}
if addons:tr:available and addons:tr:hasimpact
{
	lock impactDist to addons:tr:impactpos:distance.
} else {
	lock impactDist to alt:radar - radarOffset.
}

lock g to constant:g * body:mass / body:radius^2.						
lock shipVel to ship:velocity:surface:mag.								
lock maxDecel to (ship:availablethrust / ship:mass) - g.				
lock stopDist to ship:velocity:surface:sqrmagnitude / (2 * maxDecel).	
lock idealThrottle to stopDist / impactDist.							
lock impactTime to impactDist / abs(shipVel).							

print "Radar offset : " at (0, terminal:width).
print radarOffset at (16, terminal:width).


when ship:verticalspeed < -1 then
{
	print "Preparing for autolanding...".

	rcs on.
	sas off.
	brakes on.
	lock steering to srfretrograde.

	when impactTime < gearDeployTime then
	{
		gear on.
	}

	when impactDist < stopDist then
	{
		print "Performing autolanding".

		print idealThrottle.
		print shipVel.
		print stopDist.

		lock throttle to idealThrottle.

		when ship:groundspeed < 1 and ship:verticalspeed < 5 then
		{
			lock steering to Up.
			print "Vessel verticalized.".
		}

		when impactTime < 2 then
		{
			lock impactDist to  alt:radar - radarOffset.
			print "Precision approach phase. Impact in 2s.".
		}

		when ship:status = "LANDED" then
		{
			print "Autolanding completed".
			set ship:control:pilotmainthrottle to .5.
            wait .5.
            set ship:control:pilotmainthrottle to 0.
			unlock steering.
			rcs off.
			sas on.
		}
	}
}

UNTIL ship:status = "LANDED"
{
	print "SRF VEL  :   " + round(shipVel, 4)			 + " m/s              " at (0, terminal:height - 11).
	print "HOR VEL  :   " + round(ship:groundspeed, 4)	 + " m/s              " at (0, terminal:height - 10).
	print "VERT VEL :   " + round(ship:verticalspeed, 4) + " m/s              " at (0, terminal:height - 9).
	print "DESC RATE:   " + round( abs(ship:verticalspeed/ship:groundspeed), 2) + "              " at (0, terminal:height - 8).

	print "IMPACT           :   T+"	+ round(impactTime, 3)	+ " s              " 	at (0, terminal:height - 6).
	print "IMPACT DIST      :   "	+ round(impactDist, 2)	+ " m              " 	at (0, terminal:height - 5).
	print "MAX DECEL        :   "	+ round(maxDecel, 5)	+ " m/s²              " at (0, terminal:height - 4).
	print "S. BURN DIST     :   "	+ round(stopDist, 2)	+ " m              " 	at (0, terminal:height - 3).

	print "THROTTLE :   " + round(idealThrottle*100,2) + " %              " at (0, terminal:height - 1).

	WAIT 0.01.
}
    }
}
