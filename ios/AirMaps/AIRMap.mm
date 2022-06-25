/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "AIRMap.h"
#import <React/RCTViewComponentView.h>
#import <React/RCTEventDispatcher.h>
#import <React/UIView+React.h>
#import "AIRMapMarker.h"
#import "AIRMapPolyline.h"
#import "AIRMapPolygon.h"
#import "AIRMapCircle.h"
#import <QuartzCore/QuartzCore.h>
#import "AIRMapUrlTile.h"
#import "AIRMapWMSTile.h"
#import "AIRMapLocalTile.h"
#import "AIRMapOverlay.h"


#import <react/renderer/components/RNMapsComponents/ComponentDescriptors.h>
#import <react/renderer/components/RNMapsComponents/Props.h>
#import <react/renderer/components/RNMapsComponents/RCTComponentViewHelpers.h>
#import <react/renderer/components/RNMapsComponents/ShadowNodes.h>
#import "RCTFabricComponentsPlugins.h"
#import "RCTConvert+AirMapFabric.h"
#import <React/RCTConversions.h>
#import <React/RCTViewComponentView.h>

using namespace facebook::react;

const CLLocationDegrees AIRMapDefaultSpan = 0.005;
const NSTimeInterval AIRMapRegionChangeObserveInterval = 0.1;
const CGFloat AIRMapZoomBoundBuffer = 0.01;
const NSInteger AIRMapMaxZoomLevel = 20;


@interface MKMapView (UIGestureRecognizer)

// this tells the compiler that MKMapView actually implements this method
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch;

@end

@interface AIRMap () <RCTAIRMapViewProtocol, RCTComponentViewProtocol>

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, assign) NSNumber *shouldZoomEnabled;
@property (nonatomic, assign) NSNumber *shouldScrollEnabled;

- (void)updateScrollEnabled;
- (void)updateZoomEnabled;

@end

@implementation AIRMap
{
    UIView *_legalLabel;
    CLLocationManager *_locationManager;
    BOOL _initialRegionSet;
    BOOL _initialCameraSet;

    // Array to manually track RN subviews
    //
    // AIRMap implicitly creates subviews that aren't regular RN children
    // (SMCalloutView injects an overlay subview), which otherwise confuses RN
    // during component re-renders:
    // https://github.com/facebook/react-native/blob/v0.16.0/React/Modules/RCTUIManager.m#L657
    //
    // Implementation based on RCTTextField, another component with indirect children
    // https://github.com/facebook/react-native/blob/v0.16.0/Libraries/Text/RCTTextField.m#L20
    NSMutableArray<UIView *> *_reactSubviews;
}

+ (ComponentDescriptorProvider)componentDescriptorProvider
{
    return concreteComponentDescriptorProvider<AIRMapComponentDescriptor>();
}

