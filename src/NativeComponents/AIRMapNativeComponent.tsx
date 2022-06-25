// import { requireNativeComponent } from 'react-native';
import { ColorValue, HostComponent, ViewProps } from 'react-native';
import type {
  Float,
  BubblingEventHandler,
  // @ts-ignore TODO: remove once there is a .d.ts file with definitions
} from 'react-native/Libraries/Types/CodegenTypes';

// @ts-ignore TODO: remove once there is a .d.ts file with definitions
import codegenNativeComponentUntyped from 'react-native/Libraries/Utilities/codegenNativeComponent';

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

  // onMapLoaded?: () => void;
  // onMapReady?: () => void;
  /*
  onKmlReady?: (values: KmlMapEvent) => void;
  onRegionChange?: (region: Region, details?: { isGesture: boolean }) => void;
  onRegionChangeComplete?: (
    region: Region,
    details?: { isGesture: boolean }
  ) => void;
  
  onDoublePress?: (event: MapEvent) => void;
  onLongPress?: (event: MapEvent) => void;
  onUserLocationChange?: (event: EventUserLocation) => void;
  onPanDrag?: (event: MapEvent) => void;
  onPoiClick?: (event: MapEvent<{ placeId: string; name: string }>) => void;
  onMarkerPress?: (
    event: MapEvent<{ action: 'marker-press'; id: string }>
  ) => void;
  onMarkerSelect?: (
    event: MapEvent<{ action: 'marker-select'; id: string }>
  ) => void;
  onMarkerDeselect?: (
    event: MapEvent<{ action: 'marker-deselect'; id: string }>
  ) => void;
  onCalloutPress?: (event: MapEvent<{ action: 'callout-press' }>) => void;
  onMarkerDragStart?: (event: MapEvent) => void;
  onMarkerDrag?: (event: MapEvent) => void;
  onMarkerDragEnd?: (event: MapEvent) => void;
  onIndoorBuildingFocused?: (event: IndoorBuildingEvent) => void;
*/
  minZoomLevel?: Float;
  maxZoomLevel?: Float;
  kmlSrc?: string;
}

export default codegenNativeComponent<AIRMapProps>('AIRMap');
