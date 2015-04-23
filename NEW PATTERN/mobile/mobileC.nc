/* This is the code for the mobile motes for the objet tracking project
Date: 23-02-2014
*/

#include<Timer.h>
#include"messages.h"

#define TIME 300


module mobileC
{
	uses
	{
		interface Leds;
		interface Boot;
		interface AMSend;
		interface Timer<TMilli> as T0;
		interface Packet;
		interface AMPacket;
		interface SplitControl as AMcontrol;
		interface CC2420Packet;
	}
}
	implementation
	{
		message_t pkt;
		bool busy=FALSE;
		event void Boot.booted()
		{
			call AMcontrol.start();
		}

		event void AMcontrol.startDone(error_t err)
		{
			if(err==SUCCESS)
			{
				call T0.startPeriodic(TIME);
			}
			else
			{
				call AMcontrol.start();
			}
		}

		event void AMcontrol.stopDone(error_t err)
		{
		}
		
		event void T0.fired()
		{
			if(!busy)
			{
				MobileMote* sig=(MobileMote*)(call Packet.getPayload(&pkt,sizeof(MobileMote)));
				if(sig==NULL)
					return;
				sig->nodeid=TOS_NODE_ID;
				call CC2420Packet.setPower(&pkt,3);	
				if(call AMSend.send(AM_BROADCAST_ADDR,&pkt,sizeof(MobileMote))==SUCCESS)
					busy=TRUE;
				call Leds.set(7);
			}
		}
		
		event void AMSend.sendDone(message_t* msg, error_t err)
		{
			call Leds.set(0);
			if(&pkt==msg)
			busy=FALSE;
		}
	}
