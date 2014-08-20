//
//  PJCEntities.h
//  ProgrammingTest
//
//  Created by PJ Cabrera on 8/20/14.
//  Copyright (c) 2014 PJ Cabrera. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PJCParamRouteId : NSObject

@property (nonatomic, strong) NSNumber *routeId;

@end

@interface PJCParamStopName : NSObject

@property (nonatomic, strong) NSString *stopName;

@end

@interface PJCSearchByStopNameRequest : NSObject

@property (nonatomic, strong) PJCParamStopName *params;

@end

@interface PJCRoute : NSObject

@property (nonatomic, copy) NSString *routeId;
@property (nonatomic, copy) NSString *shortName;
@property (nonatomic, copy) NSString *longName;
@property (nonatomic, copy) NSDate   *lastModifiedDate;
@property (nonatomic, copy) NSString *agencyId;

@end
