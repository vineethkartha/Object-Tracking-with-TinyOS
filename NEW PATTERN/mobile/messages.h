/* All message struct declaration*/

typedef nx_struct MobileMote {
  nx_uint16_t nodeid;
} MobileMote;

typedef nx_struct LocData {
  nx_uint16_t nodeid;
  nx_uint16_t sec;
  nx_uint16_t min;
  nx_uint16_t hr;
  nx_uint16_t loc_data[5];
} LocData;

typedef nx_struct timesync {
  nx_uint16_t nodeid;
  nx_uint16_t msec;
  nx_uint16_t sec;
  nx_uint16_t min;
  nx_uint16_t hr;
  nx_uint16_t level;
} timesync;