- (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps
{
    // override with null ptr if it's inital render, and oldProps are not defined
    const auto &oldViewProps = oldProps != nullptr ? *std::static_pointer_cast<AIRMapProps const>(oldProps):*std::make_shared<AIRMapProps const>();
    const auto &newViewProps = *std::static_pointer_cast<AIRMapProps const>(props);

    NSLog(@"updateProps");
    
    
    if (oldViewProps.initialRegion.latitude != newViewProps.initialRegion.latitude ||
        oldViewProps.initialRegion.longitude != newViewProps.initialRegion.longitude ||
        oldViewProps.initialRegion.latitudeDelta != newViewProps.initialRegion.latitudeDelta || oldViewProps.initialRegion.longitudeDelta != newViewProps.initialRegion.longitudeDelta) {
       
        BOOL originalIgnore = self.ignoreRegionChanges;
        self.ignoreRegionChanges = YES;
        [self setInitialRegion: [RCTConvert MKCoordinateInitalRegionFabric:newViewProps.initialRegion]];
        self.ignoreRegionChanges = originalIgnore;
    }
    
    if (oldViewProps.region.latitude != newViewProps.region.latitude ||
        oldViewProps.region.longitude != newViewProps.region.longitude ||
        oldViewProps.region.latitudeDelta != newViewProps.region.latitudeDelta || oldViewProps.region.longitudeDelta != newViewProps.region.longitudeDelta) {
       
        BOOL originalIgnore = self.ignoreRegionChanges;
        self.ignoreRegionChanges = YES;
        [self setRegion:[RCTConvert MKCoordinateRegionFabric:newViewProps.region] animated:NO];
        self.ignoreRegionChanges = originalIgnore;
    }
    //RCT_EXPORT_VIEW_PROPERTY(isAccessibilityElement, BOOL)
   
    //RCT_REMAP_VIEW_PROPERTY(testID, accessibilityIdentifier, NSString)
    if (oldViewProps.testId != newViewProps.testId) {
        self.accessibilityIdentifier = RCTNSStringFromStringNilIfEmpty(newViewProps.testId);
    }
    //RCT_EXPORT_VIEW_PROPERTY(showsUserLocation, BOOL)
    if (oldViewProps.showsUserLocation != newViewProps.showsUserLocation) {
        self.showsUserLocation = newViewProps.showsUserLocation;
    }
    // RCT_EXPORT_VIEW_PROPERTY(tintColor, UIColor)
    if (oldViewProps.tintColor != newViewProps.tintColor) {
        self.tintColor = RCTUIColorFromSharedColor(newViewProps.tintColor);
    }
    // RCT_EXPORT_VIEW_PROPERTY(userLocationAnnotationTitle, NSString)
    if (oldViewProps.userLocationAnnotationTitle != newViewProps.userLocationAnnotationTitle) {
        self.userLocationAnnotationTitle = RCTNSStringFromStringNilIfEmpty(newViewProps.userLocationAnnotationTitle);
    }
    // RCT_EXPORT_VIEW_PROPERTY(userInterfaceStyle, NSString)
    if (oldViewProps.userInterfaceStyle != newViewProps.userInterfaceStyle) {
        self.userInterfaceStyle = RCTNSStringFromStringNilIfEmpty(newViewProps.userInterfaceStyle);
    }
    // RCT_EXPORT_VIEW_PROPERTY(followsUserLocation, BOOL)
    if (oldViewProps.followsUserLocation != newViewProps.followsUserLocation) {
        self.followsUserLocation = newViewProps.followsUserLocation;
    }
    // RCT_EXPORT_VIEW_PROPERTY(userLocationCalloutEnabled, BOOL)
    if (oldViewProps.userLocationCalloutEnabled != newViewProps.userLocationCalloutEnabled) {
        self.userLocationCalloutEnabled = newViewProps.userLocationCalloutEnabled;
    }
    // RCT_EXPORT_VIEW_PROPERTY(showsPointsOfInterest, BOOL)
    if (oldViewProps.showsPointsOfInterest != newViewProps.showsPointsOfInterest) {
        self.showsPointsOfInterest = newViewProps.showsPointsOfInterest;
    }
    // RCT_EXPORT_VIEW_PROPERTY(showsBuildings, BOOL)
    if (oldViewProps.showsBuildings != newViewProps.showsBuildings) {
        self.showsBuildings = newViewProps.showsBuildings;
    }
    // RCT_EXPORT_VIEW_PROPERTY(showsCompass, BOOL)
    if (oldViewProps.showsCompass != newViewProps.showsCompass) {
        self.showsCompass = newViewProps.showsCompass;
    }
    // RCT_EXPORT_VIEW_PROPERTY(showsScale, BOOL)
    if (oldViewProps.showsScale != newViewProps.showsScale) {
        self.showsScale = newViewProps.showsScale;
    }
    // RCT_EXPORT_VIEW_PROPERTY(showsTraffic, BOOL)
    if (oldViewProps.showsTraffic != newViewProps.showsTraffic) {
        self.showsTraffic = newViewProps.showsTraffic;
    }
    // RCT_EXPORT_VIEW_PROPERTY(zoomEnabled, BOOL)
    if (oldViewProps.zoomEnabled != newViewProps.zoomEnabled) {
        self.zoomEnabled = newViewProps.zoomEnabled;
    }
    // RCT_EXPORT_VIEW_PROPERTY(kmlSrc, NSString)
    if (oldViewProps.kmlSrc != newViewProps.kmlSrc) {
        // TODO not found, is it used????
        // self.kmlSrc = RCTNSStringFromStringNilIfEmpty(newViewProps.kmlSrc);
    }
    // RCT_EXPORT_VIEW_PROPERTY(rotateEnabled, BOOL)
    if (oldViewProps.rotateEnabled != newViewProps.rotateEnabled) {
        self.rotateEnabled = newViewProps.rotateEnabled;
    }
    // RCT_EXPORT_VIEW_PROPERTY(scrollEnabled, BOOL)
    if (oldViewProps.scrollEnabled != newViewProps.scrollEnabled) {
        self.scrollEnabled = newViewProps.scrollEnabled;
    }
    // RCT_EXPORT_VIEW_PROPERTY(pitchEnabled, BOOL)
    if (oldViewProps.pitchEnabled != newViewProps.pitchEnabled) {
        self.pitchEnabled = newViewProps.pitchEnabled;
    }
    // RCT_EXPORT_VIEW_PROPERTY(cacheEnabled, BOOL)
    if (oldViewProps.cacheEnabled != newViewProps.cacheEnabled) {
        self.cacheEnabled = newViewProps.cacheEnabled;
    }
    // RCT_EXPORT_VIEW_PROPERTY(loadingEnabled, BOOL)
    if (oldViewProps.loadingEnabled != newViewProps.loadingEnabled) {
        self.loadingEnabled = newViewProps.loadingEnabled;
    }
    // RCT_EXPORT_VIEW_PROPERTY(loadingBackgroundColor, UIColor)
    if (oldViewProps.loadingBackgroundColor != newViewProps.loadingBackgroundColor) {
        self.loadingBackgroundColor = RCTUIColorFromSharedColor(newViewProps.loadingBackgroundColor);
    }
    // RCT_EXPORT_VIEW_PROPERTY(loadingIndicatorColor, UIColor)
    if (oldViewProps.loadingIndicatorColor != newViewProps.loadingIndicatorColor) {
        self.loadingIndicatorColor = RCTUIColorFromSharedColor(newViewProps.loadingIndicatorColor);
    }
    // RCT_EXPORT_VIEW_PROPERTY(handlePanDrag, BOOL)
    if (oldViewProps.handlePanDrag != newViewProps.handlePanDrag) {
        self.handlePanDrag = newViewProps.handlePanDrag;
    }
    // RCT_EXPORT_VIEW_PROPERTY(maxDelta, CGFloat)
    if (oldViewProps.maxDelta != newViewProps.maxDelta) {
        self.maxDelta = newViewProps.maxDelta;
    }
    // RCT_EXPORT_VIEW_PROPERTY(minDelta, CGFloat)
    if (oldViewProps.minDelta != newViewProps.minDelta) {
        self.minDelta = newViewProps.minDelta;
    }
    // RCT_EXPORT_VIEW_PROPERTY(compassOffset, CGPoint)
    if (oldViewProps.compassOffset.x != newViewProps.compassOffset.x || oldViewProps.compassOffset.y != newViewProps.compassOffset.y) {
        self.compassOffset = (CGPoint) {newViewProps.compassOffset.x, newViewProps.compassOffset.y};
    }
    // RCT_EXPORT_VIEW_PROPERTY(legalLabelInsets, UIEdgeInsets)
    // RCT_EXPORT_VIEW_PROPERTY(mapPadding, UIEdgeInsets)
    // RCT_EXPORT_VIEW_PROPERTY(mapType, MKMapType)
    if (oldViewProps.mapType != newViewProps.mapType) {
        id mapStr = RCTNSStringFromStringNilIfEmpty(newViewProps.mapType);
        if (mapStr) {
            self.mapType = [RCTConvert MKMapType:mapStr];
        }
    }
    
    
   
    [super updateProps:props oldProps:oldProps];
}

- (instancetype)init
{
    if ((self = [super init])) {
        _hasStartedRendering = NO;
        _reactSubviews = [NSMutableArray new];

        // Find Apple link label
        for (UIView *subview in self.subviews) {
            if ([NSStringFromClass(subview.class) isEqualToString:@"MKAttributionLabel"]) {
                // This check is super hacky, but the whole premise of moving around
                // Apple's internal subviews is super hacky
                _legalLabel = subview;
                break;
            }
        }

        // 3rd-party callout view for MapKit that has more options than the built-in. It's painstakingly built to
        // be identical to the built-in callout view (which has a private API)
        self.calloutView = [SMCalloutView platformCalloutView];
        self.calloutView.delegate = self;

        self.minZoomLevel = 0;
        self.maxZoomLevel = AIRMapMaxZoomLevel;
        self.compassOffset = CGPointMake(0, 0);
    }
    return self;
}

- (void)dealloc
{
    [_regionChangeObserveTimer invalidate];
}

-(void)addSubview:(UIView *)view {
    if([view isKindOfClass:[AIRMapMarker class]]) {
        [self addAnnotation:(id <MKAnnotation>)view];
    } else {
        [super addSubview:view];
    }
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-missing-super-calls"
- (void)insertReactSubview:(id<RCTComponent>)subview atIndex:(NSInteger)atIndex {
    // Our desired API is to pass up markers/overlays as children to the mapview component.
    // This is where we intercept them and do the appropriate underlying mapview action.
    if ([subview isKindOfClass:[AIRMapMarker class]]) {
        [self addAnnotation:(id <MKAnnotation>) subview];
    } else if ([subview isKindOfClass:[AIRMapPolyline class]]) {
        ((AIRMapPolyline *)subview).map = self;
        [self addOverlay:(id<MKOverlay>)subview];
    } else if ([subview isKindOfClass:[AIRMapPolygon class]]) {
        ((AIRMapPolygon *)subview).map = self;
        [self addOverlay:(id<MKOverlay>)subview];
    } else if ([subview isKindOfClass:[AIRMapCircle class]]) {
        ((AIRMapCircle *)subview).map = self;
        [self addOverlay:(id<MKOverlay>)subview];
    } else if ([subview isKindOfClass:[AIRMapUrlTile class]]) {
        ((AIRMapUrlTile *)subview).map = self;
        [self addOverlay:(id<MKOverlay>)subview];
    }else if ([subview isKindOfClass:[AIRMapWMSTile class]]) {
        ((AIRMapWMSTile *)subview).map = self;
        [self addOverlay:(id<MKOverlay>)subview];
    } else if ([subview isKindOfClass:[AIRMapLocalTile class]]) {
        ((AIRMapLocalTile *)subview).map = self;
        [self addOverlay:(id<MKOverlay>)subview];
    } else if ([subview isKindOfClass:[AIRMapOverlay class]]) {
        ((AIRMapOverlay *)subview).map = self;
        [self addOverlay:(id<MKOverlay>)subview];
    } else {
        NSArray<id<RCTComponent>> *childSubviews = [subview reactSubviews];
        for (int i = 0; i < childSubviews.count; i++) {
          [self insertReactSubview:(UIView *)childSubviews[i] atIndex:atIndex];
        }
    }
    [_reactSubviews insertObject:(UIView *)subview atIndex:(NSUInteger) atIndex];
}

- (void)mountChildComponentView:(UIView<RCTComponentViewProtocol> *)childComponentView index:(NSInteger)index
{
    NSLog(@"mount");
//   [_containerView insertSubview:childComponentView atIndex:index];
}

- (void)unmountChildComponentView:(UIView<RCTComponentViewProtocol> *)childComponentView index:(NSInteger)index
{
  //[childComponentView removeFromSuperview];
}



#pragma clang diagnostic pop

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-missing-super-calls"
- (void)removeReactSubview:(id<RCTComponent>)subview {
    // similarly, when the children are being removed we have to do the appropriate
    // underlying mapview action here.
    if ([subview isKindOfClass:[AIRMapMarker class]]) {
        [self removeAnnotation:(id<MKAnnotation>)subview];
    } else if ([subview isKindOfClass:[AIRMapPolyline class]]) {
        [self removeOverlay:(id <MKOverlay>) subview];
    } else if ([subview isKindOfClass:[AIRMapPolygon class]]) {
        [self removeOverlay:(id <MKOverlay>) subview];
    } else if ([subview isKindOfClass:[AIRMapCircle class]]) {
        [self removeOverlay:(id <MKOverlay>) subview];
    } else if ([subview isKindOfClass:[AIRMapUrlTile class]]) {
        [self removeOverlay:(id <MKOverlay>) subview];
    } else if ([subview isKindOfClass:[AIRMapWMSTile class]]) {
        [self removeOverlay:(id <MKOverlay>) subview];
    } else if ([subview isKindOfClass:[AIRMapLocalTile class]]) {
        [self removeOverlay:(id <MKOverlay>) subview];
    } else if ([subview isKindOfClass:[AIRMapOverlay class]]) {
        [self removeOverlay:(id <MKOverlay>) subview];
    } else {
        NSArray<id<RCTComponent>> *childSubviews = [subview reactSubviews];
        for (int i = 0; i < childSubviews.count; i++) {
          [self removeReactSubview:(UIView *)childSubviews[i]];
        }
    }
    [_reactSubviews removeObject:(UIView *)subview];
}
#pragma clang diagnostic pop

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-missing-super-calls"
- (NSArray<id<RCTComponent>> *)reactSubviews {
  return _reactSubviews;
}
#pragma clang diagnostic pop

#pragma mark Utils

- (NSArray*) markers {
    NSPredicate *filterMarkers = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        AIRMapMarker *marker = (AIRMapMarker *)evaluatedObject;
        return [marker isKindOfClass:[AIRMapMarker class]];
    }];
    NSArray *filteredMarkers = [self.annotations filteredArrayUsingPredicate:filterMarkers];
    return filteredMarkers;
}

