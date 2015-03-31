//
//  VisualStateManager.h
//  DiDa
//
//  Created by Bruce Yee on 10/18/13.
//  Copyright (c) 2013 Bruce Yee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MMDrawerVisualState.h>

typedef NS_ENUM(NSInteger, MMDrawerAnimationType){
    MMDrawerAnimationTypeNone,
    MMDrawerAnimationTypeSlide,
    MMDrawerAnimationTypeSlideAndScale,
    MMDrawerAnimationTypeSwingingDoor,
    MMDrawerAnimationTypeParallax,
};

@interface VisualStateManager : NSObject

@property (nonatomic,assign) MMDrawerAnimationType leftDrawerAnimationType;
@property (nonatomic,assign) MMDrawerAnimationType rightDrawerAnimationType;

+ (VisualStateManager *)sharedManager;

-(MMDrawerControllerDrawerVisualStateBlock)drawerVisualStateBlockForDrawerSide:(MMDrawerSide)drawerSide;

@end
