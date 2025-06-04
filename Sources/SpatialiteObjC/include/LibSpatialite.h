#ifndef LibSpatialite_h
#define LibSpatialite_h

#import <spatialite/gaiageo.h>
#import <spatialite.h>
#import <sqlite3.h>

void setupSpatialite(sqlite3 *db_handle);

// void setupSpatialite(sqlite3 *db_handle, const void *ptr, int verbose);

#endif

