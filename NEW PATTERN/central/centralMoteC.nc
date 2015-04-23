/* This is the code for the Central mote for the object tracking project
Date: 08-03-2014
*/


#include"printf.h"
#include<Timer.h>
#include"messages.h"

#define TIME_SYNC 10000
#define CLOCK_TICK 100
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
	uint16_t msec=0;
	uint16_t index=0;
	uint16_t sec=0;
	uint16_t min=0;
	uint16_t hr=0;
	uint16_t level=0;
	uint16_t loopcnt=0,loopcntrw=0;
	uint16_t mote_locs[4][5]={{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0}};	
	//uint16_t rssi[5]={0,0,0,0,0};
	uint8_t pktcount=0;	
	bool busy=FALSE;
	LocData d1,d2,d3;
	
	message_t tsync_pkt;

	uint16_t getRssi(message_t *msg);
	
	event void Boot.booted()
	{
		call AMControl.start();
		call clocksend.startPeriodic(TIME_SYNC);
		call clock.startPeriodic(CLOCK_TICK);
	}
	

	
	event void clock.fired()
	{
		if(msec<1000)
		{
			msec+=CLOCK_TICK;
		}
		else if(sec<60)
		{
			sec++;
			msec=0;
			//printf("\n");
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
	}

	event void clocksend.fired()
        {
        	if(!busy)
		{	
			timesync* btrpkt=(timesync*)(call Packet.getPayload(&tsync_pkt,sizeof(timesync)));
			btrpkt->nodeid=TOS_NODE_ID;
			btrpkt->msec=msec;
			btrpkt->sec=sec;
			btrpkt->min=min;
			btrpkt->hr=hr;	
			btrpkt->level=level;
			btrpkt->index=index;		
			if(call AMSend.send(AM_BROADCAST_ADDR,&tsync_pkt,sizeof(timesync))==SUCCESS)
				busy=TRUE;
			printf("\ntime on %d  is %d:%d:%d:%d\nSend level as value as %d\n",TOS_NODE_ID,hr,min,sec,msec,level);
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
		if(len==sizeof(LocData))
		{
			LocData* btrpkt=(LocData*)payload;
			call Leds.set(0);
			pktcount++;
			if(pktcount>2)
			{
				pktcount=0;
			}
			for(loopcnt=0;loopcnt<5;loopcnt++)
			{
				if(btrpkt->loc_data[loopcnt]!=0)
				{
				mote_locs[0][loopcnt]=btrpkt->loc_data[loopcnt];
				d1.loc_data[loopcnt]=btrpkt->loc_data[loopcnt];
				mote_locs[1][loopcnt]=btrpkt->loc_sec[loopcnt];
				d1.loc_sec[loopcnt]=btrpkt->loc_sec[loopcnt];
				mote_locs[2][loopcnt]=btrpkt->loc_min[loopcnt];
				d1.loc_min[loopcnt]=btrpkt->loc_min[loopcnt];
				mote_locs[3][loopcnt]=btrpkt->msec[loopcnt];
				d1.msec[loopcnt]=btrpkt->msec[loopcnt];
				}
			}
			
			d1.nodeid=btrpkt->nodeid;
			index=btrpkt->nodeid;
			printf("\n Received the data from %d\n",btrpkt->nodeid);	
			printfflush();

			if(pktcount==3)
			{

			/*detecting algorithm*/
			for(loopcnt=0;loopcnt<5;loopcnt++)
			{
				if(d1.loc_data[loopcnt]!=0)
				{
					if(d1.loc_min[loopcnt]==d2.loc_min[loopcnt] && d1.loc_sec[loopcnt]==d2.loc_sec[loopcnt]&&d1.msec[loopcnt]==d2.msec[loopcnt] && d1.loc_min[loopcnt]==d3.loc_min[loopcnt] && d1.loc_sec[loopcnt]==d3.loc_sec[loopcnt]&&d1.msec[loopcnt]==d3.msec[loopcnt])
					{
						mote_locs[0][loopcnt]=(d1.loc_data[loopcnt]+d2.loc_data[loopcnt]+d3.loc_data[loopcnt])/3;
					}
				 else if(d1.loc_min[loopcnt]==d2.loc_min[loopcnt] && d1.loc_sec[loopcnt]==d2.loc_sec[loopcnt]&&d1.msec[loopcnt]==d2.msec[loopcnt])
					{
						mote_locs[0][loopcnt]=(d1.loc_data[loopcnt]+d2.loc_data[loopcnt])/2+1;
					}
				}
			}
			
			for(loopcnt=0;loopcnt<5;loopcnt++)
			{				
				printf("Mote %d in region %d @ %d:%d:%d\n",loopcnt+1,mote_locs[0][loopcnt],mote_locs[1][loopcnt],mote_locs[2][loopcnt],mote_locs[3][loopcnt]);
				printfflush();
			}
			}//pktcnt
		if(pktcount==1)
			d2=d1;
		if(pktcount==2)
			d3=d1;
		call Leds.set(7);
		}

		return msg;
	}
	uint16_t getRssi(message_t *msg)
	{
		call Leds.set(0);
		return (uint16_t)call CC2420Packet.getRssi(msg);
	}
}
