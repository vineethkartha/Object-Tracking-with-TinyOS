/* This is the code for the Central mote for the object tracking project
Date: 08-03-2014
*/


#include"printf.h"
#include<Timer.h>


#define TIME_SYNC 9003
typedef nx_struct MobileMote {
  nx_uint16_t nodeid;
} MobileMote;

typedef nx_struct timesync {
  nx_uint16_t nodeid;
  nx_uint16_t time;
} timesync;

module centralMoteC
{
	uses interface Boot;
	uses interface Leds;
	uses interface AMSend;
	uses interface Packet;
	uses interface AMPacket;
	uses interface Timer<TMilli> as clocksend;
	uses interface Timer<TMilli> as clock;
	uses interface SplitControl as AMControl;
	uses interface Receive;
	uses interface CC2420Packet;
}

implementation
{
	uint16_t secs=0;
	bool busy=FALSE;
	
	message_t tsync_pkt;

	uint16_t getRssi(message_t *msg);
	
	event void Boot.booted()
	{
		call AMControl.start();
		call clocksend.startPeriodic(TIME_SYNC);
		call clock.startPeriodic(1000);
	}
	

	
	event void clock.fired()
	{
		secs++;
		printf("time on %d is %d\n",TOS_NODE_ID,secs);
		printfflush();
	}

	event void clocksend.fired()
	{
		if(!busy)
		{	
			timesync* btrpkt=(timesync*)(call Packet.getPayload(&tsync_pkt,sizeof(timesync)));
			btrpkt->nodeid=TOS_NODE_ID;
			btrpkt->time=secs;
			if(call AMSend.send(AM_BROADCAST_ADDR,&tsync_pkt,sizeof(timesync))==SUCCESS)
				busy=TRUE;
			printf("Send time value as %d\n",secs);
			printfflush();
			call Leds.set(7);
		}
	}

	event void AMControl.startDone(error_t err)
	{
	}


	event void AMSend.sendDone(message_t* msg,error_t err)
	{
		if(&tsync_pkt==msg)
		{
			busy=FALSE;
			call Leds.set(0);
		}
	}	

	event void AMControl.stopDone(error_t err) { }

	event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len)
	{
			
	}
	uint16_t getRssi(message_t *msg)
	{
		call Leds.set(0);
		return (uint16_t)call CC2420Packet.getRssi(msg);
	}
}
