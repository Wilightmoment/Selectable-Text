import React from 'react';

import { View } from 'react-native';
import { SelectableTextView } from 'react-native-selectable-text';

const sentences = [
  {
    start_time: '0',
    end_time: '10',
    content:
      '曾有參與過廟宇修繕工作的西班牙籍方姓男子，今日凌晨酒後居然持松香水、油脂溶解劑等清潔工具，擦拭塗抹在北市古蹟慈諴宮的廟門上。',
    index: 1,
  },
  {
    start_time: '11',
    end_time: '15',
    content:
      '警方獲報將他逮捕，他卻供稱是看廟門太髒，所以想幫忙清洗擦拭乾淨，警訊後依違反文化資產保存法送辦。',
    index: 2,
  },
  {
    start_time: '11',
    end_time: '15',
    content:
      '據了解，奉祀天上聖母的士林慈諴宮，位在北市大南路84號，創建於清嘉慶元年（西元1796年），原址在今士林美國學校附近。清同治三年（西元1864年），由信眾遷建於八芝蘭新街，作為地方守護神。民國16年重建，左右兩邊由兩派匠師分別承建，因此雕琢作風各異，正殿內仍有精美的交趾陶，皆具重要特色，被北市認定為古蹟。',
    index: 3,
  },
];

export default function App() {
  return (
    <View>
      <SelectableTextView
        menuItems={['Comment', 'Height', 'Cos']}
        sentences={sentences}
        onSelection={(event) => {
          console.log('onSelection: ', event.nativeEvent);
        }}
        onClick={(event) => {
          console.log('onClick: ', event.nativeEvent);
        }}
      />
    </View>
  );
}
