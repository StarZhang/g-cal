//
//  
//  
//
//  Created by Devin Ross on 10/31/09.
//  Copyright 2009 Devin Ross. All rights reserved.
//
// Modified by rafael Chacon

#import "TapkuLibrary.h"
//#import "AddTitlePlaceEventViewController.h"
#import "AddEventViewController.h"
@class GoogleCalAppDelegate;
@interface MonthCalendar : TKCalendarMonthTableViewController<AddEventDelegate,NSFetchedResultsControllerDelegate> {
	GoogleCalAppDelegate *appDelegate;	
	@private
		NSFetchedResultsController *fetchedResultsController;
		NSManagedObjectContext *managedObjectContext;
		NSDate *selectedDate;
		int numberOfRowsForGivenDate;
		NSArray *eventsForGivenDate;
	
	
}

-(IBAction)addEvent:(id)sender;
- (BOOL)isSameDay:(NSDate *)dateOne withDate:(NSDate *)dateTwo;
@property (nonatomic, retain) NSArray *eventsForGivenDate;
@property (nonatomic, retain) NSDate *selectedDate;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;


@end
