//
//  PJCMasterViewController.m
//  ProgrammingTest
//
//  Created by PJ Cabrera on 8/19/14.
//  Copyright (c) 2014 PJ Cabrera. All rights reserved.
//

#import "PJCMasterViewController.h"

#import "PJCDetailViewController.h"
#import "RestKit/RestKit.h"
#import "PJCEntities.h"

@interface PJCMasterViewController () <UISearchBarDelegate>

@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) NSMutableArray *objects;

@end

@implementation PJCMasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
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

#pragma mark - UISearchBar delegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self sendSearchRequest:searchBar.text];
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

    PJCRoute *route = self.objects[indexPath.row];
    cell.textLabel.text = [route longName];
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.searchBar resignFirstResponder];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        PJCRoute *route = self.objects[indexPath.row];
        [[segue destinationViewController] setDetailItem:route];
    }
}

#pragma mark - Private methods

- (void)sendSearchRequest:(NSString *)searchTerm {
    
    //RKLogConfigureByName("*", RKLogLevelTrace);

    // map JSON elements to object properties
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[PJCRoute class]];
    [mapping addAttributeMappingsFromDictionary:@{
        @"id"               : @"routeId",
        @"shortName"        : @"shortName",
        @"longName"         : @"longName",
        @"lastModifiedDate" : @"lastModifiedDate",
        @"agencyId"         : @"agencyId",
    }];
    
    // set request base URL and required headers, content type of the request, authentication
    NSURL *url = [NSURL URLWithString:@"https://api.appglu.com/"];
    RKObjectManager* objectManager = [RKObjectManager managerWithBaseURL:url];
    [objectManager.HTTPClient setDefaultHeader:@"X-AppGlu-Environment" value:@"staging"];
    [objectManager.HTTPClient setDefaultHeader:@"Content-Type" value:@"application/json;charset=UTF-8"];
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
            self.objects = [mappingResult array].mutableCopy;
            [self.tableView reloadData];
        }
    };
    // upon failure, log the error, and display an alert view
    id failureBlock = ^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"Failure requesting findRoutesByStopName: %@", error.description);
        
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
    
    // create the search request object
    PJCSearchByStopNameRequest *request = [PJCSearchByStopNameRequest new];
    request.params = [PJCParamStopName new];
    request.params.stopName = [NSString stringWithFormat:@"%%%@%%", searchTerm.lowercaseString];

    // submit the POST request to the full URL
    [objectManager postObject:request
                         path:@"/v1/queries/findRoutesByStopName/run"
                   parameters:nil
                      success:successBlock
                      failure:failureBlock];
}

@end
