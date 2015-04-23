/* This is the code for the Central mote for the object tracking project
Date: 08-03-2014
*/


#define NEW_PRINTF_SEMANTICS
#include "printf.h"
#include<Timer.h>

configuration slaveMoteAppC {
} 
  implementation {
  components MainC;
  components LedsC;
  components new TimerMilliC() as clock;
  components slaveMoteC as App;
  components PrintfC;
  components SerialStartC;
  components new AMSenderC(5);
  components new AMReceiverC(5);
  components ActiveMessageC;
  components CC2420ActiveMessageC;
  

  App.Leds -> LedsC;
  App.Boot -> MainC;
  App.AMControl -> ActiveMessageC;
  App.Receive   -> AMReceiverC;
  App.Packet -> AMSenderC;
  App.AMPacket -> AMSenderC;
  App.AMSend -> AMSenderC;
  App.clock->clock;
  App -> CC2420ActiveMessageC.CC2420Packet;
}
