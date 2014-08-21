//
//  PJCDetailViewController.h
//  ProgrammingTest
//
//  Created by PJ Cabrera on 8/19/14.
//  Copyright (c) 2014 PJ Cabrera. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PJCEntities.h"

@protocol PJCDetailItemViewController <NSObject>

- (void)setDetailItem:(id)newDetailItem;

@end

@interface PJCDetailViewController : UITabBarController <PJCDetailItemViewController>

@property (strong, nonatomic) PJCRoute *detailItem;

@end
