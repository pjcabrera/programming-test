//
//  PJCDeparturesViewController.h
//  ProgrammingTest
//
//  Created by PJ Cabrera on 8/20/14.
//  Copyright (c) 2014 PJ Cabrera. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PJCDetailViewController.h"
#import "PJCEntities.h"

@interface PJCDeparturesViewController : UIViewController <PJCDetailItemViewController>

@property (strong, nonatomic) PJCRoute *detailItem;

@end
