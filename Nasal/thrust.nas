# A3XX Throttle Control System by Joshua Davidson (it0uchpods)
# Set A/THR modes to Custom IT-AUTOTHRUST, and other thrust modes like MCT, TOGA and eventually TO FLEX.
# Also handles FADEC
# V1.9.1

setlistener("/sim/signals/fdm-initialized", func {
	setprop("/systems/thrust/state1", "IDLE");
	setprop("/systems/thrust/state2", "IDLE");
	setprop("/systems/thrust/state3", "IDLE");
	setprop("/systems/thrust/state4", "IDLE");
	setprop("/systems/thrust/lvrclb", "0");
	setprop("/systems/thrust/clbreduc-ft", "1500");
	lvrclbt.start();
	print("FADEC ... Done!")
});

setlistener("/controls/engines/engine[0]/throttle-pos", func {
	var thrr = getprop("/controls/engines/engine[0]/throttle-pos");
	if (thrr < 0.01) {
		setprop("/systems/thrust/state1", "IDLE");
		atoff_request();
	} else if (thrr >= 0.01 and thrr < 0.60) {
		setprop("/systems/thrust/state1", "MAN");
	} else if (thrr >= 0.60 and thrr < 0.65) {
		setprop("/systems/thrust/state1", "CL");
	} else if (thrr >= 0.65 and thrr < 0.78) {
		setprop("/systems/thrust/state1", "MAN THR");
	} else if (thrr >= 0.78 and thrr < 0.83) {
		setprop("/it-autoflight/input/athr", 1);
		setprop("/controls/engines/engine[0]/throttle-fdm", 0.90);
		setprop("/systems/thrust/state1", "MCT");
	} else if (thrr >= 0.83 and thrr < 0.95) {
		setprop("/it-autoflight/input/athr", 1);
		setprop("/systems/thrust/state1", "MAN THR");
	} else if (thrr >= 0.95) {
		setprop("/it-autoflight/input/athr", 1);
		setprop("/controls/engines/engine[0]/throttle-fdm", 0.95);
		setprop("/systems/thrust/state1", "TOGA");
	}
});

setlistener("/controls/engines/engine[1]/throttle-pos", func {
	var thrr = getprop("/controls/engines/engine[1]/throttle-pos");
	if (thrr < 0.01) {
		setprop("/systems/thrust/state2", "IDLE");
		atoff_request();
	} else if (thrr >= 0.01 and thrr < 0.60) {
		setprop("/systems/thrust/state2", "MAN");
	} else if (thrr >= 0.60 and thrr < 0.65) {
		setprop("/systems/thrust/state2", "CL");
	} else if (thrr >= 0.65 and thrr < 0.78) {
		setprop("/systems/thrust/state2", "MAN THR");
	} else if (thrr >= 0.78 and thrr < 0.83) {
		setprop("/it-autoflight/input/athr", 1);
		setprop("/controls/engines/engine[1]/throttle-fdm", 0.90);
		setprop("/systems/thrust/state2", "MCT");
	} else if (thrr >= 0.83 and thrr < 0.95) {
		setprop("/it-autoflight/input/athr", 1);
		setprop("/systems/thrust/state2", "MAN THR");
	} else if (thrr >= 0.95) {
		setprop("/it-autoflight/input/athr", 1);
		setprop("/controls/engines/engine[1]/throttle-fdm", 0.95);
		setprop("/systems/thrust/state2", "TOGA");
	}
});

