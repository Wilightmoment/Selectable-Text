import * as React from 'react';

import { StyleSheet, View } from 'react-native';
import { SelectableTextView } from 'react-native-selectable-text';

export default function App() {
  return (
    <View style={styles.container}>
      <SelectableTextView
        menuItems={['Comment', 'Height']}
        onSelection={event => {
          console.log(event.nativeEvent)
        }}
        style={styles.box}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: '#0c9',
  },
  box: {
    width: '50%',
    height: 60,
  },
});
