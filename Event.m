/*
 
 Copyright (c) 2010 Rafael Chacon
 g-Cal is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 g-Cal is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with g-Cal.  If not, see <http://www.gnu.org/licenses/>.
 */


#import "Event.h"

#import "Calendar.h"

@implementation Event 

@dynamic location;
@dynamic note;
@dynamic title;
@dynamic endDate;
@dynamic startDate;
@dynamic eventid;
@dynamic calendar;
@dynamic updated;
@dynamic editLink;
@dynamic etag;
@dynamic identifier;
@dynamic allDay;


+(Event *)getEventWithId:(NSString *)eventId forCalendar:(Calendar *)calendar andContext:(NSManagedObjectContext *) context{

	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:context];
	[request setEntity:entity];
	// retrive the objects with a given value for a certain property
	NSPredicate *predicate = [NSPredicate predicateWithFormat: @"eventid == %@ AND calendar == %@", eventId, calendar];
	[request setPredicate:predicate];
	
	// Edit the sort key as appropriate.
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"eventid" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[request setSortDescriptors:sortDescriptors];
	NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
																								managedObjectContext:context 
																								  sectionNameKeyPath:nil
																										   cacheName:@"RootEvent"];
	
	aFetchedResultsController.delegate = self;
	
	NSError *error = nil;
	NSArray *result = [context executeFetchRequest:request error:&error];
	
	[request release];
	[sortDescriptor release];
	[sortDescriptors release];
	[aFetchedResultsController release];
	if (error) return nil;
	if (error) return nil;
	if(result != nil && [result count] == 1)
		return (Event *)[result objectAtIndex:0];
	return nil;
	
	
}

+(Event *)createEventFromGCal:(GDataEntryCalendarEvent *)event forCalendar:(Calendar *)calendar withContext:(NSManagedObjectContext *)context{

	GDataWhen *when = [[event objectsForExtensionClass:[GDataWhen class]] objectAtIndex:0];
	// Note: An event might have multiple locations.  We're only displaying the first one.
	GDataWhere *addr = [[event locations] objectAtIndex:0];
	Event *anEvent;
	anEvent = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:context];
	anEvent.title = [[event title] stringValue];
	
	if( when ){
			if (![[when startTime] hasTime ]) 
			anEvent.allDay =[NSNumber numberWithBool:YES];


		anEvent.startDate =  [[when startTime] date];
		anEvent.endDate = [[when endTime] date];
	}
	
	anEvent.editLink = [[event editLink] href]; 

	anEvent.eventid = [event iCalUID];
	anEvent.updated = [[event updatedDate] date];
	anEvent.note = [[event content] stringValue];
	if( addr )
		anEvent.location =  [addr stringValue];
	anEvent.calendar = calendar;
	anEvent.etag =  [event ETag];
	
	anEvent.identifier = [event identifier];


	

	NSError *core_data_error = nil;
	if (![context save:&core_data_error]) {
		NSLog(@"Unresolved error saving a event %@, %@", core_data_error, [core_data_error userInfo]);
		return nil;
	}
	return anEvent;
	
}


-(BOOL)updateEventFromGCal:(GDataEntryCalendarEvent *)event forCalendar:(Calendar *)calendar withContext:(NSManagedObjectContext *)context{
		
	
	
	GDataWhen *when = [[event objectsForExtensionClass:[GDataWhen class]] objectAtIndex:0];
	// Note: An event might have multiple locations.  We're only displaying the first one.
	GDataWhere *addr = [[event locations] objectAtIndex:0];
	
	self.title = [[event title] stringValue];
	
	if( when ){
		if (![[when startTime] hasTime ]) 
			self.allDay =[NSNumber numberWithBool:YES];
		else 
			self.allDay =[NSNumber numberWithBool:NO];


		self.startDate =  [[when startTime] date];
		self.endDate = [[when endTime] date];
	}
	
	self.eventid = [event iCalUID];
	self.updated = [[event updatedDate] date];
	self.note = [[event content] stringValue];
	self.editLink = [[event editLink] href]; 
	self.etag = [event ETag]; 
	if( addr )
		self.location =  [addr stringValue];
	self.calendar = calendar;
	self.identifier = [event identifier];
	
	//anEvent.calendar =
	
	
	
	
	NSError *core_data_error = nil;
	if (![context save:&core_data_error]) {
		NSLog(@"Unresolved error saving a event %@, %@", core_data_error, [core_data_error userInfo]);
	
	}
	if (core_data_error) return NO;

	return YES;
	
}

-(GDataEntryCalendarEvent *)eventGDataEntry{	
	
	
	GDataEntryCalendarEvent *newEntry = [GDataEntryCalendarEvent calendarEvent];
	[newEntry setTitleWithString:self.title];
	[newEntry addLocation:[GDataWhere whereWithString:self.location]];
	if (self.startDate) {
		GDataDateTime *startDate = [GDataDateTime dateTimeWithDate:self.startDate timeZone:[NSTimeZone systemTimeZone]];
		GDataDateTime *endDate = [GDataDateTime dateTimeWithDate:self.endDate timeZone:[NSTimeZone systemTimeZone]];
		[newEntry addTime:[GDataWhen whenWithStartTime:startDate endTime:endDate]];
	}

		
	
	
	
	
	[newEntry setContentWithString:self.note];
	[newEntry setICalUID:self.eventid];
	[newEntry setETag:self.etag];
	
	return newEntry;
	
}




@end


