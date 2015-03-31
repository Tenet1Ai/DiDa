//
//  MapAnnotation.h
//  DiDa
//
//  Created by Bruce Yee on 10/30/13.
//  Copyright (c) 2013 Bruce Yee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#define REUSABLE_PIN_RED @"Red"
#define REUSABLE_PIN_GREEN @"Green"
#define REUSABLE_PIN_PURPLE @"Purple"

@interface MapAnnotation : NSObject <MKAnnotation> {
@private
    CLLocationCoordinate2D  coordinate;
    NSString                *title;
    NSString                *subtitle;
    MKPinAnnotationColor    pinColor;
}

@property (nonatomic, assign, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString  *title;
@property (nonatomic, copy) NSString  *subtitle;
@property (nonatomic, assign) MKPinAnnotationColor pinColor;

- (id) initWithCoordinates:(CLLocationCoordinate2D)paramCoordinates
                     title:(NSString*)paramTitle
                  subTitle:(NSString*)paramSubTitle;

+ (NSString *) reusableIdentifierforPinColor:(MKPinAnnotationColor)paramColor;

@end
