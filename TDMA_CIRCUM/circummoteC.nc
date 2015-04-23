/* This is the code for the Central mote for the object tracking project
Date: 08-03-2014
*/

#include"nodeids.h"
#include"printf.h"
#include<Timer.h>


#define TIME_SYNC 10000
#define TIME_INC 100

typedef nx_struct MobileMote {
  nx_uint16_t nodeid;
} MobileMote;

typedef nx_struct timesync {
  nx_uint16_t nodeid;
  nx_uint16_t msec;
  nx_uint16_t sec;
  nx_uint16_t min;
  nx_uint16_t hr;
} timesync;

typedef nx_struct tdma {
  nx_uint16_t nodeid;
  nx_uint16_t data;
} tdma;


module circummoteC
{
	uses interface Boot;
	uses interface Leds;
	uses interface AMSend;
	uses interface Packet;
	uses interface AMPacket;
	uses interface Timer<TMilli> as clock;
	uses interface SplitControl as AMControl;
	uses interface Receive;
	uses interface CC2420Packet;
}

implementation
{
	uint16_t msec=0;
	uint16_t sec=0;
	uint16_t min=0;
	uint16_t hr=0;
	uint16_t mob=0;

	bool busy=FALSE;
	
	message_t tsync_pkt;

	uint16_t getRssi(message_t *msg);
	
	event void Boot.booted()
	{
		call AMControl.start();
		call clock.startPeriodic(1000);
	}
	

	
	event void clock.fired()
	{
		if(msec<1000)
		{
			msec+=TIME_INC;
		}
		else if(sec<60)
		{
			sec++;
			msec=0;
		}
		else if(min<60)
		{
			min++;
			sec=0;
			msec=0;
		}
		else
		{
			hr++;
			min=0;
			sec=0;
			msec=0;
		}
		printf("time on %d  is %d:%d:%d:%d\n",TOS_NODE_ID,hr,min,sec,msec);
		printfflush();
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
		if(len==sizeof(timesync))
			{
				timesync* btrpkt=(timesync*)payload;
				if(btrpkt ->nodeid==CENTRAL)
				{
					printf("time on %d  is %d:%d:%d:%d\n",TOS_NODE_ID,hr,min,sec,msec);
					printfflush();
					msec=btrpkt->msec;
					sec=btrpkt->sec;
					min=btrpkt->min;

				}
				
			}
                 if(len==sizeof(tdma))
			{
				tdma* btrpkt=(tdma*)payload;
				if(btrpkt ->nodeid==TOS_NODE_ID)
				{
					if(!busy)
		                          {	
			                  tdma* btrpkt=(tdma*)(call Packet.getPayload(&tsync_pkt,sizeof(tdma)));
			                  btrpkt->nodeid=TOS_NODE_ID;
					  btrpkt->data=mob;
			                  if(call AMSend.send(CENTRAL,&tsync_pkt,sizeof(tdma))==SUCCESS)
                                          printf("I will send my node id\n ");
				          busy=TRUE;
			                  call Leds.set(7);
					  mob=0;
		                          }
				}
				
			}
		if(len==sizeof(MobileMote))
			{
				MobileMote* btrpkt=(MobileMote*)payload;
				mob=btrpkt->nodeid;
				
			}
		return msg;
	}
	uint16_t getRssi(message_t *msg)
	{
		call Leds.set(0);
		return (uint16_t)call CC2420Packet.getRssi(msg);
	}
}
