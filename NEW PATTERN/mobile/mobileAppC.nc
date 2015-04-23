#include<Timer.h>

configuration mobileAppC
{
}

implementation
{
	components MainC;
	components LedsC;
	components mobileC as App;
	components new TimerMilliC() as T0;
	components ActiveMessageC;
	components new AMSenderC(5);
	components CC2420ActiveMessageC;
	
	
	App.Boot-> MainC;
	App.Leds-> LedsC;
	App.T0-> T0;
	App.Packet-> AMSenderC;
	App.AMPacket->AMSenderC;
	App.AMcontrol-> ActiveMessageC;
	App.AMSend-> AMSenderC;
	App->CC2420ActiveMessageC.CC2420Packet;
}