setlistener("/controls/engines/engine[2]/throttle-pos", func {
	var thrr = getprop("/controls/engines/engine[2]/throttle-pos");
	if (thrr < 0.02) {
		setprop("/systems/thrust/state3", "IDLE");
		atoff_request();
	} else if (thrr >= 0.01 and thrr < 0.60) {
		setprop("/systems/thrust/state3", "MAN");
	} else if (thrr >= 0.60 and thrr < 0.65) {
		setprop("/systems/thrust/state3", "CL");
	} else if (thrr >= 0.65 and thrr < 0.78) {
		setprop("/systems/thrust/state3", "MAN THR");
	} else if (thrr >= 0.78 and thrr < 0.83) {
		setprop("/it-autoflight/input/athr", 1);
		setprop("/controls/engines/engine[2]/throttle-fdm", 0.90);
		setprop("/systems/thrust/state3", "MCT");
	} else if (thrr >= 0.83 and thrr < 0.95) {
		setprop("/it-autoflight/input/athr", 1);
		setprop("/systems/thrust/state3", "MAN THR");
	} else if (thrr >= 0.95) {
		setprop("/it-autoflight/input/athr", 1);
		setprop("/controls/engines/engine[2]/throttle-fdm", 0.95);
		setprop("/systems/thrust/state3", "TOGA");
	}
});

setlistener("/controls/engines/engine[3]/throttle-pos", func {
	var thrr = getprop("/controls/engines/engine[3]/throttle-pos");
	if (thrr < 0.02) {
		setprop("/systems/thrust/state4", "IDLE");
		atoff_request();
	} else if (thrr >= 0.01 and thrr < 0.60) {
		setprop("/systems/thrust/state4", "MAN");
	} else if (thrr >= 0.60 and thrr < 0.65) {
		setprop("/systems/thrust/state4", "CL");
	} else if (thrr >= 0.65 and thrr < 0.78) {
		setprop("/systems/thrust/state4", "MAN THR");
	} else if (thrr >= 0.78 and thrr < 0.83) {
		setprop("/it-autoflight/input/athr", 1);
		setprop("/controls/engines/engine[3]/throttle-fdm", 0.90);
		setprop("/systems/thrust/state4", "MCT");
	} else if (thrr >= 0.83 and thrr < 0.95) {
		setprop("/it-autoflight/input/athr", 1);
		setprop("/systems/thrust/state4", "MAN THR");
	} else if (thrr >= 0.95) {
		setprop("/it-autoflight/input/athr", 1);
		setprop("/controls/engines/engine[3]/throttle-fdm", 0.95);
		setprop("/systems/thrust/state4", "TOGA");
	}
});

# Checks if all throttles are in the IDLE position, before tuning off the A/THR.
var atoff_request = func {
	var state1 = getprop("/systems/thrust/state1");
	var state2 = getprop("/systems/thrust/state2");
	var state3 = getprop("/systems/thrust/state3");
	var state4 = getprop("/systems/thrust/state4");
	if ((state1 == "IDLE") and (state2 == "IDLE") and (state3 == "IDLE") and (state4 == "IDLE")) {
		setprop("/it-autoflight/input/athr", 0);
	}
}

var lvrclb = func {
	var state1 = getprop("/systems/thrust/state1");
	var state2 = getprop("/systems/thrust/state2");
	var state3 = getprop("/systems/thrust/state3");
	var state4 = getprop("/systems/thrust/state4");
	if ((state1 == "CL") and (state2 == "CL") and (state3 == "CL") and (state4 == "CL")) {
		setprop("/systems/thrust/lvrclb", "0");
	} else {
		var status = getprop("/systems/thrust/lvrclb");
		if (status == 0) {
			if (getprop("/systems/thrust/state1") == "MAN" or getprop("/systems/thrust/state2") == "MAN" or getprop("/systems/thrust/state3") == "MAN" or getprop("/systems/thrust/state4") == "MAN") {
				setprop("/systems/thrust/lvrclb", "1");
			} else {
				if (getprop("/instrumentation/altimeter/indicated-altitude-ft") >= getprop("/systems/thrust/clbreduc-ft")) {
					setprop("/systems/thrust/lvrclb", "1");
				} else {
					setprop("/systems/thrust/lvrclb", "0");
				}
			}
		} else if (status == 1) {
			setprop("/systems/thrust/lvrclb", "0");
		}
	}
}

# Timers
var lvrclbt = maketimer(0.5, lvrclb);