- (AIRMapMarker*) markerForCallout:(AIRMapCallout*)callout {
    AIRMapMarker* marker = nil;
    NSArray* markers = [self markers];
    for (AIRMapMarker* mrk in markers) {
        if (mrk.calloutView == callout) {
            marker = mrk;
            break;
        }
    }
    return marker;
}

- (CGRect) frameForMarker:(AIRMapMarker*) mrkAnn {
    MKAnnotationView* mrkView = [self viewForAnnotation: mrkAnn];
    CGRect mrkFrame = mrkView.frame;
    return mrkFrame;
}

- (NSDictionary*) getMarkersFramesWithOnlyVisible:(BOOL)onlyVisible {
    NSMutableDictionary* markersFrames = [NSMutableDictionary new];
    for (AIRMapMarker* mrkAnn in self.markers) {
        CGRect frame = [self frameForMarker:mrkAnn];
        CGPoint point = [self convertCoordinate:mrkAnn.coordinate toPointToView:self];
        NSDictionary* frameDict = @{
                                    @"x": @(frame.origin.x),
                                    @"y": @(frame.origin.y),
                                    @"width": @(frame.size.width),
                                    @"height": @(frame.size.height)
                                    };
        NSDictionary* pointDict = @{
                                   @"x": @(point.x),
                                   @"y": @(point.y)
                                  };
        NSString* k = mrkAnn.identifier;
        BOOL isVisible = CGRectIntersectsRect(self.bounds, frame);
        if (k != nil && (!onlyVisible || isVisible)) {
            [markersFrames setObject:@{ @"frame": frameDict, @"point": pointDict } forKey:k];
        }
    }
    return markersFrames;
}

