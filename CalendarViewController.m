//
//  CalendarViewController.m
//  GoogleCal
//
//  Created by Rafael Chacon on 15/06/10.
//  Copyright 2010 Universidad Simon Bolivar. All rights reserved.
//

#import "CalendarViewController.h"
#import "Calendar.h"
#import "MonthCalendar.h"
#import "GoogleCalAppDelegate.h"


@implementation CalendarViewController
@synthesize fetchedResultsController;
@synthesize managedObjectContext;
@synthesize calendarsTableView;


#pragma mark -
#pragma mark Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
	
    if (fetchedResultsController == nil) {
		
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"Calendar" inManagedObjectContext:managedObjectContext];
        [fetchRequest setEntity:entity];
        
		
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        
        [fetchRequest setSortDescriptors:sortDescriptors];
		
        NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:@"EventRoot"];
        aFetchedResultsController.delegate = self;
        self.fetchedResultsController = aFetchedResultsController;
		
		NSError *error = nil;
		if (![[self fetchedResultsController] performFetch:&error]) {
			/*
			 Replace this implementation with code to handle the error appropriately.
			 
			 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
			 */
			NSLog(@"Unresolved error fetching events MonthCalendar.m %@, %@", error, [error userInfo]);
			//abort();
		}	
		
		
        [aFetchedResultsController release];
        [fetchRequest release];
        [sortDescriptor release];
        [sortDescriptors release];
		
    }
	
	return fetchedResultsController;
}    


#pragma mark -
#pragma mark Table View dataSource delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	NSUInteger section = [indexPath section];
	if (section == 0){
	
		appDelegate.mainMonthCal.selectedCalendar = nil;
		[appDelegate.mainMonthCal allCalendars:YES];
	}
	else{
		[appDelegate.mainMonthCal allCalendars:NO];
		NSUInteger row = [indexPath row];

		section = section -1 ;
		NSIndexPath *fetchedIndex = [NSIndexPath indexPathForRow:row inSection:section];
		Calendar *aCalendar = (Calendar *)[self.fetchedResultsController objectAtIndexPath:fetchedIndex];
		appDelegate.mainMonthCal.selectedCalendar = aCalendar;
	}

	MonthCalendar *mainMonthCal = appDelegate.mainMonthCal;
	[self.navigationController pushViewController:mainMonthCal animated:YES];
		
}




#pragma mark -
#pragma mark Table View dataSource Methods

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section)
	
	{
		case 0:
			
			return @"";
			
			break;
			
		case 1:
			
			return @"Your Calendars";
			
			break;
			
	}
	return @"";
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	UITableViewCell *cell = nil;
	NSUInteger row = [indexPath row];
	NSUInteger section = [indexPath section];
	
	static NSString *kcalendarCell_ID = @"calendarCell_ID";
	cell = [tableView dequeueReusableCellWithIdentifier:kcalendarCell_ID];	
	if( cell == nil) {
		
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kcalendarCell_ID] autorelease];	
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
	}	
	

	if (section == 0) {
		cell.textLabel.text = @"All Calendars";
	}

	
	else{
		section = section -1 ;
		NSIndexPath *fetchedIndex = [NSIndexPath indexPathForRow:row inSection:section];
		Calendar *aCalendar = (Calendar *)[self.fetchedResultsController objectAtIndexPath:fetchedIndex];
		cell.textLabel.text = aCalendar.name;

	}


	
	return cell;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger count = [[fetchedResultsController sections] count];
    
	if (count == 0) {
		count = 1;
	}
	count++;
	
    return count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = 1;

//		
//	
	if (section == 1){
		section = section -1 ;
	
		if ([[fetchedResultsController sections] count] > 0) {
			id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
			numberOfRows = [sectionInfo numberOfObjects];
			
		}
		
	}
    
   return numberOfRows;
}



#pragma mark -
#pragma mark UIViewController functions
- (void)viewWillAppear:(BOOL)animated
{
	// this UIViewController is about to re-appear, make sure we remove the current selection in our table view
	NSIndexPath *tableSelection = [self.calendarsTableView indexPathForSelectedRow];
	[self.calendarsTableView deselectRowAtIndexPath:tableSelection animated:YES];
}



- (void)viewDidLoad {
	self.title = @"Calendars";
	
	appDelegate = [[UIApplication sharedApplication] delegate];
	
	
	NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error]) {
		/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
		 */
		NSLog(@"Unresolved error fetching calendars %@, %@", error, [error userInfo]);
		abort();
	}
	
    [super viewDidLoad];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	
}

- (void)viewDidUnload {
	self.managedObjectContext = nil;
	self.fetchedResultsController = nil;

}


- (void)dealloc {
	[managedObjectContext release];
	[fetchedResultsController release];
    [super dealloc];
}


@end
