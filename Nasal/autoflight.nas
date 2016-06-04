# A340 AutoFlight system by Joshua Davidson (it0uchpods/411).

var ap_init = func {
	ap_logic_init();
	setprop("/controls/switches/aplatset", 0);
	setprop("/controls/switches/apvertset", 0);
	setprop("/autopilot/settings/target-speed-kt", 100);
	setprop("/autopilot/settings/target-mach", 0.68);
	setprop("/autopilot/settings/heading-bug-deg", 360);
	setprop("/autopilot/settings/target-altitude-ft", 10000);
	setprop("/autopilot/settings/vertical-speed-fpm", 0);
	update_arms();
	ap_refresh();
	print("AUTOFLIGHT ... FINE!");
}

var update_arms = func {
  update_locarmelec();
  update_apparmelec();

  settimer(update_arms, 0.5);
}

var update_locarmelec = func {
  var ap = getprop("/controls/switches/ap_master");
  var loc1 = getprop("/controls/switches/loc1");
  if (loc1 & ap) {
  locarmcheck();
  } else {
  return 0;
  }
}

var update_apparmelec = func {
  var ap = getprop("/controls/switches/ap_master");
  var app1 = getprop("/controls/switches/app1");
  if (app1 & ap) {
  apparmcheck();
  } else {
  return 0;
  }
}

var hdg_master = func {
	var ap = getprop("/controls/switches/ap_master");
	var hdg = getprop("/controls/switches/hdg");
	if (hdg & ap) {
		setprop("/autopilot/locks/heading", "dg-heading-hold");
		setprop("/controls/switches/loc1", 0);
	} else {
		return 0;
	}
}

var nav_master = func {
	var ap = getprop("/controls/switches/ap_master");
	var nav = getprop("/controls/switches/nav");
	if (nav & ap) {
		setprop("/autopilot/locks/heading", "true-heading-hold");
		setprop("/controls/switches/loc1", 0);
	} else {
		return 0;
	}
}

var locarmcheck = func {
	var locdefl = getprop("instrumentation/nav/heading-needle-deflection-norm");
	if ((locdefl < 0.9233) and (getprop("instrumentation/nav/signal-quality-norm") > 0.99)) {
		setprop("/autopilot/locks/heading", "nav1-hold");
		setprop("/controls/switches/loc1", 0);
		setprop("/controls/switches/aplatmode", 2);
		setprop("/controls/switches/aphldtrk", 1);
	} else {
		return 0;
	}
}

var alt_master = func {
	var ap = getprop("/controls/switches/ap_master");
	var alt = getprop("/controls/switches/alt");
	if (alt & ap) {
		setprop("/autopilot/locks/altitude", "altitude-hold");
		setprop("/controls/switches/app1", 0);
	} else {
		return 0;
	}
}

var vs_master = func {
	var ap = getprop("/controls/switches/ap_master");
	var vs = getprop("/controls/switches/vs");
	if (vs & ap) {
		setprop("/autopilot/locks/altitude", "vertical-speed-hold");
		setprop("/controls/switches/app1", 0);
	} else {
		return 0;
	}
}

var apparmcheck = func {
	var signal = getprop("/instrumentation/nav/gs-needle-deflection-norm");
	if (signal <= -0.000000001) {
		setprop("/autopilot/locks/altitude", "gs1-hold");
		setprop("/controls/switches/app1", 0);
		setprop("/controls/switches/apvertmode", 2);
		setprop("/controls/switches/aphldtrk2", 1);
	} else {
		return 0;
	}
}

var ap_refresh = func {
	hdg_master();
	nav_master();
	alt_master();
	vs_master();
}

var ap_off = func {
	var ap = getprop("/controls/switches/ap_master");
	setprop("/controls/switches/ap_master", 0);
	setprop("/autopilot/locks/heading", 0);
	setprop("/autopilot/locks/altitude", 0);
	setprop("/controls/switches/apoffsound", 1);
	hdg_master();
	nav_master();
	alt_master();
	vs_master();
}