- (AIRMapMarker*) markerAtPoint:(CGPoint)point {
    AIRMapMarker* mrk = nil;
    for (AIRMapMarker* mrkAnn in self.markers) {
        CGRect frame = [self frameForMarker:mrkAnn];
        if (CGRectContainsPoint(frame, point)) {
            mrk = mrkAnn;
            break;
        }
    }
    return mrk;
}

#pragma mark Overrides for Callout behavior

// override UIGestureRecognizer's delegate method so we can prevent MKMapView's recognizer from firing
// when we interact with UIControl subclasses inside our callout view.
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isDescendantOfView:self.calloutView])
        return NO;
    else
        return [super gestureRecognizer:gestureRecognizer shouldReceiveTouch:touch];
}


// Allow touches to be sent to our calloutview.
// See this for some discussion of why we need to override this: https://github.com/nfarina/calloutview/pull/9
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {

    CGPoint touchPoint = [self.calloutView convertPoint:point fromView:self];
    UIView *touchedView = [self.calloutView hitTest:touchPoint withEvent:event];
    
    if (touchedView) {
        UIWindow* win = [[[UIApplication sharedApplication] windows] firstObject];
        AIRMapCalloutSubview* calloutSubview = nil;
        AIRMapCallout* callout = nil;
        AIRMapMarker* marker = nil;
        
        UIView* tmp = touchedView;
        while (tmp && tmp != win && tmp != self.calloutView) {
            if ([tmp respondsToSelector:@selector(onPress)]) {
                calloutSubview = (AIRMapCalloutSubview*) tmp;
            }
            if ([tmp isKindOfClass:[AIRMapCallout class]]) {
                callout = (AIRMapCallout*) tmp;
                break;
            }
            tmp = tmp.superview;
        }
        
        if (callout) {
            marker = [self markerForCallout:callout];
            if (marker) {
                CGPoint touchPointReal = [marker.calloutView convertPoint:point fromView:self];
                if (![callout isPointInside:touchPointReal]) {
                    return [super hitTest:point withEvent:event];
                }
            }
        }
        
        return calloutSubview ? calloutSubview : touchedView;
    }

    return [super hitTest:point withEvent:event];
}

