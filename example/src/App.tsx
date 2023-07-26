import React, { useEffect, useState } from 'react';

import { StyleSheet, View } from 'react-native';
import { SelectableTextView } from 'react-native-selectable-text';

const sentences = [
  { start_time: 0, end_time: 10, content: 'this is first sentence', index: 1 },
  { start_time: 11, end_time: 15, content: " and im' second", index: 2 },
];

export default function App() {
  const [size, setSize] = useState({ width: 0, height: 0 });

  useEffect(() => {
    console.log('size: ', size);
  }, [size]);
  return (
    <View style={{backgroundColor: "#0c9"}}>
      <SelectableTextView
        menuItems={['Comment', 'Height']}
        playingIndex={1}
        playingColor="#dfe8ff"
        textColor="#667280"
        onSelection={(event) => {
          console.log('onSelection: ', event.nativeEvent);
        }}
        onMeasure={(event) => setSize(event.nativeEvent)}
        onClick={(event) => console.log('onClick: ', event.nativeEvent)}
        sentences={sentences}
        style={{ height: size.height }}
        fontSize="16"
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    // flex: 1,
    backgroundColor: '#09c',
  },
  box: {
    backgroundColor: 'rgba(255, 0, 255, 1)',
    // height: 60,
    flexBasis: 'auto',
    // flex: 1,
    // height: "auto"
  },
});
