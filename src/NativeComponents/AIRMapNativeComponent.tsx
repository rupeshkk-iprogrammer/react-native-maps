// import { requireNativeComponent } from 'react-native';
import { ColorValue, HostComponent, ViewProps } from 'react-native';
import type {
  Float,
  Int32,
  BubblingEventHandler,
  // @ts-ignore TODO: remove once there is a .d.ts file with definitions
} from 'react-native/Libraries/Types/CodegenTypes';

// @ts-ignore TODO: remove once there is a .d.ts file with definitions
import codegenNativeComponentUntyped from 'react-native/Libraries/Utilities/codegenNativeComponent';
// @ts-ignore TODO: remove once there is a .d.ts file with definitions
import codegenNativeCommands from 'react-native/Libraries/Utilities/codegenNativeCommands';
import React from 'react';
import { Coordinate, Point } from 'react-native-maps';

//const AIRMap = requireNativeComponent<MapViewProps>('AIRMap');

// eslint-disable-next-line @typescript-eslint/ban-types
const codegenNativeComponent = codegenNativeComponentUntyped as <T extends {}>(
  name: string
) => HostComponent<T>;

type EdgeInsets = Readonly<{
  top: Float;
  right: Float;
  bottom: Float;
  left: Float;
}>;

type MapStyleElement = Readonly<{
  featureType?: string;
  elementType?: string;
  stylers: ReadonlyArray<Readonly<{}>>;
}>;

type EdgePadding = Readonly<{
  top: Float;
  right: Float;
  bottom: Float;
  left: Float;
}>;

type Region = Readonly<{
  latitude: Float;
  longitude: Float;
  latitudeDelta: Float;
  longitudeDelta: Float;
}>;

type LatLng = Readonly<{
  latitude: Float;
  longitude: Float;
}>;

type Camera = Readonly<{
  center: LatLng;
  heading: Float;
  pitch: Float;
  zoom: Float;
  altitude: Float;
}>;

/*
type MapEvent = Readonly<{
  coordinate: {
    latitude: Float;
    longitude: Float;
  };
  position: {
    x: Float;
    y: Float;
  };
  action: string;
  id?: string;
}>;*/

type KmlMarker = Readonly<{
  id: String;
  title: String;
  description: String;
  coordinate: { latitude: Float; longitude: Float };
  position: { x: Float; y: Float };
}>;

type MapEvent = Readonly<{
  coordinate: {
    latitude: Float;
    longitude: Float;
  };
  position: {
    x: Float;
    y: Float;
  };
  action: string;
  id?: string;
}>;

type MapEventWithAction = Readonly<{
  coordinate: {
    latitude: Float;
    longitude: Float;
  };
  position: {
    x: Float;
    y: Float;
  };
  id?: string;
  action: string;
}>;

type EventUserLocation = Readonly<{
  coordinate: {
    latitude: Float;
    longitude: Float;
    altitude: Float;
    timestamp: Float;
    accuracy: Float;
    speed: Float;
    heading: Float;
    isFromMockProvider: boolean;
  };
}>;

type IndoorLevel = {
  index: Float;
  name: string;
  shortName: string;
};

type IndoorBuilding = Readonly<{
  underground: boolean;
  activeLevelIndex: Float;
  levels: Array<IndoorLevel>;
}>;

export interface AIRMapProps extends ViewProps {
  region?: Region;
  initialRegion?: Region;
  camera?: Camera;
  initialCamera?: Camera;
  provider?: string | null;
  customMapStyleString?: string;
  userLocationUpdateInterval?: Float;
  userLocationFastestInterval?: Float;
  showsUserLocation?: boolean;
  userLocationAnnotationTitle?: string;
  showsMyLocationButton?: boolean;
  followsUserLocation?: boolean;
  userLocationCalloutEnabled?: boolean;
  showsPointsOfInterest?: boolean;
  showsCompass?: boolean;
  zoomEnabled?: boolean;
  zoomTapEnabled?: boolean;
  zoomControlEnabled?: boolean;
  rotateEnabled?: boolean;
  scrollDuringRotateOrZoomEnabled?: boolean;
  cacheEnabled?: boolean;
  loadingEnabled?: boolean;
  loadingBackgroundColor?: ColorValue;
  loadingIndicatorColor?: ColorValue;
  scrollEnabled?: boolean;
  pitchEnabled?: boolean;
  toolbarEnabled?: boolean;
  moveOnMarkerPress?: boolean;
  showsScale?: boolean;
  showsBuildings?: boolean;
  showsTraffic?: boolean;
  showsIndoors?: boolean;
  showsIndoorLevelPicker?: boolean;
  liteMode?: boolean;
  maxDelta?: Float;
  minDelta?: Float;
  tintColor?: ColorValue;
  compassOffset?: Readonly<{ x: Float; y: Float }>;
  mapType?: string;
  userInterfaceStyle?: string;
  legalLabelInsets?: EdgeInsets;
  mapPadding?: EdgePadding;
  paddingAdjustmentBehavior?: string;
  userLocationPriority?: string;
  customMapStyle?: MapStyleElement;
  handlePanDrag?: boolean;

  onPress?: BubblingEventHandler<MapEvent>;

