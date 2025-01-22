#import <Foundation/Foundation.h>
#import "include/LibSpatialite.h"

void setupSpatialite(sqlite3 *db_handle){
  // spatialite_init(0);
  puts("SpatiaLite integrated");

  const void *ptr;
  int verbose;

  spatialite_init_ex (db_handle, ptr, verbose);
}
