/* All message struct declaration*/

typedef nx_struct MobileMote {
  nx_uint16_t nodeid;
} MobileMote;

typedef nx_struct LocData {
  nx_uint16_t nodeid;
  nx_uint8_t loc_data[5];
  nx_uint8_t loc_sec[5];
  nx_uint8_t loc_min[5];
  nx_uint16_t msec[5];
} LocData;

typedef nx_struct timesync {
  nx_uint16_t nodeid;
  nx_uint16_t msec;
  nx_uint16_t sec;
  nx_uint16_t min;
  nx_uint16_t hr;
  nx_uint16_t level;
  nx_uint16_t index;
} timesync;