#pragma mark SMCalloutViewDelegate

- (NSTimeInterval)calloutView:(SMCalloutView *)calloutView delayForRepositionWithSize:(CGSize)offset {

    // When the callout is being asked to present in a way where it or its target will be partially offscreen, it asks us
    // if we'd like to reposition our surface first so the callout is completely visible. Here we scroll the map into view,
    // but it takes some math because we have to deal in lon/lat instead of the given offset in pixels.

    CLLocationCoordinate2D coordinate = self.region.center;

    // where's the center coordinate in terms of our view?
    CGPoint center = [self convertCoordinate:coordinate toPointToView:self];

    // move it by the requested offset
    center.x -= offset.width;
    center.y -= offset.height;

    // and translate it back into map coordinates
    coordinate = [self convertPoint:center toCoordinateFromView:self];

    // move the map!
    [self setCenterCoordinate:coordinate animated:YES];

    // tell the callout to wait for a while while we scroll (we assume the scroll delay for MKMapView matches UIScrollView)
    return kSMCalloutViewRepositionDelayForUIScrollView;
}

#pragma mark Accessors

- (NSArray *)getMapBoundaries
{
    MKMapRect mapRect = self.visibleMapRect;
    
    CLLocationCoordinate2D northEast = MKCoordinateForMapPoint(MKMapPointMake(MKMapRectGetMaxX(mapRect), mapRect.origin.y));
    CLLocationCoordinate2D southWest = MKCoordinateForMapPoint(MKMapPointMake(mapRect.origin.x, MKMapRectGetMaxY(mapRect)));

    return @[
        @[
            [NSNumber numberWithDouble:northEast.longitude],
            [NSNumber numberWithDouble:northEast.latitude]
        ],
        @[
            [NSNumber numberWithDouble:southWest.longitude],
            [NSNumber numberWithDouble:southWest.latitude]
        ]
    ];
}

