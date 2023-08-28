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
  content: string;
  eventType: string;
  selectedSentences: Array<Sentence>;
  selectionStart?: number;
  selectionEnd?: number;
};
type ClickResult = {
  selectedSentences: Array<Sentence>
}
type Sentence = {
  [key: string]: string | number;
  content: string;
  index: number;
};
type SelectableTextProps = {
  menuItems: Array<String>;
  onSelection?: (event: NativeTouchEvent & { nativeEvent: Selection }) => void;
  onClick?: (event: NativeTouchEvent & { nativeEvent: ClickResult }) => void;
  onMenuShown?: (event: NativeTouchEvent) => void; // android only
  sentences: Sentence[];
  playingIndex?: number;
  playingColor?: string;
  textColor?: string;
  style?: ViewStyle;
  fontSize?: string;
};

const ComponentName = 'SelectableTextView';

export const SelectableTextView =
  UIManager.getViewManagerConfig(ComponentName) != null
    ? requireNativeComponent<SelectableTextProps>(ComponentName)
    : () => {
        throw new Error(LINKING_ERROR);
      };
