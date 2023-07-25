package com.selectabletext

import android.content.Context
import android.graphics.Color
import android.text.Spannable
import android.text.SpannableStringBuilder
import android.text.TextPaint
import android.text.method.LinkMovementMethod
import android.text.style.ClickableSpan
import android.text.style.ForegroundColorSpan
import android.text.style.BackgroundColorSpan
import android.util.AttributeSet
import android.util.Log
import android.view.View
import android.view.ViewGroup
import androidx.appcompat.widget.AppCompatTextView
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.ReactContext
import com.facebook.react.uimanager.events.RCTEventEmitter


data class Sentence(
  val start_time: Int,
  val end_time: Int,
  val content: String,
  val index: Int,
)

class CustomClickableSpan(private val clickedSentence: Sentence, private val context: Context?) : ClickableSpan() {
  override fun onClick(view: View) {
    Log.d("ClickableSpan", "Clicked text: $clickedSentence")
    val event = Arguments.createMap()
    event.putString("content", clickedSentence.content)
    event.putInt("index", clickedSentence.index)
    event.putInt("end_time", clickedSentence.end_time)
    event.putInt("start_time", clickedSentence.start_time)
    // Dispatch
    val reactContext = context as ReactContext
    reactContext
      .getJSModule(RCTEventEmitter::class.java)
      .receiveEvent(view.id, "topClickSentence", event)
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
      val clickableSpan = object : ClickableSpan() {
        override fun onClick(view: View) {
          Log.d("onclick", "click")
        }

        override fun updateDrawState(ds: TextPaint) {
          super.updateDrawState(ds)
          ds.isUnderlineText = false
        }
      }
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
