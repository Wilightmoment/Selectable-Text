package com.selectabletext

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.util.Log
import android.view.ActionMode
import android.view.Menu
import android.view.MenuItem
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.ReactContext
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.bridge.WritableNativeArray
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.annotations.ReactProp
import com.facebook.react.uimanager.events.RCTEventEmitter

class SelectableTextViewManager : SimpleViewManager<SelectableText>() {
  private var sentences: Array<Sentence> = arrayOf()
  private var text = ""
  private var density = 0F
  private var fontSize = 16
  override fun getName() = "SelectableTextView"
  override fun createViewInstance(reactContext: ThemedReactContext): SelectableText {
    this.density =  reactContext.resources.displayMetrics.density
    return SelectableText(reactContext)
  }

  @ReactProp(name = "fontSize")
  fun setFontSize(textView: SelectableText, fontSize: String) {
    this.fontSize = fontSize.toInt()
    textView.textSize = fontSize.toFloat()
  }
  @ReactProp(name = "sentences")
  fun setSentences(textView: SelectableText, sentences: ReadableArray) {
    val sentenceList = mutableListOf<Sentence>()

    for (currentIndex in 0 until sentences.size()) {
      val item = sentences.getMap(currentIndex)
      val iterator = item.keySetIterator()
      val sentence = Sentence(content = "", index = 0, others = mutableMapOf())
      sentence.content = item.getString("content") ?: ""
      sentence.index = item.getInt("index")
      while (iterator.hasNextKey()) {
        val key = iterator.nextKey()
        if (key == "content" || key == "index") {
          continue;
        }
        sentence.others[key] = item.getString(key).toString()
      }
      sentenceList.add(sentence)
    }
    this.sentences = sentenceList.toTypedArray()
    this.text = ""
    this.sentences.forEach { sentence ->
      this.text += sentence.content
    }
    textView.setSentences(this.sentences)
  }

  @ReactProp(name = "textColor")
  fun setTextColor(textView: SelectableText, color: String) {
    textView.setTextColor(color)
  }

  @ReactProp(name = "playingColor")
  fun setPlayingColor(textView: SelectableText, color: String) {
    textView.setPlayingBGColor(color)
  }

  @ReactProp(name = "playingIndex")
  fun setPlayingIndex(textView: SelectableText, index: Int) {
    textView.setPlayingIndex(index)
  }

  @ReactProp(name = "highlightIndexes")
  fun setHighlightIndexes(textView: SelectableText, highlightIndexes: ReadableArray) {
    val indexList = mutableListOf<Int>()
    for (currentIndex in 0 until highlightIndexes.size()) {
      indexList.add(highlightIndexes.getInt(currentIndex))
    }
    textView.setHighlightIndexes(indexList.toTypedArray())
  }

  @ReactProp(name = "highlightColor")
  fun setHighlightColor(textView: SelectableText, highlightColor: String) {
    textView.setHighlightColor(highlightColor)
  }

  @ReactProp(name = "menuItems")
  fun setMenuItems(textView: SelectableText, items: ReadableArray) {
    val result: MutableList<String> = ArrayList(items.size())
    for (i in 0 until items.size()) {
      result.add(items.getString(i))
    }
    registerSelectionListener(result.toTypedArray(), textView, this.sentences)
//    Log.d("menuItems", textView.isTextSelectable.toString())
  }
  override fun createShadowNodeInstance(): SelectableTextShadowNode {
    return SelectableTextShadowNode()
  }
  private fun registerSelectionListener(menuItems: Array<String?>, textView: SelectableText, sentences: Array<Sentence>) {
    textView.customSelectionActionModeCallback = object : ActionMode.Callback {
      override fun onPrepareActionMode(mode: ActionMode?, menu: Menu): Boolean {
        for (i in menu.size() - 1 downTo 0) {
          val menuItem = menu.getItem(i)
          if (menuItem.itemId != android.R.id.copy) {
            menu.removeItem(menuItem.itemId)
          }
        }

//        menu.clear()
        for (index in menuItems.indices) {
          menu.add(0, index, 0, menuItems[index])
        }
        return true
      }

      override fun onCreateActionMode(mode: ActionMode?, menu: Menu?): Boolean {
        val event = Arguments.createMap()
        val reactContext = textView.context as ReactContext
        reactContext
          .getJSModule(RCTEventEmitter::class.java)
          .receiveEvent(textView.id, "topMenuShown", event)
        return true
      }

      override fun onDestroyActionMode(mode: ActionMode?) {
        // Called when an action mode is about to be exited and
      }

      override fun onActionItemClicked(mode: ActionMode?, item: MenuItem): Boolean {
        val selectionStart = textView.selectionStart
        val selectionEnd = textView.selectionEnd
        val selectedText = textView.text.toString().substring(selectionStart, selectionEnd)
        val selectedSentences = mutableSetOf<Sentence>()

        if (item.itemId == android.R.id.copy) {
          val clipboardManager = textView.context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
          val clipData = ClipData.newPlainText("text", selectedText)
          clipboardManager.setPrimaryClip(clipData)
          return true
        }

        for (i in selectionStart..selectionEnd) {
          textView.sentenceIndexMap.forEach { item ->
            if (item.value.contains(i) && item.key < sentences.size) {
              selectedSentences.add(sentences[item.key])
            }
          }
        }

        // Dispatch event
        onSelectNativeEvent(textView, menuItems[item.itemId], selectedText, selectionStart, selectionEnd, selectedSentences)
        mode?.finish()
        return true
      }
    }
  }

  fun onSelectNativeEvent(view: SelectableText, eventType: String?, content: String?, selectionStart: Int, selectionEnd: Int, selectedSentences: MutableSet<Sentence>) {
    try {
      val event = Arguments.createMap()
      event.putString("eventType", eventType)
      event.putString("content", content)
      event.putInt("selectionStart", selectionStart)
      event.putInt("selectionEnd", selectionEnd)
      val readableArray = WritableNativeArray()
      selectedSentences.forEach { selected ->
        val map = Arguments.createMap()
        map.putString("content", selected.content)
        map.putInt("index", selected.index)
        selected.others.forEach {item ->
          map.putString(item.key, item.value.toString())
        }
        readableArray.pushMap(map)
      }
      event.putArray("selectedSentences", readableArray)
      // Dispatch
      val reactContext = view.context as ReactContext
      reactContext
        .getJSModule(RCTEventEmitter::class.java)
        .receiveEvent(view.id, "topSelection", event)
    } catch (error: Error) {
      Log.e("onSelectNativeEvent", "$error", error)
    }
  }
  override fun getExportedCustomBubblingEventTypeConstants(): Map<String, Any> {
    return mapOf(
      "topSelection" to mapOf(
        "phasedRegistrationNames" to mapOf(
          "bubbled" to "onSelection"
        )
      ),
      "topClickSentence" to mapOf(
        "phasedRegistrationNames" to mapOf(
          "bubbled" to "onClick"
        )
      ),
      "topMeasure" to mapOf(
        "phasedRegistrationNames" to mapOf(
          "bubbled" to "onMeasure"
        )
      ),
      "topMenuShown" to mapOf(
        "phasedRegistrationNames" to mapOf(
          "bubbled" to "onMenuShown"
        )
      ),
    )
  }
}
