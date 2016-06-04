# A340 AutoFlight control logic by Joshua Davidson (it0uchpods/411).

var ap_logic_init = func {
	setprop("/controls/switches/ap_master", 0);
	setprop("/controls/switches/hdg", 1);
	setprop("/controls/switches/nav", 0);
	setprop("/controls/switches/loc", 0);
	setprop("/controls/switches/loc1", 0);
	setprop("/controls/switches/alt", 0);
	setprop("/controls/switches/vs", 0);
	setprop("/controls/switches/app", 0);
	setprop("/controls/switches/app1", 0);
	setprop("/controls/switches/aplatmode", 0);
	setprop("/controls/switches/aphldtrk", 0);
	setprop("/controls/switches/apvertmode", 3);
	setprop("/controls/switches/aphldtrk2", 0);
	print("AUTOFLIGHT LOGIC ... FINE!");
}

# AP Master System
setlistener("/controls/switches/ap_mastersw", func {
  var apmas = getprop("/controls/switches/ap_mastersw");
  if (apmas == 0) {
	setprop("/controls/switches/ap_master", 0);
    ap_off();
  } else if (apmas == 1) {
	setprop("/controls/switches/ap_master", 1);
	setprop("/controls/switches/apoffsound", 0);
    ap_refresh();
  }
});

# Master Lateral
setlistener("/controls/switches/aplatset", func {
  var latset = getprop("/controls/switches/aplatset");
  if (latset == 0) {
	setprop("/controls/switches/hdg", 1);
	setprop("/controls/switches/nav", 0);
	setprop("/controls/switches/loc", 0);
	setprop("/controls/switches/loc1", 0);
	setprop("/controls/switches/app", 0);
	setprop("/controls/switches/app1", 0);
	setprop("/controls/switches/aplatmode", 0);
	setprop("/controls/switches/aphldtrk", 0);
    hdg_master();
  } else if (latset == 1) {
	setprop("/controls/switches/hdg", 0);
	setprop("/controls/switches/nav", 1);
	setprop("/controls/switches/loc", 0);
	setprop("/controls/switches/loc1", 0);
	setprop("/controls/switches/app", 0);
	setprop("/controls/switches/app1", 0);
	setprop("/controls/switches/aplatmode", 1);
	setprop("/controls/switches/aphldtrk", 1);
    nav_master();
  } else if (latset == 2) {
	setprop("/instrumentation/nav/signal-quality-norm", 0);
	setprop("/controls/switches/hdg", 0);
	setprop("/controls/switches/nav", 0);
	setprop("/controls/switches/loc", 1);
	setprop("/controls/switches/loc1", 1);
	setprop("/controls/switches/apilsmode", 0);
  }
});

# Master Vertical
setlistener("/controls/switches/apvertset", func {
  var vertset = getprop("/controls/switches/apvertset");
  if (vertset == 0) {
	setprop("/controls/switches/alt", 1);
	setprop("/controls/switches/vs", 0);
	setprop("/controls/switches/app", 0);
	setprop("/controls/switches/app1", 0);
	setprop("/controls/switches/altc", 0);
	setprop("/controls/switches/flch", 0);
	setprop("/controls/switches/apvertmode", 0);
	setprop("/controls/switches/aphldtrk2", 0);
	setprop("/controls/switches/apilsmode", 0);
    alt_master();
  } else if (vertset == 1) {
	setprop("/controls/switches/alt", 0);
	setprop("/controls/switches/vs", 1);
	setprop("/controls/switches/app", 0);
	setprop("/controls/switches/app1", 0);
	setprop("/controls/switches/altc", 0);
	setprop("/controls/switches/flch", 0);
	setprop("/controls/switches/apvertmode", 1);
	setprop("/controls/switches/aphldtrk2", 0);
	setprop("/controls/switches/apilsmode", 0);
    vs_master();
  } else if (vertset == 2) {
	setprop("/instrumentation/nav/signal-quality-norm", 0);
	setprop("/controls/switches/hdg", 0);
	setprop("/controls/switches/nav", 0);
	setprop("/controls/switches/loc", 1);
	setprop("/controls/switches/loc1", 1);
	setprop("/instrumentation/nav/gs-rate-of-climb", 0);
	setprop("/controls/switches/alt", 0);
	setprop("/controls/switches/vs", 0);
	setprop("/controls/switches/app", 1);
	setprop("/controls/switches/app1", 1);
	setprop("/controls/switches/altc", 0);
	setprop("/controls/switches/flch", 0);
	setprop("/controls/switches/apilsmode", 1);
  } 
});

# Capture Logic
setlistener("/controls/switches/apvertset", func {
  var ap = getprop("/controls/switches/ap_master");
  var vertm = getprop("/controls/switches/apvertset");
  if (ap) {
	if (vertm == 1) {
      altcaptt.start();
    } else {
	  altcaptt.stop();
    }
  }
});

var altcapt = func {
  var calt = getprop("/instrumentation/altimeter/indicated-altitude-ft");
  var alt = getprop("/autopilot/settings/target-altitude-ft");
  var dif = calt - alt;
  if (dif < 500 and dif > -500) {
  setprop("/controls/switches/apvertset", 0);
  }
}

# Timers
var altcaptt = maketimer(0.5, altcapt);