- (void)setShowsUserLocation:(BOOL)showsUserLocation
{
    if (self.showsUserLocation != showsUserLocation) {
        if (showsUserLocation && !_locationManager) {
            _locationManager = [CLLocationManager new];
            if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                [_locationManager requestWhenInUseAuthorization];
            }
        }
        super.showsUserLocation = showsUserLocation;
    }
}

- (void)setUserInterfaceStyle:(NSString*)userInterfaceStyle
{
    if (@available(iOS 13.0, *)) {
        if([userInterfaceStyle isEqualToString:@"light"]) {
            self.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
        } else if([userInterfaceStyle isEqualToString:@"dark"]) {
            self.overrideUserInterfaceStyle = UIUserInterfaceStyleDark;
        } else {
            self.overrideUserInterfaceStyle = UIUserInterfaceStyleUnspecified;
        }
    } else {
        NSLog(@"UserInterfaceStyle not supported below iOS 13");
    }
}

- (void)setTintColor:(UIColor *)tintColor
{
    super.tintColor = tintColor;
}

- (void)setFollowsUserLocation:(BOOL)followsUserLocation
{
    _followUserLocation = followsUserLocation;
}

- (void)setUserLocationCalloutEnabled:(BOOL)calloutEnabled
{
    _userLocationCalloutEnabled = calloutEnabled;
}