  onMapLoaded?: BubblingEventHandler<Readonly<{}>>;
  onMapReady?: BubblingEventHandler<Readonly<{}>>;

  /*onKmlReady?: BubblingEventHandler<
    Readonly<{ markers: ReadonlyArray<KmlMarker> }>
  >;
  onRegionChange?: BubblingEventHandler<
    Region,
    Readonly<{ isGesture: boolean }>
  >; //(region: Region, details?: { isGesture: boolean }) => void;
  onRegionChangeComplete?: BubblingEventHandler<
    Region,
    Readonly<{ isGesture: boolean }>
  >;*/

  onDoublePress?: BubblingEventHandler<MapEvent>;
  onLongPress?: BubblingEventHandler<MapEvent>;
  onUserLocationChange?: BubblingEventHandler<EventUserLocation>;
  onPanDrag?: BubblingEventHandler<MapEvent>;
  onPointClick?: BubblingEventHandler<MapEventWithAction>;
  onMarkerPress?: BubblingEventHandler<MapEventWithAction>;
  onMarkerSelect?: BubblingEventHandler<MapEventWithAction>;

  onMarkerDeselect?: BubblingEventHandler<MapEventWithAction>;
  onCalloutPress?: BubblingEventHandler<MapEventWithAction>;
  onMarkerDragStart?: BubblingEventHandler<MapEvent>;
  onMarkerDrag?: BubblingEventHandler<MapEvent>;
  onMarkerDragEnd?: BubblingEventHandler<MapEvent>;
  /*onIndoorBuildingFocused?: BubblingEventHandler<
    MapEvent<Readonly<{ IndoorBuilding: IndoorBuilding }>>
  >;*/

  minZoomLevel?: Float;
  maxZoomLevel?: Float;
  kmlSrc?: string;
}

export interface AIRMapNativeCommands {
  getCamera: (viewRef: React.ElementRef<any>) => Promise<Camera>;
  /*setCamera: (viewRef: React.ElementRef<any>, camera: Camera) => void;
  animateCamera: (
    viewRef: React.ElementRef<any>,
    camera: Camera,
    duration?: Float
  ) => void;
  animateToNavigation: (
    viewRef: React.ElementRef<any>,
    location: LatLng,
    bearing: number,
    angle: number,
    duration?: number
  ) => void;
  animateToRegion: (
    viewRef: React.ElementRef<any>,
    region: Region,
    duration?: Float
  ) => void;
  animateToCoordinate: (
    viewRef: React.ElementRef<any>,
    latLng: LatLng,
    duration?: Float
  ) => void;
  animateToBearing: (
    viewRef: React.ElementRef<any>,
    bearing: Float,
    duration?: Float
  ) => void;
  animateToViewingAngle: (
    viewRef: React.ElementRef<any>,
    angle: Float,
    duration?: Float
  ) => void;
  fitToElements: (
    viewRef: React.ElementRef<any>,
    edgePadding: EdgePadding,
    duration?: Float
  ) => void;
  fitToSuppliedMarkers: (
    viewRef: React.ElementRef<any>,
    markers: string[],
    edgePadding: EdgePadding,
    animated?: boolean
  ) => void;
  fitToCoordinates: (
    viewRef: React.ElementRef<any>,
    coordinates: Coordinate[],
    edgePadding: EdgePadding,
    animated?: boolean
  ) => void;
  getMapBoundaries: (viewRef: React.ElementRef<any>) => void;
  setMapBoundaries: (
    viewRef: React.ElementRef<any>,
    northEast: Coordinate,
    southWest: Coordinate
  ) => void;
  setIndoorActiveLevelIndex: (
    viewRef: React.ElementRef<any>,
    activeLevelIndex: Float
  ) => void;
  takeSnapshot: (
    viewRef: React.ElementRef<any>,
    width: Float,
    height: Float,
    region: Region | {},
    format: string,
    quality: Int32,
    result: string,
    callback: (err: any, snapshot: string) => void
  ) => void;
  getAddressFromCoordinates: (
    viewRef: React.ElementRef<any>,
    coordinate: Coordinate
  ) => void;
  pointForCoordinate: (
    viewRef: React.ElementRef<any>,
    coordinate: Coordinate
  ) => Promise<Point>;
  coordinateForPoint: (
    viewRef: React.ElementRef<any>,
    coordinate: Point
  ) => Promise<Coordinate>;
  getMarkersFrames: (
    viewRef: React.ElementRef<any>,
    onlyVisible: boolean
  ) => Promise<unknown>;*/
}

export const AIRMapCommands: AIRMapNativeCommands =
  codegenNativeCommands<AIRMapNativeCommands>({
    supportedCommands: [
      'getCamera',
      /* 'setCamera',
      'animateCamera',
      'animateToNavigation',
      'animateToRegion',
      'animateToCoordinate',
      'animateToBearing',
      'animateToViewingAngle',
      'fitToElements',
      'fitToSuppliedMarkers',
      'fitToCoordinates',
      'getMapBoundaries',
      'getMapBoundaries',
      'setIndoorActiveLevelIndex',
      'takeSnapshot',
      'getAddressFromCoordinates',
      'pointForCoordinate',
      'coordinateForPoint',
      'getMarkersFrames',*/
    ],
  });

export default codegenNativeComponent<AIRMapProps>('AIRMap');
