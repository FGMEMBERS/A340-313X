# A340 Throttle Control System by Joshua Davidson (it0uchpods/411)
# Set ATHR modes to IT-AUTOFLIGHT, and other thrust modes like MCT, TOGA and eventually TO FLEX.

setlistener("/sim/signals/fdm-initialized", func {
	setprop("/systems/thrust/state1", "MAN");
	setprop("/systems/thrust/state2", "MAN");
	setprop("/systems/thrust/state3", "MAN");
	setprop("/systems/thrust/state4", "MAN");
	setprop("/systems/thrust/at1", 0);
	setprop("/systems/thrust/at2", 0);
	setprop("/systems/thrust/at3", 0);
	setprop("/systems/thrust/at4", 0);
	print("Thrust System ... Done!")
});

setlistener("/controls/engines/engine[0]/throttle-lever", func {
	var thrr = getprop("/controls/engines/engine[0]/throttle-lever");
	if (thrr < 0.60) {
		if (getprop("/systems/thrust/at1")) {
			atoff_request();
		}
		setprop("/systems/thrust/state1", "MAN");
	} else if (thrr  >= 0.60 and thrr < 0.80) {
		setprop("/systems/thrust/at1", 1);
		setprop("/it-autoflight/at_mastersw", 1);
		setprop("/systems/thrust/state1", "ATHR");
	} else if (thrr  >= 0.80 and thrr < 0.95) {
		setprop("/systems/thrust/at1", 1);
		setprop("/it-autoflight/at_mastersw", 1);
		setprop("/controls/engines/engine[0]/throttle-fdm", 0.96);
		setprop("/systems/thrust/state1", "MCT");
	} else if (thrr >= 0.95) {
		setprop("/systems/thrust/at1", 1);
		setprop("/it-autoflight/at_mastersw", 1);
		setprop("/controls/engines/engine[0]/throttle-fdm", 1);
		setprop("/systems/thrust/state1", "TOGA");
	}
});

setlistener("/controls/engines/engine[1]/throttle-lever", func {
	var thrr = getprop("/controls/engines/engine[1]/throttle-lever");
	if (thrr < 0.60) {
		if (getprop("/systems/thrust/at2")) {
			atoff_request();
		}
		setprop("/systems/thrust/state2", "MAN");
	} else if (thrr  >= 0.60 and thrr < 0.80) {
		setprop("/systems/thrust/at2", 1);
		setprop("/it-autoflight/at_mastersw", 1);
		setprop("/systems/thrust/state2", "ATHR");
	} else if (thrr  >= 0.80 and thrr < 0.95) {
		setprop("/systems/thrust/at2", 1);
		setprop("/it-autoflight/at_mastersw", 1);
		setprop("/controls/engines/engine[1]/throttle-fdm", 0.96);
		setprop("/systems/thrust/state2", "MCT");
	} else if (thrr >= 0.95) {
		setprop("/systems/thrust/at2", 1);
		setprop("/it-autoflight/at_mastersw", 1);
		setprop("/controls/engines/engine[1]/throttle-fdm", 1);
		setprop("/systems/thrust/state2", "TOGA");
	}
});

setlistener("/controls/engines/engine[2]/throttle-lever", func {
	var thrr = getprop("/controls/engines/engine[2]/throttle-lever");
	if (thrr < 0.60) {
		if (getprop("/systems/thrust/at3")) {
			atoff_request();
		}
		setprop("/systems/thrust/state3", "MAN");
	} else if (thrr  >= 0.60 and thrr < 0.80) {
		setprop("/systems/thrust/at3", 1);
		setprop("/it-autoflight/at_mastersw", 1);
		setprop("/systems/thrust/state3", "ATHR");
	} else if (thrr  >= 0.80 and thrr < 0.95) {
		setprop("/systems/thrust/at3", 1);
		setprop("/it-autoflight/at_mastersw", 1);
		setprop("/controls/engines/engine[2]/throttle-fdm", 0.96);
		setprop("/systems/thrust/state3", "MCT");
	} else if (thrr >= 0.95) {
		setprop("/systems/thrust/at3", 1);
		setprop("/it-autoflight/at_mastersw", 1);
		setprop("/controls/engines/engine[2]/throttle-fdm", 1);
		setprop("/systems/thrust/state3", "TOGA");
	}
});

setlistener("/controls/engines/engine[3]/throttle-lever", func {
	var thrr = getprop("/controls/engines/engine[3]/throttle-lever");
	if (thrr < 0.60) {
		if (getprop("/systems/thrust/at4")) {
			atoff_request();
		}
		setprop("/systems/thrust/state4", "MAN");
	} else if (thrr  >= 0.60 and thrr < 0.80) {
		setprop("/systems/thrust/at4", 1);
		setprop("/it-autoflight/at_mastersw", 1);
		setprop("/systems/thrust/state4", "ATHR");
	} else if (thrr  >= 0.80 and thrr < 0.95) {
		setprop("/systems/thrust/at4", 1);
		setprop("/it-autoflight/at_mastersw", 1);
		setprop("/controls/engines/engine[3]/throttle-fdm", 0.96);
		setprop("/systems/thrust/state4", "MCT");
	} else if (thrr >= 0.95) {
		setprop("/systems/thrust/at4", 1);
		setprop("/it-autoflight/at_mastersw", 1);
		setprop("/controls/engines/engine[3]/throttle-fdm", 1);
		setprop("/systems/thrust/state4", "TOGA");
	}
});

# Checks if all throttles are in the MAN position, before tuning off the A/THR engage light.
var atoff_request = func {
	var state1 = getprop("/systems/thrust/state1");
	var state2 = getprop("/systems/thrust/state2");
	var state3 = getprop("/systems/thrust/state3");
	var state4 = getprop("/systems/thrust/state4");
	if ((state1 == "MAN") and (state2 == "MAN") and (state3 == "MAN") and (state4 == "MAN")) {
		setprop("/it-autoflight/at_mastersw", 0);
		setprop("/systems/thrust/at1", 0);
		setprop("/systems/thrust/at2", 0);
		setprop("/systems/thrust/at3", 0);
		setprop("/systems/thrust/at4", 0);
	}
}