- (void)setHandlePanDrag:(BOOL)handleMapDrag {
    for (UIGestureRecognizer *recognizer in [self gestureRecognizers]) {
        if ([recognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
            recognizer.enabled = handleMapDrag;
            break;
        }
    }
}

- (void)setRegion:(MKCoordinateRegion)region animated:(BOOL)animated
{
    // If location is invalid, abort
    if (!CLLocationCoordinate2DIsValid(region.center)) {
        return;
    }

    // If new span values are nil, use old values instead
    if (!region.span.latitudeDelta) {
        region.span.latitudeDelta = self.region.span.latitudeDelta;
    }
    if (!region.span.longitudeDelta) {
        region.span.longitudeDelta = self.region.span.longitudeDelta;
    }

    // Animate/move to new position
    [super setRegion:region animated:animated];
}

- (void)setInitialRegion:(MKCoordinateRegion)initialRegion {
    if (!_initialRegionSet) {
        _initialRegionSet = YES;
        [self setRegion:initialRegion animated:NO];
    }
}

- (void)setCamera:(MKMapCamera*)camera animated:(BOOL)animated
{
    [super setCamera:camera animated:animated];
}


- (void)setInitialCamera:(MKMapCamera*)initialCamera {
    if (!_initialCameraSet) {
        _initialCameraSet = YES;
        [self setCamera:initialCamera animated:NO];
    }
}

- (void)setCacheEnabled:(BOOL)cacheEnabled {
    _cacheEnabled = cacheEnabled;
    if (self.cacheEnabled && self.cacheImageView.image == nil) {
        self.loadingView.hidden = NO;
        [self.activityIndicatorView startAnimating];
    }
    else {
        if (_loadingView != nil) {
            self.loadingView.hidden = YES;
        }
    }
}

- (void)setLoadingEnabled:(BOOL)loadingEnabled {
    _loadingEnabled = loadingEnabled;
    if (!self.hasShownInitialLoading) {
        self.loadingView.hidden = !self.loadingEnabled;
    }
    else {
        if (_loadingView != nil) {
            self.loadingView.hidden = YES;
        }
    }
}

- (UIColor *)loadingBackgroundColor {
    return self.loadingView.backgroundColor;
}

- (void)setLoadingBackgroundColor:(UIColor *)loadingBackgroundColor {
    self.loadingView.backgroundColor = loadingBackgroundColor;
}

- (UIColor *)loadingIndicatorColor {
    return self.activityIndicatorView.color;
}

- (void)setLoadingIndicatorColor:(UIColor *)loadingIndicatorColor {
    self.activityIndicatorView.color = loadingIndicatorColor;
}

// Include properties of MKMapView which are only available on iOS 9+
// and check if their selector is available before calling super method.

- (void)setShowsCompass:(BOOL)showsCompass {
    if ([MKMapView instancesRespondToSelector:@selector(setShowsCompass:)]) {
        [super setShowsCompass:showsCompass];
    }
}

- (BOOL)showsCompass {
    if ([MKMapView instancesRespondToSelector:@selector(showsCompass)]) {
        return [super showsCompass];
    } else {
        return NO;
    }
}

- (void)setShowsScale:(BOOL)showsScale {
    if ([MKMapView instancesRespondToSelector:@selector(setShowsScale:)]) {
        [super setShowsScale:showsScale];
    }
}

- (BOOL)showsScale {
    if ([MKMapView instancesRespondToSelector:@selector(showsScale)]) {
        return [super showsScale];
    } else {
        return NO;
    }
}

- (void)setShowsTraffic:(BOOL)showsTraffic {
    if ([MKMapView instancesRespondToSelector:@selector(setShowsTraffic:)]) {
        [super setShowsTraffic:showsTraffic];
    }
}

- (BOOL)showsTraffic {
    if ([MKMapView instancesRespondToSelector:@selector(showsTraffic)]) {
        return [super showsTraffic];
    } else {
        return NO;
    }
}

- (void)setScrollEnabled:(BOOL)scrollEnabled {
    self.shouldScrollEnabled = [NSNumber numberWithBool:scrollEnabled];
    [self updateScrollEnabled];
}

- (void)updateScrollEnabled {
    if (self.cacheEnabled) {
        [super setScrollEnabled:NO];
    }
    else if (self.shouldScrollEnabled != nil) {
        [super setScrollEnabled:[self.shouldScrollEnabled boolValue]];
    }
}

- (void)setZoomEnabled:(BOOL)zoomEnabled {
    self.shouldZoomEnabled = [NSNumber numberWithBool:zoomEnabled];
    [self updateZoomEnabled];
}

- (void)updateZoomEnabled {
    if (self.cacheEnabled) {
        [super setZoomEnabled: NO];
    }
    else if (self.shouldZoomEnabled != nil) {
        [super setZoomEnabled:[self.shouldZoomEnabled boolValue]];
    }
}

- (void)cacheViewIfNeeded {
    // https://github.com/react-native-maps/react-native-maps/issues/3100
    // Do nothing if app is not active
    if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive) {
        return;
    }
    if (self.hasShownInitialLoading) {
        if (!self.cacheEnabled) {
            if (_cacheImageView != nil) {
                self.cacheImageView.hidden = YES;
                self.cacheImageView.image = nil;
            }
        }
        else {
            self.cacheImageView.image = nil;
            self.cacheImageView.hidden = YES;

            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.cacheImageView.image = nil;
                self.cacheImageView.hidden = YES;
                UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0.0);
                [self.layer renderInContext:UIGraphicsGetCurrentContext()];
                UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();

                self.cacheImageView.image = image;
                self.cacheImageView.hidden = NO;
            });
        }

        [self updateScrollEnabled];
        [self updateZoomEnabled];
        [self updateLegalLabelInsets];
    }
}

