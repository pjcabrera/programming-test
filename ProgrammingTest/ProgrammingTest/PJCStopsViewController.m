//
//  PJCStopsViewController.m
//  ProgrammingTest
//
//  Created by PJ Cabrera on 8/20/14.
//  Copyright (c) 2014 PJ Cabrera. All rights reserved.
//

#import "PJCStopsViewController.h"

#import "RestKit/RestKit.h"

@interface PJCStopsViewController ()

@property (strong, nonatomic) NSMutableArray *objects;
@property (strong, nonatomic) NSMutableArray *stops;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation PJCStopsViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Request the list of stops for this item
        [self sendRouteStopsRequest:_detailItem.routeId];
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
    NSDate *object = self.objects[indexPath.row];
    cell.textLabel.text = [object description];
    return cell;
}

#pragma - Private methods

- (void)sendRouteStopsRequest:(NSNumber *)routeId {
    //RKLogConfigureByName("*", RKLogLevelTrace);
    
    // map JSON elements to object properties
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[PJCStop class]];
    [mapping addAttributeMappingsFromDictionary:@{
        @"id"               : @"stopId",
        @"name"             : @"name",
        @"sequence"         : @"sequence",
        @"route_id"         : @"routeId",
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
            id comparator = ^NSComparisonResult(PJCStop *obj1, PJCStop *obj2) {
                return [obj1.sequence compare:obj2.sequence];
            };
            self.stops = [[mappingResult array] sortedArrayUsingComparator:comparator].mutableCopy;
            self.objects = [self.stops valueForKeyPath:@"name"];
            [self.tableView reloadData];
        }
        else {
            NSLog(@"findStopsByRouteId returned an empty rows array");
            
            NSString *message = @"Server did not return any stops";
            
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
        NSLog(@"Failure requesting findStopsByRouteId: %@", error.description);
        
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
                         path:@"/v1/queries/findStopsByRouteId/run"
                   parameters:nil
                      success:successBlock
                      failure:failureBlock];
}

@end
