import { ColorValue, HostComponent, ViewProps } from 'react-native';
import type {
  Float,
  Int32,
  // @ts-ignore TODO: remove once there is a .d.ts file with definitions
} from 'react-native/Libraries/Types/CodegenTypes';
// @ts-ignore TODO: remove once there is a .d.ts file with definitions
import { ImageSource } from 'react-native/Libraries/Image/ImageSource';

// @ts-ignore TODO: remove once there is a .d.ts file with definitions
import codegenNativeComponentUntyped from 'react-native/Libraries/Utilities/codegenNativeComponent';

// eslint-disable-next-line @typescript-eslint/ban-types
const codegenNativeComponent = codegenNativeComponentUntyped as <T extends {}>(
  name: string
) => HostComponent<T>;

type LatLng = Readonly<{
  latitude: Float;
  longitude: Float;
}>;

type Point = Readonly<{
  x: Float;
  y: Float;
}>;

interface MarkerProps extends ViewProps {
  identifier?: string;
  reuseIdentifier?: string;
  title?: string;
  description?: string;
  image?: ImageSource;
  icon?: ImageSource;
  opacity?: Float;
  pinColor?: ColorValue;
  coordinate: LatLng; //| AnimatedRegion;
  centerOffset?: Point;
  calloutOffset?: Point;
  anchor?: Point;
  calloutAnchor?: Point;
  flat?: boolean;
  draggable?: boolean;
  tappable?: boolean;
  tracksViewChanges?: boolean;
  tracksInfoWindowChanges?: boolean;
  stopPropagation?: boolean;

  rotation?: Float;
  //zIndex?: Int32; some wierd error happens here!
  /*onPress?: (event: MapEvent<{ action: 'marker-press'; id: string }>) => void;
  onSelect?: (event: MapEvent<{ action: 'marker-select'; id: string }>) => void;
  onDeselect?: (
    event: MapEvent<{ action: 'marker-deselect'; id: string }>
  ) => void;
  onCalloutPress?: (event: MapEvent<{ action: 'callout-press' }>) => void;
  onDragStart?: (event: MapEvent) => void;
  onDrag?: (event: MapEvent) => void;
  onDragEnd?: (event: MapEvent) => void;*/
}

export default codegenNativeComponent<MarkerProps>('AIRMapMarker');