- (void)updateLegalLabelInsets {
    if (_legalLabel) {
        dispatch_async(dispatch_get_main_queue(), ^{
            CGRect frame = self->_legalLabel.frame;
            if (self->_legalLabelInsets.left) {
                frame.origin.x = self->_legalLabelInsets.left;
            } else if (self->_legalLabelInsets.right) {
                frame.origin.x = self.frame.size.width - self->_legalLabelInsets.right - frame.size.width;
            }
            if (self->_legalLabelInsets.top) {
                frame.origin.y = self->_legalLabelInsets.top;
            } else if (self->_legalLabelInsets.bottom) {
                frame.origin.y = self.frame.size.height - self->_legalLabelInsets.bottom - frame.size.height;
            }
            self->_legalLabel.frame = frame;
        });
    }
}


- (void)setLegalLabelInsets:(UIEdgeInsets)legalLabelInsets {
  _legalLabelInsets = legalLabelInsets;
  [self updateLegalLabelInsets];
}

- (void)setMapPadding:(UIEdgeInsets)mapPadding {
  self.layoutMargins = mapPadding;
}

- (UIEdgeInsets)mapPadding {
  return self.layoutMargins;
}

- (void)beginLoading {
    if ((!self.hasShownInitialLoading && self.loadingEnabled) || (self.cacheEnabled && self.cacheImageView.image == nil)) {
        self.loadingView.hidden = NO;
        [self.activityIndicatorView startAnimating];
    }
    else {
        if (_loadingView != nil) {
            self.loadingView.hidden = YES;
        }
    }
}

- (void)finishLoading {
    self.hasShownInitialLoading = YES;
    if (_loadingView != nil) {
        self.loadingView.hidden = YES;
    }
    [self cacheViewIfNeeded];
}

- (UIActivityIndicatorView *)activityIndicatorView {
    if (_activityIndicatorView == nil) {
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityIndicatorView.center = self.loadingView.center;
        _activityIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        _activityIndicatorView.color = [UIColor colorWithRed:96.f/255.f green:96.f/255.f blue:96.f/255.f alpha:1.f]; // defaults to #606060
    }
    [self.loadingView addSubview:_activityIndicatorView];
    return _activityIndicatorView;
}

- (UIView *)loadingView {
    if (_loadingView == nil) {
        _loadingView = [[UIView alloc] initWithFrame:self.bounds];
        _loadingView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _loadingView.backgroundColor = [UIColor whiteColor]; // defaults to #FFFFFF
        [self addSubview:_loadingView];
        _loadingView.hidden = NO;
    }
    return _loadingView;
}

- (UIImageView *)cacheImageView {
    if (_cacheImageView == nil) {
        _cacheImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _cacheImageView.contentMode = UIViewContentModeCenter;
        _cacheImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addSubview:self.cacheImageView];
        _cacheImageView.hidden = YES;
    }
    return _cacheImageView;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self cacheViewIfNeeded];
    NSUInteger index = [[self subviews] indexOfObjectPassingTest:^BOOL(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *str = NSStringFromClass([obj class]);
        return [str containsString:@"MKCompassView"];
    }];
    if (index != NSNotFound) {
        UIView* compassButton;
        compassButton = [self.subviews objectAtIndex:index];
        compassButton.frame = CGRectMake(compassButton.frame.origin.x + _compassOffset.x, compassButton.frame.origin.y + _compassOffset.y, compassButton.frame.size.width, compassButton.frame.size.height);
    }
}

@end


extern "C" {
    Class<RCTComponentViewProtocol> AIRMapCls(void)
    {
        return AIRMap.class;
    }
}
