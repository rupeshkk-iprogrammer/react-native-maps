/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "AIRMapMarkerFabric.h"

#import <React/RCTConvert+CoreLocation.h>
#import <React/RCTUIManager.h>
#import <React/UIView+React.h>
#import "AIRMapMarker.h"

#import <React/RCTViewComponentView.h>
#import <react/renderer/components/RNMapsComponents/ComponentDescriptors.h>
#import <react/renderer/components/RNMapsComponents/Props.h>
#import <react/renderer/components/RNMapsComponents/RCTComponentViewHelpers.h>
#import <react/renderer/components/RNMapsComponents/ShadowNodes.h>
#import "RCTFabricComponentsPlugins.h"
#import "RCTConvert+AirMapFabric.h"
#import <React/RCTConversions.h>

using namespace facebook::react;

@interface AIRMapMarkerFabric () <MKMapViewDelegate, RCTAIRMapMarkerViewProtocol>

@end

@implementation AIRMapMarkerFabric {
    AIRMapMarker *_marker;
}



- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        AIRMapMarker *marker = [AIRMapMarker new];
        [marker addTapGestureRecognizer];
       // marker.bridge = self.bridge;
        marker.isAccessibilityElement = YES;
        marker.accessibilityElementsHidden = NO;
        
        static const auto defaultProps = std::make_shared<const AIRMapMarkerProps>();
        _props = defaultProps;
        
        _marker = marker;
        self.contentView = marker;
    }
    return self;
}


+ (ComponentDescriptorProvider)componentDescriptorProvider
{
    return concreteComponentDescriptorProvider<AIRMapMarkerComponentDescriptor>();
}


- (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps
{
    // override with null ptr if it's inital render, and oldProps are not defined
    const auto &oldViewProps = *std::static_pointer_cast<AIRMapMarkerProps const>(_props);
    const auto &newViewProps = *std::static_pointer_cast<AIRMapMarkerProps const>(props);

    NSLog(@"updateProps");
    
    
    if (oldViewProps.coordinate.longitude != newViewProps.coordinate.longitude || oldViewProps.coordinate.latitude != newViewProps.coordinate.latitude) {
        _marker.coordinate = (CLLocationCoordinate2D) {
            newViewProps.coordinate.latitude, newViewProps.coordinate.longitude
        };
    }
    
    if (oldViewProps.identifier != newViewProps.identifier) {
        _marker.identifier = RCTNSStringFromStringNilIfEmpty(newViewProps.identifier);
    }
    
    if (oldViewProps.image != newViewProps.image) {
        // self.image = 
    }
    
    if (oldViewProps.pinColor != newViewProps.pinColor) {
        _marker.pinColor = RCTUIColorFromSharedColor(newViewProps.pinColor);
    }
    
    [super updateProps: props oldProps:oldProps];
}


@end


extern "C" {
    Class<RCTComponentViewProtocol> AIRMapMarkerCls(void)
    {
        return AIRMapMarkerFabric.class;
    }
}
