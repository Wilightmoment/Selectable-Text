package com.selectabletext

//import android.R

import android.content.Context
import android.graphics.Color
import android.text.Spannable
import android.text.SpannableStringBuilder
import android.text.style.ForegroundColorSpan
import android.util.AttributeSet
import android.view.ActionMode
import android.view.Menu
import android.view.MenuItem
import android.view.View
import android.view.ViewGroup
import androidx.appcompat.widget.AppCompatTextView
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.ReactContext
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.bridge.WritableNativeArray
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.annotations.ReactProp
import com.facebook.react.uimanager.events.RCTEventEmitter


data class Sentence(
  val start_time: Int,
  val end_time: Int,
  val content: String,
  val index: Int,
)
val paragraph_test = arrayOf(
  Sentence(start_time = 0, end_time = 10, content = "this is first sentence", index = 1),
  Sentence(start_time = 11, end_time = 15, content = " and im' second", index = 2)
)

class CustomEditText : AppCompatTextView {
  constructor(context: Context?) : super(context!!) {
    this.setTextIsSelectable(true)
//    TextViewCompat.setAutoSizeTextTypeWithDefaults(this, 1)
//    this.layoutParams = ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT)
  }
  constructor(context: Context?, attrs: AttributeSet?) : super(context!!, attrs) {}
  constructor(context: Context?, attrs: AttributeSet?, defStyleAttr: Int) : super(context!!, attrs, defStyleAttr) {}
  private val spannableBuilder = SpannableStringBuilder()
  private var sentences: Array<Sentence> = arrayOf()
  var sentenceIndexMap: Map<Int, List<Int>> = mutableMapOf()
  fun setSentences(sentences: Array<Sentence> = paragraph_test) {
    this.sentences = sentences
    var lastCount = 0
    sentences.forEachIndexed {currentIndex, sentence ->
      this.spannableBuilder.append(sentence.content)
      val sentenceIndexArray: List<Int> = sentence.content.toCharArray().mapIndexed { charIndex, _ ->
        charIndex + lastCount
      }
      sentenceIndexMap += Pair(currentIndex, sentenceIndexArray)
      lastCount = sentenceIndexArray.size
    }
    this.text = this.spannableBuilder


  }

  fun changePlayingSentence(index: Int) {
    this.spannableBuilder.clearSpans()
    val startIndex = this.sentences.indexOfFirst {
      it.index == index
    }
    if (startIndex == -1) return
    var spannableStart = 0
    for ((_index, sentence) in this.sentences.withIndex()) {
      if (_index == startIndex) break
      spannableStart += sentence.content.length
    }
    val spannableEnd = spannableStart + this.sentences[startIndex].content.length
    this.spannableBuilder.setSpan(ForegroundColorSpan(Color.BLUE), spannableStart, spannableEnd, Spannable.SPAN_EXCLUSIVE_INCLUSIVE)
    this.setSentences(this.sentences)
  }
}

class SelectableTextViewManager : SimpleViewManager<CustomEditText>() {
  override fun getName() = "SelectableTextView"

  override fun createViewInstance(reactContext: ThemedReactContext): CustomEditText {
    val textView = CustomEditText(reactContext)
    textView.setSentences()
    textView.changePlayingSentence(2)
    return textView
  }

  private fun createPragraph() {

  }

  @ReactProp(name = "fontSize")
  fun setFontSize(textView: CustomEditText, fontSize: String) {

    textView.textSize = fontSize.toFloat()
  }
  @ReactProp(name = "value")
  fun setText(textView: CustomEditText, value: String) {
//    textView.setText(value)
  }

  @ReactProp(name = "menuItems")
  fun setMenuItems(textView: CustomEditText, items: ReadableArray) {
    val result: MutableList<String> = ArrayList(items.size())
    for (i in 0 until items.size()) {
      result.add(items.getString(i))
    }
    registerSelectionListener(result.toTypedArray(), textView)
  }

  private fun registerSelectionListener(menuItems: Array<String?>, textView: CustomEditText) {
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

  fun onSelectNativeEvent(view: CustomEditText, eventType: String?, content: String?, selectionStart: Int, selectionEnd: Int, selectedSentences: MutableSet<Int>) {
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
      )
    )
  }
}
