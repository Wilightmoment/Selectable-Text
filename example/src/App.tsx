import * as React from 'react';

import { StyleSheet, View } from 'react-native';
import { SelectableTextView } from 'react-native-selectable-text';

const sentences = [
  { start_time: 0, end_time: 10, content: 'this is first sentence', index: 1 },
  { start_time: 11, end_time: 15, content: " and im' second", index: 2 },
];

export default function App() {
  return (
    <View
      style={styles.container}
      onLayout={(event) => {
        console.log(event.nativeEvent.layout);
      }}
    >
      <SelectableTextView
        menuItems={['Comment', 'Height']}
        playingIndex={1}
        playingColor="#dfe8ff"
        textColor="#667280"
        onSelection={(event) => {
          console.log('onSelection: ', event.nativeEvent);
        }}
        onClick={(event) => console.log('onClick: ', event.nativeEvent)}
        sentences={sentences}
        style={styles.box}
        fontSize="16"
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  box: {
    backgroundColor: 'rgba(255, 255, 255, .1)',
    height: 60,
  },
});
