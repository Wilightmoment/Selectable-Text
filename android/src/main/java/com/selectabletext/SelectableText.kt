package com.selectabletext

import android.content.Context
import android.graphics.Color
import android.text.Layout
import android.text.StaticLayout
import android.text.Spannable
import android.text.SpannableStringBuilder
import android.text.TextPaint
import android.text.method.LinkMovementMethod
import android.text.style.ClickableSpan
import android.text.style.ForegroundColorSpan
import android.text.style.BackgroundColorSpan
import android.util.AttributeSet
import android.view.View
import android.view.ViewGroup
import androidx.appcompat.widget.AppCompatTextView
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.ReactContext
import com.facebook.react.bridge.WritableNativeArray
import com.facebook.react.uimanager.events.RCTEventEmitter

data class Sentence(
  val others: MutableMap<String, Any>,
  var index: Int,
  var content: String,
)

class CustomClickableSpan(private val clickedSentence: Sentence, private val context: Context?) : ClickableSpan() {
  override fun onClick(view: View) {
    val event = Arguments.createMap()
    val readableArray = Arguments.createArray()
    val result = Arguments.createMap()
    event.putString("content", clickedSentence.content)
    event.putInt("index", clickedSentence.index)
    clickedSentence.others.forEach { item ->
      event.putString(item.key, item.value.toString())
    }

    readableArray.pushMap(event)
    result.putArray("selectedSentences", readableArray)
    // Dispatch
    val reactContext = context as ReactContext
    reactContext
      .getJSModule(RCTEventEmitter::class.java)
      .receiveEvent(view.id, "topClickSentence", result)
  }

  override fun updateDrawState(ds: TextPaint) {
    super.updateDrawState(ds)
    ds.isUnderlineText = false
  }
}

class SelectableText: AppCompatTextView {
  constructor(context: Context?) : super(context!!) {
    this.setTextIsSelectable(true)
    this.isClickable = true
    this.layoutParams = ViewGroup.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.MATCH_PARENT)
  }
  constructor(context: Context?, attrs: AttributeSet?) : super(context!!, attrs) {}
  constructor(context: Context?, attrs: AttributeSet?, defStyleAttr: Int) : super(context!!, attrs, defStyleAttr) {}
  private val spannableBuilder = SpannableStringBuilder()
  private var sentences: Array<Sentence> = arrayOf()
  private var textColorSpan = ForegroundColorSpan(Color.GREEN)
  private var playingBGColorSpan = BackgroundColorSpan(Color.BLUE)
  private var playingIndex = 0
  var sentenceIndexMap: Map<Int, List<Int>> = mutableMapOf()

  override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
    super.onMeasure(widthMeasureSpec, heightMeasureSpec)
    val width = MeasureSpec.getSize(widthMeasureSpec)
    val height = measureContentHeight(text.toString(), paint, width)
    val density = this.resources.displayMetrics.density
    val event = Arguments.createMap()
    event.putDouble("width", (width / density).toDouble())
    event.putDouble("height", (height / density).toDouble())
    // Dispatch
    val reactContext = context as ReactContext
    reactContext
      .getJSModule(RCTEventEmitter::class.java)
      .receiveEvent(this.id, "topMeasure", event)
  }
  private fun measureContentHeight(text: String, paint: TextPaint, width: Int): Int {
    val layout = StaticLayout(text, paint, width, Layout.Alignment.ALIGN_NORMAL, 1.0f, 0.0f, false)
    return layout.height
  }


  fun setPlayingBGColor(hex: String) {
    this.spannableBuilder.removeSpan(this.playingBGColorSpan)
    this.playingBGColorSpan = BackgroundColorSpan(Color.parseColor(hex))
    this.changePlayingSentence(this.playingIndex)
  }

  fun setTextColor(hex: String) {
    this.spannableBuilder.removeSpan(this.textColorSpan)
    this.textColorSpan = ForegroundColorSpan(Color.parseColor(hex))
    this.spannableBuilder.setSpan(this.textColorSpan, 0, this.spannableBuilder.length, Spannable.SPAN_INCLUSIVE_INCLUSIVE)
    this.changePlayingSentence(this.playingIndex)
  }

  fun setSentences(sentences: Array<Sentence>) {
    this.sentences = sentences
    var lastCount = 0
    sentences.forEachIndexed {currentIndex, sentence ->
      this.spannableBuilder.append(sentence.content, CustomClickableSpan(sentence, this.context), Spannable.SPAN_EXCLUSIVE_EXCLUSIVE)
      val sentenceIndexArray: List<Int> = sentence.content.toCharArray().mapIndexed { charIndex, _ ->
        charIndex + lastCount
      }
      sentenceIndexMap += Pair(currentIndex, sentenceIndexArray)
      lastCount = sentenceIndexArray.size
    }
    this.changePlayingSentence(this.playingIndex)
    this.movementMethod = LinkMovementMethod.getInstance()
  }

  fun changePlayingSentence(index: Int) {
    this.playingIndex = index
    this.spannableBuilder.removeSpan(this.playingBGColorSpan)
    val startIndex = this.sentences.indexOfFirst {
      it.index == index
    }
    if (startIndex == -1) {
      this.text = this.spannableBuilder
      return
    }
    var spannableStart = 0
    for ((sentenceIndex, sentence) in this.sentences.withIndex()) {
      if (sentenceIndex == startIndex) break
      spannableStart += sentence.content.length
    }
    val spannableEnd = spannableStart + this.sentences[startIndex].content.length
    this.spannableBuilder.setSpan(this.playingBGColorSpan, spannableStart, spannableEnd, Spannable.SPAN_EXCLUSIVE_EXCLUSIVE)
    this.text = this.spannableBuilder
  }
}
