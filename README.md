# react-native-selectable-text

A selectable text with react native

## Installation

```sh
npm install react-native-selectable-text
```

## Usage

```js
import { SelectableTextView } from 'react-native-selectable-text';
const sentences = [
  {
    content: 'this is first sentence',
    index: 1,
    // another props if you want, but value's type must be String
    // ex: text: "example"
  },
  { content: " and im' second", index: 2 },
];
// ...

<SelectableTextView
  menuItems={['Comment', 'Height']} // required
  playingIndex={1}
  playingColor="#dfe8ff"
  textColor="#667280"
  onSelection={(event) => {
    console.log('onSelection: ', event.nativeEvent);
  }}
  onClick={(event) => console.log('onClick: ', event.nativeEvent)}
  sentences={sentences} // required
  fontSize="16"
/>;
```

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)
