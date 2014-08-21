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

@interface PJCSearchByRouteIdRequest : NSObject

@property (nonatomic, strong) PJCParamRouteId *params;

@end

@interface PJCRoute : NSObject

@property (nonatomic, copy) NSNumber *routeId;
@property (nonatomic, copy) NSString *shortName;
@property (nonatomic, copy) NSString *longName;
@property (nonatomic, copy) NSDate   *lastModifiedDate;
@property (nonatomic, copy) NSString *agencyId;

@end

@interface PJCStop : NSObject

@property (nonatomic, copy) NSNumber *stopId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSNumber *sequence;
@property (nonatomic, copy) NSNumber *routeId;

@end


@interface PJCDeparture : NSObject

@property (nonatomic, copy) NSNumber *departureId;
@property (nonatomic, copy) NSString *calendar;
@property (nonatomic, copy) NSString *time;

@end
