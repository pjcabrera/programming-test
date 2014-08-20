//
//  PJCDetailViewController.h
//  ProgrammingTest
//
//  Created by PJ Cabrera on 8/19/14.
//  Copyright (c) 2014 PJ Cabrera. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PJCDetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
