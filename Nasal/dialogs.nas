#var EFB = gui.Dialog.new("/sim/gui/dialogs/EFB/dialog",
#        "Aircraft/A340-313X/Systems/EFB-dlg.xml");
var Radio = gui.Dialog.new("/sim/gui/dialogs/radios/dialog",
        "Aircraft/A340-313X/Systems/tranceivers.xml");
var ap_settings = gui.Dialog.new("/sim/gui/dialogs/autopilot/dialog",
        "Aircraft/A340-313X/Systems/autopilot-dlg.xml");
var tiller_steering = gui.Dialog.new("/sim/gui/dialogs/tiller_steering/dialog",
		"Aircraft/A340-313X/Systems/tiller_steering.xml");
var yokechart = gui.Dialog.new("/sim/gui/dialogs/yokechart/dialog",
		"Aircraft/A340-313X/Dialogs/yokechart-dialog.xml");

gui.menuBind("radio", "dialogs.Radio.open()");
gui.menuBind("autopilot-settings", "dialogs.ap_settings.open()");
