import React, { useState } from 'react';

import { View, FlatList, Text, TextInput } from 'react-native';
import { SelectableTextView } from 'react-native-selectable-text';

const sentences = [
  {
    start_time: '0',
    end_time: '10',
    content: 'this is first sentence',
    index: 1,
  },
  { start_time: '11', end_time: '15', content: " and im' second", index: 2 },
];

export default function App() {
  const [size, setSize] = useState({ width: 0, height: 0 });

  return (
    <View style={{ backgroundColor: '#0c9' }}>
      <SelectableTextView
        menuItems={['Comment', 'Height', 'Cos']}
        playingIndex={1}
        playingColor="#dfe8ff"
        textColor="#667280"
        onSelection={(event) => {
          console.log('onSelection: ', event.nativeEvent);
        }}
        onMeasure={(event) => setSize(event.nativeEvent)}
        onClick={(event) => console.log('onClick: ', event.nativeEvent)}
        sentences={sentences}
        style={{ height: 130, marginBottom: 8, zIndex: 999 }}
        fontSize="16"
      />
      <FlatList
        data={[...new Array(1000).fill(0)]}
        // viewabilityConfig={{
        //   waitForInteraction: true,
        //   viewAreaCoveragePercentThreshold: 100,
        // }}
        keyExtractor={(_, index) => index.toString()}
        renderItem={() => (
          <View style={{ marginBottom: 15 }}>
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
              fontSize="16"
            />
          </View>
        )}
      />
    </View>
  );
}
