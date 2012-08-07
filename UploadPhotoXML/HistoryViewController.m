//
//  HistoryViewController.m
//  UploadPhotoXML
//
//  Created by Яблочник on 8/6/12.
//  Copyright (c) 2012 org. All rights reserved.
//

#import "HistoryViewController.h"
#import "sqlite3.h"
#import "HistoryObject.h"
#import "HistoryObjectViewController.h"

@interface HistoryViewController ()

@property (strong, nonatomic)  NSMutableArray *historyObjects;

@end

@implementation HistoryViewController
@synthesize myScroll;

-(void)loadHistory
{
    self.historyObjects = [NSMutableArray array];
    NSString *documentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    sqlite3 *historyDB;
    NSString *databasePath = [[NSString alloc] initWithString: [documentsPath stringByAppendingPathComponent: @"history.db"]];
    NSFileManager *filemgr = [NSFileManager defaultManager];
    const char *dbpath = [databasePath UTF8String];
    if ([filemgr fileExistsAtPath: databasePath ] == NO)    {
        [filemgr createFileAtPath:databasePath contents:nil attributes:nil];
		if (sqlite3_open(dbpath, &historyDB) == SQLITE_OK)         {
            char *errMsg;
            const char *sql_stmt = "CREATE TABLE IF NOT EXISTS history (ID INTEGER PRIMARY KEY AUTOINCREMENT, description TEXT, details TEXT, price TEXT, img_filename TEXT)";
            if (sqlite3_exec(historyDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)     {
                NSLog(@"Failed to create table");
            }
            sqlite3_close(historyDB);
        } else {
            NSLog(@"Failed to open/create database");
        }
    }
    else {
        if (sqlite3_open(dbpath, &historyDB) == SQLITE_OK)         {
            sqlite3_stmt *selectstmt;
            const char *sql_stmt2 = "SELECT * FROM history";
            if(sqlite3_prepare_v2(historyDB, sql_stmt2, -1, &selectstmt, NULL) == SQLITE_OK) {
                while(sqlite3_step(selectstmt) == SQLITE_ROW) {
                    HistoryObject *tmp = [[HistoryObject alloc] init];
                    tmp.Id = sqlite3_column_int(selectstmt, 0);
                    tmp.desc = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 1)];
                    tmp.detail = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 2)];
                    tmp.price = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 3)];
                    tmp.filePath = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 4)];
                    [self.historyObjects addObject:tmp];
                }
            }
            else {
                NSLog(@"Failed to read from DB");
            }
            sqlite3_close(historyDB);
        } else {
            NSLog(@"Failed to open database");
        }
    }
    
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        nibNameOrNil = [NSString stringWithFormat:@"%@%@",nibNameOrNil,@"_iPad"];
    }
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadHistory];
    
    self.myScroll.isVertical = NO;
    self.myScroll.enableCaching = NO;
    self.myScroll.dataSource = self;
    
    [self.myScroll reloadData];

    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setMyScroll:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


// CustomScrollViewProtocol protocol methods

- (int) numberOfElementsInCustomScrollView:(CustomScrollView *)sender;
{
    return self.historyObjects.count;
}

- (UIView *) customScrollView:(CustomScrollView *)sender viewAtIndex:(int)index
{
    if (index >= self.historyObjects.count)
        return nil;

    HistoryObjectViewController *vc = [[HistoryObjectViewController alloc] initWithNibName:@"HistoryObjectViewController" bundle:nil];
    
    NSString *documentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *imgPath = [[NSString alloc] initWithString:
                              [documentsPath stringByAppendingPathComponent:
                               [[self.historyObjects objectAtIndex:index] filePath]]];
    NSData *data = [NSData dataWithContentsOfFile:imgPath];
    vc.imageUI = [UIImage imageWithData:data];
    vc.descText = [[self.historyObjects objectAtIndex:index] desc];
    vc.detailText = [[self.historyObjects objectAtIndex:index] detail];
    vc.priceText = [[self.historyObjects objectAtIndex:index] price];
    
    return vc.view;
}

// end protocol methods

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
