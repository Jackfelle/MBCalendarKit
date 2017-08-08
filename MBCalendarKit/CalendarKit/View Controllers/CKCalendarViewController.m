//
//  CKViewController.m
//  MBCalendarKit
//
//  Created by Moshe Berman on 4/10/13.
//  Copyright (c) 2013 Moshe Berman. All rights reserved.
//

#import "CKCalendarView.h"
#import "CKCalendarEvent.h"
#import "NSCalendarCategories.h"

#import "CKCalendarViewController.h"

@interface CKCalendarViewController () <CKCalendarViewDataSource, CKCalendarViewDelegate>

/**
 The calendar view used in the view controller.
 */
@property (nonatomic, strong) CKCalendarView *calendarView;

/**
 A control that allows users to choose between month, week, and day modes.
 */
@property (nonatomic, strong) UISegmentedControl *modePicker;


/**
 The events to display in the calendar.
 */
@property (nonatomic, strong) NSMutableArray *events;

@end

@implementation CKCalendarViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    /* iOS 7 hack*/
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    
    if(!self.title)
    {
        [self setTitle:NSLocalizedString(@"Calendar", @"A title for the calendar view.")];
    }
    
    /* Prepare the events array */
    
    [self setEvents:[NSMutableArray new]];
    
    [self _configureCalendarView];
    
    /* Mode Picker */
    
    NSArray *items = @[NSLocalizedString(@"Month", @"A title for the month view button."), NSLocalizedString(@"Week",@"A title for the week view button."), NSLocalizedString(@"Day", @"A title for the day view button.")];
    
    [self setModePicker:[[UISegmentedControl alloc] initWithItems:items]];
    [[self modePicker] addTarget:self action:@selector(modeChangedUsingControl:) forControlEvents:UIControlEventValueChanged];
    [[self modePicker] setSelectedSegmentIndex:0];
    
    /* Toolbar setup */
    
    NSString *todayTitle = NSLocalizedString(@"Today", @"A button which sets the calendar to today.");
    UIBarButtonItem *todayButton = [[UIBarButtonItem alloc] initWithTitle:todayTitle style:UIBarButtonItemStylePlain target:self action:@selector(todayButtonTapped:)];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:[self modePicker]];
    
    [self setToolbarItems:@[todayButton, item] animated:NO];
    [[self navigationController] setToolbarHidden:NO animated:NO];
    
    /* Remove bar translucency. */
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.toolbar.translucent = NO;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Configuring the Calendar View

- (void)_configureCalendarView
{
    self.calendarView = [[CKCalendarView alloc] init];
    self.calendarView.dataSource = self;
    self.calendarView.delegate = self;
    [self.view addSubview:self.calendarView];
    [self layoutCalendar];
}


/**
 This method sets up constraints on the calendar view.
 */

- (void)layoutCalendar
{
    self.calendarView.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:self.calendarView
                                                           attribute:NSLayoutAttributeTop
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self.topLayoutGuide
                                                           attribute:NSLayoutAttributeBottom
                                                          multiplier:1.0
                                                            constant:0.0];
    
    NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:self.calendarView
                                                             attribute:NSLayoutAttributeLeading
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeLeading
                                                            multiplier:1.0
                                                              constant:0.0];
    
    [self.view addConstraints:@[top, leading]];
}

#pragma mark - Toolbar Items

- (void)modeChangedUsingControl:(id)sender
{
    [[self calendarView] setDisplayMode:(CKCalendarDisplayMode)[[self modePicker] selectedSegmentIndex]];
}

- (void)todayButtonTapped:(id)sender
{
    [[self calendarView] setDate:[NSDate date] animated:NO];
}

#pragma mark - CKCalendarViewDataSource

- (NSArray *)calendarView:(CKCalendarView *)CalendarView eventsForDate:(NSDate *)date
{
    if ([[self dataSource] respondsToSelector:@selector(calendarView:eventsForDate:)]) {
        return [[self dataSource] calendarView:CalendarView eventsForDate:date];
    }
    return nil;
}

#pragma mark - CKCalendarViewDelegate

// Called before the selected date changes
- (void)calendarView:(CKCalendarView *)calendarView willSelectDate:(NSDate *)date
{
    if ([self isEqual:[self delegate]]) {
        return;
    }
    
    if ([[self delegate] respondsToSelector:@selector(calendarView:willSelectDate:)]) {
        [[self delegate] calendarView:calendarView willSelectDate:date];
    }
}

// Called after the selected date changes
- (void)calendarView:(CKCalendarView *)calendarView didSelectDate:(NSDate *)date
{
    if ([self isEqual:[self delegate]]) {
        return;
    }
    
    if ([[self delegate] respondsToSelector:@selector(calendarView:didSelectDate:)]) {
        [[self delegate] calendarView:calendarView didSelectDate:date];
    }
}

//  A row is selected in the events table. (Use to push a detail view or whatever.)
- (void)calendarView:(CKCalendarView *)calendarView didSelectEvent:(CKCalendarEvent *)event
{
    if ([self isEqual:[self delegate]]) {
        return;
    }
    
    if ([[self delegate] respondsToSelector:@selector(calendarView:didSelectEvent:)]) {
        [[self delegate] calendarView:calendarView didSelectEvent:event];
    }
}

#pragma mark - Calendar View

- (CKCalendarView *)calendarView
{
    return _calendarView;
}

#pragma mark - Orientation Support

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [[self calendarView] reloadAnimated:NO];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        
    }];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [[self calendarView] reloadAnimated:NO];
}

@end
