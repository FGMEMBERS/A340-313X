#############################################################################
# A340 Autopilot Flight Director System
# adapted from Syd Adams'
#
# speed modes: THR,THR REF, IDLE,HOLD,SPD;
# roll modes : TO/GA,HDG SEL,HDG HOLD, LNAV,LOC,ROLLOUT,TRK SEL, TRK HOLD,ATT;
# pitch modes: TO/GA,ALT,V/S,VNAV PTH,VNAV SPD,VNAV ALT,G/S,FLARE,FLCH SPD,FPA;
# FPA range  : -9.9 ~ 9.9 degrees
# VS range   : -8000 ~ 6000
# ALT range  : 0 ~ 50,000
#
#############################################################################

#Usage : var afds = AFDS.new();

var AFDS = {
    new : func{
        var m = {parents:[AFDS]};

        m.spd_list=["","THR","THR REF","HOLD","IDLE","SPD"];

        m.roll_list=["","HDG SEL","HDG HOLD","LNAV","LOC","ROLLOUT",
        "TRK SEL","TRK HOLD","ATT","TO/GA"];

        m.pitch_list=["","ALT","V/S","VNAV PTH","VNAV SPD",
        "VNAV ALT","G/S","FLARE","FLCH SPD","FPA","TO/GA","CLB CON"];

        m.step=0;

        m.AFDS_node = props.globals.getNode("instrumentation/afds",1);
        m.AFDS_inputs = m.AFDS_node.getNode("inputs",1);
        m.AFDS_apmodes = m.AFDS_node.getNode("ap-modes",1);
        m.AFDS_settings = m.AFDS_node.getNode("settings",1);
        m.AP_settings = props.globals.getNode("autopilot/settings",1);

        m.AP = m.AFDS_inputs.initNode("AP",0,"BOOL");
        m.AP_disengaged = m.AFDS_inputs.initNode("AP-disengage",0,"BOOL");
        m.AP_passive = props.globals.initNode("autopilot/locks/passive-mode",1,"BOOL");
        m.AP_pitch_engaged = props.globals.initNode("autopilot/locks/pitch-engaged",1,"BOOL");
        m.AP_roll_engaged = props.globals.initNode("autopilot/locks/roll-engaged",1,"BOOL");

        m.FD = m.AFDS_inputs.initNode("FD",0,"BOOL");
        m.at1 = m.AFDS_inputs.initNode("at-armed[0]",0,"BOOL");
        m.at2 = m.AFDS_inputs.initNode("at-armed[1]",0,"BOOL");
        m.alt_knob = m.AFDS_inputs.initNode("alt-knob",0,"BOOL");
        m.autothrottle_mode = m.AFDS_inputs.initNode("autothrottle-index",0,"INT");
        m.lateral_mode = m.AFDS_inputs.initNode("lateral-index",0,"INT");
        m.vertical_mode = m.AFDS_inputs.initNode("vertical-index",0,"INT");
        m.gs_armed = m.AFDS_inputs.initNode("gs-armed",0,"BOOL");
        m.loc_armed = m.AFDS_inputs.initNode("loc-armed",0,"BOOL");
        m.vor_armed = m.AFDS_inputs.initNode("vor-armed",0,"BOOL");
        m.ias_mach_selected = m.AFDS_inputs.initNode("ias-mach-selected",0,"BOOL");
        m.hdg_trk_selected = m.AFDS_inputs.initNode("hdg-trk-selected",0,"BOOL");
        m.vs_fpa_selected = m.AFDS_inputs.initNode("vs-fpa-selected",0,"BOOL");
        m.bank_switch = m.AFDS_inputs.initNode("bank-limit-switch",0,"INT");

        m.ias_setting = m.AP_settings.initNode("target-speed-kt",250);# 100 - 399 #
        m.mach_setting = m.AP_settings.initNode("target-speed-mach",0.40);# 0.40 - 0.95 #
        m.vs_setting = m.AP_settings.initNode("vertical-speed-fpm",0); # -8000 to +6000 #
        m.hdg_setting = m.AP_settings.initNode("heading-bug-deg",360,"INT");

	m.hdg_setting_active = m.AP_settings.initNode("heading-bug-active",0,"BOOL");

        m.fpa_setting = m.AP_settings.initNode("flight-path-angle",0); # -9.9 to 9.9 #
        m.alt_setting = m.AP_settings.initNode("target-altitude-ft",10000,"DOUBLE");
        m.auto_brake_setting = m.AP_settings.initNode("autobrake",0.000,"DOUBLE");

        m.trk_setting = m.AFDS_settings.initNode("trk",0,"INT");
        m.vs_display = m.AFDS_settings.initNode("vs-display",0);
        m.fpa_display = m.AFDS_settings.initNode("fpa-display",0);
        m.bank_min = m.AFDS_settings.initNode("bank-min",-25);
        m.bank_max = m.AFDS_settings.initNode("bank-max",25);
        m.pitch_min = m.AFDS_settings.initNode("pitch-min",-10);
        m.pitch_max = m.AFDS_settings.initNode("pitch-max",20);
        m.vnav_alt = m.AFDS_settings.initNode("vnav-alt",35000);

        m.AP_roll_mode = m.AFDS_apmodes.initNode("roll-mode","TO/GA");
        m.AP_roll_arm = m.AFDS_apmodes.initNode("roll-mode-arm"," ");
        m.AP_pitch_mode = m.AFDS_apmodes.initNode("pitch-mode","TO/GA");
        m.AP_pitch_arm = m.AFDS_apmodes.initNode("pitch-mode-arm"," ");
        m.AP_speed_mode = m.AFDS_apmodes.initNode("speed-mode","");
        m.AP_annun = m.AFDS_apmodes.initNode("mode-annunciator"," ");

        m.FMS = props.globals.initNode("instrumentation/nav/slaved-to-gps");
        m.FMS.setValue(0);

        m.APl = setlistener(m.AP, func m.setAP(),0,0);
        m.APdisl = setlistener(m.AP_disengaged, func m.setAP(),0,0);
        m.Lbank = setlistener(m.bank_switch, func m.setbank(),0,0);
        m.LTMode = setlistener(m.autothrottle_mode, func m.updateATMode(),0,0);
        return m;
    },

####    Inputs    ####
###################
    input : func(mode,btn){
        var fms = 0;
        if(mode==0){
            # horizontal AP controls
            if(me.lateral_mode.getValue() ==btn) btn=0;
            if(btn==3)fms=1;
            me.lateral_mode.setValue(btn);
            me.FMS.setValue(fms);
        }elsif(mode==1){
            # vertical AP controls
            if(me.vertical_mode.getValue() ==btn) btn=0;
            if (btn==1){
                # hold current altitude
                if (me.AP.getValue())
                {
                    var alt = int((getprop("instrumentation/altimeter/indicated-altitude-ft")+50)/100)*100;
                    me.alt_setting.setValue(alt);
                } else
                    btn = 0;
            }
            if (btn==11)
            {
                    var vs_now = int(getprop("/velocities/vertical-speed-fps")*0.6)*100;
					if (vs_now>0 and vs_now<6000)
                    me.vs_setting.setValue(vs_now);
            }
            me.vertical_mode.setValue(btn);
        }elsif(mode==2){
            # throttle AP controls
            if(me.autothrottle_mode.getValue() ==btn) btn=0;
            if(getprop("position/altitude-agl-ft")<200) btn=0;
            me.autothrottle_mode.setValue(btn);
        }elsif(mode==3){
            var arm = 1-((me.loc_armed.getValue() or (4==me.lateral_mode.getValue())));
            if (btn==1){
                # toggle G/S and LOC arm
                var arm = arm or (1-(me.gs_armed.getValue() or (6==me.vertical_mode.getValue())));
                me.gs_armed.setValue(arm);
                if ((arm==0)and(6==me.vertical_mode.getValue())) me.vertical_mode.setValue(0);
            }
            me.loc_armed.setValue(arm);
            if((arm==0)and(4==me.lateral_mode.getValue())) me.lateral_mode.setValue(0);
        }
    },
###################
    setAP : func{
        var output=1-me.AP.getValue();
        var disabled = me.AP_disengaged.getValue();
        if(getprop("position/altitude-agl-ft")<200)disabled = 1;
#	if (getprop('/autopilot/route-manager/current-wp') < 0)disabled=1;
        if((disabled)and(output==0)){output = 1;me.AP.setValue(0);}
        setprop("autopilot/internal/target-pitch-deg",0);
        setprop("autopilot/internal/target-roll-deg",0);
        me.AP_passive.setValue(output);
    },
###################
    setbank : func{
        var banklimit=me.bank_switch.getValue();
        var lmt=25;
        if(banklimit>0){lmt=banklimit * 5};
        me.bank_max.setValue(lmt);
        lmt = -1 * lmt;
        me.bank_min.setValue(lmt);
    },
###################
    updateATMode : func()
    {
        var idx=me.autothrottle_mode.getValue();
        me.AP_speed_mode.setValue(me.spd_list[idx]);
    },
#################

    ap_update : func{
        var VS =getprop("velocities/vertical-speed-fps");
        var TAS =getprop("velocities/uBody-fps");
        if(TAS < 10) TAS = 10;
        if(VS < -200) VS=-200;
        if (abs(VS/TAS)<=1)
        {
          var FPangle = math.asin(VS/TAS);
          FPangle *=90;
          setprop("autopilot/internal/fpa",FPangle);
        }
        var msg=" ";
        if(me.FD.getValue())msg="FLT DIR";
        if(me.AP.getValue())msg="AP ENG";
        me.AP_annun.setValue(msg);
        var tmp = abs(me.vs_setting.getValue());
        me.vs_display.setValue(tmp);
        tmp = abs(me.fpa_setting.getValue());
        me.fpa_display.setValue(tmp);
        msg="";
        var hdgoffset = me.hdg_setting.getValue()-getprop("orientation/heading-magnetic-deg");
        if(hdgoffset < -180) hdgoffset +=360;
        if(hdgoffset > 180) hdgoffset +=-360;
        setprop("autopilot/internal/fdm-heading-bug-error-deg",hdgoffset);
        if(getprop("position/altitude-agl-ft")<200){
            me.AP.setValue(0);
            me.autothrottle_mode.setValue(0);
        }

        if(me.step==0){ ### glideslope armed ?###
            msg="";
            if(me.gs_armed.getValue()){
                msg="G/S";
                var gsdefl = getprop("instrumentation/nav/gs-needle-deflection");
                var gsrange = getprop("instrumentation/nav/gs-in-range");
                if(gsdefl< 0.5 and gsdefl>-0.5){
                    if(gsrange){
                        me.vertical_mode.setValue(6);
                        me.gs_armed.setValue(0);
                    }
                }
            }
            me.AP_pitch_arm.setValue(msg);

        }elsif(me.step==1){ ### localizer armed ? ###
            msg="";
            if(me.loc_armed.getValue()){
                msg="LOC";
                var hddefl = getprop("instrumentation/nav/heading-needle-deflection");
                if(hddefl< 8 and hddefl>-8){
                    me.lateral_mode.setValue(4);
                    me.loc_armed.setValue(0);
                }
            }
            me.AP_roll_arm.setValue(msg);

        }elsif(me.step==2){ ### check lateral modes  ###
            var idx=me.lateral_mode.getValue();
            me.AP_roll_mode.setValue(me.roll_list[idx]);
            me.AP_roll_engaged.setBoolValue(idx>0);

        }elsif(me.step==3){ ### check vertical modes  ###
            var idx=me.vertical_mode.getValue();
            var test_fpa=me.vs_fpa_selected.getValue();
            if(idx==2 and test_fpa)idx=9;
            if(idx==9 and !test_fpa)idx=2;
            if ((idx==8)or(idx==1))
            {
                # flight level change mode
                if (abs(getprop("instrumentation/altimeter/indicated-altitude-ft")-me.alt_setting.getValue())<50)
                    # within target altitude: switch to ALT HOLD mode
                    idx=1;
                else
                    # outside target altitude: change flight level
                    idx=8;
                me.vertical_mode.setValue(idx);
            }
            me.AP_pitch_mode.setValue(me.pitch_list[idx]);
            me.AP_pitch_engaged.setBoolValue(idx>0);

        }elsif(me.step==4){             ### check speed modes  ###
            if (getprop("controls/engines/engine/reverser")) {
                # auto-throttle disables when reverser is enabled
                me.autothrottle_mode.setValue(0);
            }
        }elsif(me.step==5){
			if (getprop("/autopilot/route-manager/active")){
				max_wpt=getprop("/autopilot/route-manager/route/num");
				atm_wpt=getprop("/autopilot/route-manager/current-wp");
				max_wpt-=1;
				if (getprop("/autopilot/route-manager/wp/eta")=="0:30" and getprop("/autopilot/route-manager/wp/dist")<20){
					if (getprop("/autopilot/route-manager/current-wp")<max_wpt){
						atm_wpt+=1;
						props.globals.getNode("/autopilot/route-manager/current-wp").setValue(atm_wpt);
					}
				}
				if (getprop("/autopilot/route-manager/wp/eta")=="0:30" and getprop("/autopilot/route-manager/wp/dist")<20){
					if (getprop("/autopilot/route-manager/current-wp")==max_wpt){
						atm_wpt-=1;
					}
				}
				if(getprop('/autopilot/route-manager/current-wp') < 0)  {
#					  setprop('/autopilot/route-manager/active', false);
					  setprop('/autopilot/route-manager/current-wp', 0);
				}
			}
		}elsif(me.step==6){
			ma_spd=getprop("/velocities/mach");
			banklimit=getprop("/instrumentation/afds/inputs/bank-limit-switch");
			if (banklimit==0 and ma_spd>0.85)
			lim=0;
			if (banklimit==0 and ma_spd<=0.85 and ma_spd>0.6666)
			lim=10;
			if (banklimit==0 and ma_spd<=0.6666 and ma_spd>0.5)
			lim=20;	
			if (banklimit==0 and ma_spd<=0.5 and ma_spd>0.3333)
			lim=30;
			if (banklimit==0 and ma_spd<=0.333)
			lim=35;
			if (banklimit==0){
	        props.globals.getNode("/instrumentation/afds/settings/bank-max").setValue(lim);
			lim = -1 * lim;
			props.globals.getNode("/instrumentation/afds/settings/bank-min").setValue(lim);
			}
		}

        me.step+=1;
        if(me.step>6)me.step =0;
    },
};
#####################


var afds = AFDS.new();

setlistener("/sim/signals/fdm-initialized", func {
    settimer(update_afds, 6);
    print("AFDS System ... check");
});

var lim=30;
var max_wpt=1;
var atm_wpt=1;
## setprop("/aaa/jettison", 0);
var update_afds = func {
    afds.ap_update();

settimer(update_afds, 0);
}
