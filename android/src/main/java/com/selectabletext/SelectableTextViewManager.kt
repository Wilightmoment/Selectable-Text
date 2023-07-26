package com.selectabletext

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
  override fun getName() = "SelectableTextView"
  override fun createViewInstance(reactContext: ThemedReactContext): SelectableText {
    return SelectableText(reactContext)
  }

  @ReactProp(name = "fontSize")
  fun setFontSize(textView: SelectableText, fontSize: String) {
    textView.textSize = fontSize.toFloat()
  }
  @ReactProp(name = "sentences")
  fun setSentences(textView: SelectableText, sentences: ReadableArray) {
    val sentenceList = mutableListOf<Sentence>()
    for (currentIndex in 0 until sentences.size()) {
      val item = sentences.getMap(currentIndex)
      sentenceList.add(Sentence(
        start_time = item.getInt("start_time"),
        end_time = item.getInt("end_time"),
        content = item.getString("content") ?: "",
        index = item.getInt("index")
      ))
    }
    textView.setSentences(sentenceList.toTypedArray())
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
    textView.changePlayingSentence(index)
  }

  @ReactProp(name = "menuItems")
  fun setMenuItems(textView: SelectableText, items: ReadableArray) {
    val result: MutableList<String> = ArrayList(items.size())
    for (i in 0 until items.size()) {
      result.add(items.getString(i))
    }
    registerSelectionListener(result.toTypedArray(), textView)
  }

  private fun registerSelectionListener(menuItems: Array<String?>, textView: SelectableText) {
    textView.customSelectionActionModeCallback = object : ActionMode.Callback {
      override fun onPrepareActionMode(mode: ActionMode?, menu: Menu): Boolean {
        // Called when action mode is first created. The menu supplied
        // will be used to generate action buttons for the action mode
        // Android Smart Linkify feature pushes extra options into the menu
        // and would override the generated menu items
        menu.clear()
        for (index in menuItems.indices) {
          menu.add(0, index, 0, menuItems[index])
        }
        return true
      }

      override fun onCreateActionMode(mode: ActionMode?, menu: Menu?): Boolean {
        return true
      }

      override fun onDestroyActionMode(mode: ActionMode?) {
        // Called when an action mode is about to be exited and
      }

      override fun onActionItemClicked(mode: ActionMode?, item: MenuItem): Boolean {
        val selectionStart = textView.selectionStart
        val selectionEnd = textView.selectionEnd
        val selectedText = textView.text.toString().substring(selectionStart, selectionEnd)
        val selectedSentences = mutableSetOf<Int>()
        for (i in selectionStart..selectionEnd) {
          textView.sentenceIndexMap.forEach { item ->
            if (item.value.contains(i)) selectedSentences.add(item.key)
          }
        }

        // Dispatch event
        onSelectNativeEvent(textView, menuItems[item.itemId], selectedText, selectionStart, selectionEnd, selectedSentences)
        mode?.finish()
        return true
      }
    }
  }

  fun onSelectNativeEvent(view: SelectableText, eventType: String?, content: String?, selectionStart: Int, selectionEnd: Int, selectedSentences: MutableSet<Int>) {
    val event = Arguments.createMap()
    event.putString("eventType", eventType)
    event.putString("content", content)
    event.putInt("selectionStart", selectionStart)
    event.putInt("selectionEnd", selectionEnd)
    val readableArray = WritableNativeArray()
    selectedSentences.forEach { selected ->
      readableArray.pushInt(selected)
    }
    event.putArray("selectedSentences", readableArray)
    // Dispatch
    val reactContext = view.context as ReactContext
    reactContext
      .getJSModule(RCTEventEmitter::class.java)
      .receiveEvent(view.id, "topSelection", event)
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
    )
  }
}
