# Airbus A340-313X
# Nasal door system
#########################

var doors =
 {
 new: func(name, transit_time)
  {
  doors[name] = aircraft.door.new("sim/model/door-positions/" ~ name, transit_time);
  },
 toggle: func(name)
  {
  doors[name].toggle();
  },
 open: func(name)
  {
  doors[name].open();
  },
 close: func(name)
  {
  doors[name].close();
  },
 setpos: func(name, value)
  {
  doors[name].setpos(value);
  }
 };
doors.new("pax-l1", 2);
doors.new("pax-l2", 2);
doors.new("pax-l4", 2);
doors.new("pax-l3", 2);
doors.new("pax-r1", 2);
doors.new("pax-r2", 2);
doors.new("pax-r4", 2);
doors.new("pax-r3", 2);
doors.new("cargo-fwd", 3);
doors.new("cargo-aft", 3);
doors.new("cargo-bulk", 3);
