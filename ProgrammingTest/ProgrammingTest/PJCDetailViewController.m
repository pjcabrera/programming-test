//
//  PJCDetailViewController.m
//  ProgrammingTest
//
//  Created by PJ Cabrera on 8/19/14.
//  Copyright (c) 2014 PJ Cabrera. All rights reserved.
//

#import "PJCDetailViewController.h"
#import "PJCDeparturesViewController.h"

@interface PJCDetailViewController ()

@end

@implementation PJCDetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Set the detail item on the tab bar's view controllers
        [self.viewControllers enumerateObjectsUsingBlock:^(id<PJCDetailItemViewController> vc, NSUInteger idx, BOOL *stop) {
            [vc setDetailItem:_detailItem];
        }];
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

@end
