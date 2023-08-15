package com.selectabletext

import com.facebook.react.uimanager.LayoutShadowNode
import com.facebook.react.views.text.TextAttributes

abstract class SelectableTextBaseShadowNode : LayoutShadowNode() {
  var mTextAttributes: TextAttributes = TextAttributes()
  var mNumberOfLines = -1
  var mTextAlign = 0
  var mIncludeFontPadding = true
  var mTextBreakStrategy = 1
  var mHyphenationFrequency = 0
  var mJustificationMode = 0
}
