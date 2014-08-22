//
//  PJCDeparturesViewController.m
//  ProgrammingTest
//
//  Created by PJ Cabrera on 8/20/14.
//  Copyright (c) 2014 PJ Cabrera. All rights reserved.
//

#import "PJCDeparturesViewController.h"

#import "RestKit/RestKit.h"

@interface PJCDeparturesViewController () <UISearchBarDelegate>

@property (strong, nonatomic) NSMutableArray *objects;
@property (strong, nonatomic) NSMutableArray *departureTimes;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;

@end

@implementation PJCDeparturesViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Request the list of stops for this item
        [self sendRouteDeparturesRequest:self.detailItem.routeId];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source & delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    NSString *time = self.objects[indexPath.row];
    cell.textLabel.text = time;
    return cell;
}

#pragma mark - UISearchBar delegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    [self showDepartureTimes];
}

#pragma mark - Private methods

- (void)showDepartureTimes {
    NSString *calendarChoice;
    switch (self.searchBar.selectedScopeButtonIndex) {
        case 1:
            calendarChoice = @"SATURDAY";
            break;
            
        case 2:
            calendarChoice = @"SUNDAY";
            break;
            
        default:
            calendarChoice = @"WEEKDAY";
            break;
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"calendar == %@", calendarChoice];
    NSMutableArray *filteredDepartureTimes = [self.departureTimes filteredArrayUsingPredicate:predicate].mutableCopy;
    [filteredDepartureTimes sortUsingComparator:^NSComparisonResult(PJCDeparture *obj1, PJCDeparture *obj2) {
        return [obj1.time compare:obj2.time];
    }];
    self.objects = [[filteredDepartureTimes valueForKeyPath:@"time"] mutableCopy];
    [self.tableView reloadData];
}

- (void)sendRouteDeparturesRequest:(NSNumber *)routeId {
    //RKLogConfigureByName("*", RKLogLevelTrace);
    
    // map JSON elements to object properties
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[PJCDeparture class]];
    [mapping addAttributeMappingsFromDictionary:@{
        @"id"               : @"departureId",
        @"calendar"         : @"calendar",
        @"time"             : @"time",
    }];
    
    // set request base URL and required headers, content type of the request, authentication
    NSURL *url = [NSURL URLWithString:@"https://api.appglu.com/"];
    RKObjectManager* objectManager = [RKObjectManager managerWithBaseURL:url];
    objectManager.requestSerializationMIMEType = RKMIMETypeJSON;
    [objectManager.HTTPClient setDefaultHeader:@"X-AppGlu-Environment" value:@"staging"];
    [objectManager.HTTPClient setAuthorizationHeaderWithUsername:@"WKD4N7YMA1uiM8V"
                                                        password:@"DtdTtzMLQlA0hk2C1Yi5pLyVIlAQ68"];
    
    // the response will return the objects we're looking for in the "rows" JSON element
    NSIndexSet *statusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    RKResponseDescriptor *responseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:mapping
                                                 method:RKRequestMethodPOST
                                            pathPattern:nil
                                                keyPath:@"rows"
                                            statusCodes:statusCodes];
    [objectManager addResponseDescriptor:responseDescriptor];
    
    // upon success, update the table view data source & reload
    id successBlock = ^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        if (mappingResult.count) {
            self.departureTimes = [mappingResult array].mutableCopy;
            [self showDepartureTimes];
        }
        else {
            NSLog(@"findDeparturesByRouteId returned an empty rows array");
            
            NSString *message = @"Server did not return any departures";
            
            UIAlertView *alert =
            [[UIAlertView alloc] initWithTitle:@"No data"
                                       message:message
                                      delegate:nil
                             cancelButtonTitle:@"OK"
                             otherButtonTitles:nil];
            [alert show];
        }
    };
    // upon failure, log the error, and display an alert view
    id failureBlock = ^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"Failure requesting findDeparturesByRouteId: %@", error.description);
        
        NSString *message =
        [NSString stringWithFormat:@"%@ %@", error.localizedDescription, error.localizedRecoverySuggestion];
        
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle:@"There's been an error"
                                   message:message
                                  delegate:nil
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil];
        [alert show];
    };
    
    // map request JSON elements to object properties
    RKObjectMapping *paramsRouteIdMapping = [RKObjectMapping requestMapping];
    [paramsRouteIdMapping addAttributeMappingsFromArray:@[@"routeId"]];
    
    RKObjectMapping *requestParamsMapping = [RKObjectMapping requestMapping];
    RKRelationshipMapping *paramsMapping =
    [RKRelationshipMapping relationshipMappingFromKeyPath:@"params"
                                                toKeyPath:@"params"
                                              withMapping:paramsRouteIdMapping];
    [requestParamsMapping addPropertyMapping:paramsMapping];
    
    RKRequestDescriptor *requestDescriptor =
    [RKRequestDescriptor requestDescriptorWithMapping:requestParamsMapping
                                          objectClass:[PJCSearchByRouteIdRequest class]
                                          rootKeyPath:nil
                                               method:RKRequestMethodPOST];
    [objectManager addRequestDescriptor:requestDescriptor];
    
    // create the search request object
    PJCSearchByRouteIdRequest *request = [PJCSearchByRouteIdRequest new];
    request.params = [PJCParamRouteId new];
    request.params.routeId = routeId;
    
    // submit the POST request to the full URL
    [objectManager postObject:request
                         path:@"/v1/queries/findDeparturesByRouteId/run"
                   parameters:nil
                      success:successBlock
                      failure:failureBlock];
}

@end
