import {
  requireNativeComponent,
  UIManager,
  Platform,
  type ViewStyle,
  type NativeTouchEvent,
} from 'react-native';

const LINKING_ERROR =
  `The package 'react-native-selectable-text' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';
type Selection = {
  key: string;
  range: Array<number>;
  text: string;
}
type SelectableTextProps = {
  menuItems: Array<String>;
  onSelection: (
    event: NativeTouchEvent & { nativeEvent: Selection }
  ) => void;
  style: ViewStyle;
  value: string;
  fontSize?: string
};

const ComponentName = 'SelectableTextView';

export const SelectableTextView =
  UIManager.getViewManagerConfig(ComponentName) != null
    ? requireNativeComponent<SelectableTextProps>(ComponentName)
    : () => {
        throw new Error(LINKING_ERROR);
      };
