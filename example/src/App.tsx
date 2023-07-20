import * as React from 'react';

import { StyleSheet, View } from 'react-native';
import { SelectableTextView } from 'react-native-selectable-text';

export default function App() {
  return (
    <View style={styles.container} onLayout={(event) => {
      console.log(event.nativeEvent.layout)
    }}>
      <SelectableTextView
        menuItems={['Comment', 'Height']}
        onSelection={event => {
          console.log(event.nativeEvent)
        }}
        value="123fsd asdf afasfasdfassa  asdfa dassafas ss s  f"
        style={styles.box}
        fontSize="16"
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    // alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: '#0c9',
    // flexWrap: "wrap"
  },
  box: {
    // flex: 1,
    // flexWrap: "wrap"
    // width: '50%',
    // width: "100%",
    // height: 50,
  },
});
