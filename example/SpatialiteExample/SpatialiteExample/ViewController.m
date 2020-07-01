//
//  ViewController.m
//  SpatialiteExample
//
//  Created by 松澤 太郎 on 2020/06/30.
//  Copyright © 2020 松澤 太郎. All rights reserved.
//

#import "ViewController.h"
#import "spatialite.h"
#import "sqlite3.h"

@interface ViewController ()

@end

@implementation ViewController

sqlite3* db;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self dbOpen];
}

- (void)dbOpen {
    NSLog(@"Open Database");
    
    NSString *db_file = @"db5.sqlite";
    
    NSArray *dir_paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *document_dir = dir_paths[0];
    
    NSString *database_path = [[NSString alloc] initWithString:[document_dir stringByAppendingPathComponent:db_file]];
    
    NSFileManager *file_manager = [NSFileManager defaultManager];
    
    if ([file_manager fileExistsAtPath:database_path] == NO) {
        NSLog(@"File doesn't exist");
        const char *path = [database_path UTF8String];
        if (sqlite3_open(path, &db) == SQLITE_OK) {
            char *error;
            const char *sql_stmt = "select spatialite_version()";
            sqlite3_enable_load_extension(db, 1);
            if (sqlite3_load_extension(db, "mod_spatialite", 0, &error) == SQLITE_OK) {
                NSLog(@"OK!");
            } else {
                NSLog(@"fail!!");
            }
        }
    }
}


@end
