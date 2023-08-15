package com.selectabletext

import android.os.Build
import android.text.BoringLayout
import android.text.Layout
import android.text.Spannable
import android.text.SpannableStringBuilder
import android.text.StaticLayout
import android.text.TextPaint
import android.util.Log
import com.facebook.infer.annotation.Assertions
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.uimanager.annotations.ReactProp
import com.facebook.yoga.YogaBaselineFunction
import com.facebook.yoga.YogaConstants
import com.facebook.yoga.YogaDirection
import com.facebook.yoga.YogaMeasureFunction
import com.facebook.yoga.YogaMeasureMode
import com.facebook.yoga.YogaMeasureOutput
import kotlin.math.ceil

class SelectableTextShadowNode(
) : SelectableTextBaseShadowNode() {
  private var mTextMeasureFunction: YogaMeasureFunction? = null
  private var mTextBaselineFunction: YogaBaselineFunction? = null
  private val sTextPaintInstance = TextPaint(1)
  private var mPreparedSpannableText: Spannable? = null

  init {
    val that = this
    mTextMeasureFunction =
      YogaMeasureFunction { _, width, widthMode, height, heightMode ->
        val text = Assertions.assertNotNull<Spannable>(
          that.mPreparedSpannableText,
          "Spannable element has not been prepared in onBeforeLayout"
        ) as Spannable
        var layout: Layout = that.measureSpannedText(text, width, widthMode)
        Log.d("text", text.toString())
        Log.d("width", width.toString())
        var lineCount = 0
        var lineIndex = 0
        lineCount =
          if (that.mNumberOfLines == -1) layout.lineCount else Math.min(
            that.mNumberOfLines,
            layout.lineCount
          )
        var layoutWidth = 0.0f
        if (widthMode == YogaMeasureMode.EXACTLY) {
          layoutWidth = width
        } else {
          lineIndex = 0
          while (lineIndex < lineCount) {
            val endsWithNewLine = text.length > 0 && text[layout.getLineEnd(lineIndex) - 1] == '\n'
            val lineWidth =
              if (endsWithNewLine) layout.getLineMax(lineIndex) else layout.getLineWidth(lineIndex)
            if (lineWidth > layoutWidth) {
              layoutWidth = lineWidth
            }
            ++lineIndex
          }
          if (widthMode == YogaMeasureMode.AT_MOST && layoutWidth > width) {
            layoutWidth = width
          }
        }
        if (Build.VERSION.SDK_INT > 29) {
          layoutWidth = ceil(layoutWidth.toDouble()).toFloat()
        }
        var layoutHeight = height
        if (heightMode != YogaMeasureMode.EXACTLY) {
          layoutHeight = layout.getLineBottom(lineCount - 1).toFloat()
          if (heightMode == YogaMeasureMode.AT_MOST && layoutHeight > height) {
            layoutHeight = height
          }
        }
        YogaMeasureOutput.make(layoutWidth, layoutHeight)
      }
    mTextBaselineFunction = YogaBaselineFunction { _, width, _ ->
      val text = Assertions.assertNotNull<Spannable>(
        that.mPreparedSpannableText,
        "Spannable element has not been prepared in onBeforeLayout"
      ) as Spannable
      val layout: Layout =
        that.measureSpannedText(text, width, YogaMeasureMode.EXACTLY)
      layout.getLineBaseline(layout.lineCount - 1).toFloat()
    }

    this.initMeasureFunction()
  }
  private fun initMeasureFunction() {
    if (!this.isVirtual) {
      setMeasureFunction(this.mTextMeasureFunction)
      setBaselineFunction(this.mTextBaselineFunction)
    }
  }

  @ReactProp(name = "sentences")
  fun setSentences(sentences: ReadableArray) {
    var text = ""
    for (currentIndex in 0 until sentences.size()) {
      val item = sentences.getMap(currentIndex)
      text += item.getString("content") ?: ""
    }
    this.mPreparedSpannableText = SpannableStringBuilder(text)
//    markUpdated()
  }
  @ReactProp(name = "fontSize")
  fun setFontSize(fontSize: String) {
    this.mTextAttributes.fontSize = fontSize.toFloat()
  }
  override fun markUpdated() {
    super.markUpdated()
    super.dirty()
  }

  private fun measureSpannedText(
    text: Spannable,
    width: Float,
    widthMode: YogaMeasureMode
  ): Layout {
    var width = width
    val textPaint = this.sTextPaintInstance
    // todo: try get textSize from initial
    textPaint.textSize = this.mTextAttributes.effectiveFontSize.toFloat()
    val boring = BoringLayout.isBoring(text, textPaint)
    val desiredWidth = if (boring == null) Layout.getDesiredWidth(text, textPaint) else Float.NaN
    val unconstrainedWidth = widthMode == YogaMeasureMode.UNDEFINED || width < 0.0f
    var alignment = Layout.Alignment.ALIGN_NORMAL
    when (this.getTextAlign()) {
      1 -> alignment = Layout.Alignment.ALIGN_CENTER
      2, 4 -> {}
      3 -> alignment = Layout.Alignment.ALIGN_NORMAL
      5 -> alignment = Layout.Alignment.ALIGN_OPPOSITE
      else -> {}
    }
    val layout: Any
    if (boring != null || !unconstrainedWidth && (YogaConstants.isUndefined(desiredWidth) || desiredWidth > width)) {
      if (boring == null || !unconstrainedWidth && boring.width.toFloat() > width) {
        if (Build.VERSION.SDK_INT < 23) {
          layout = StaticLayout(
            text,
            textPaint,
            width.toInt(),
            alignment,
            1.0f,
            0.0f,
            this.mIncludeFontPadding
          )
        } else {
          if (Build.VERSION.SDK_INT > 29) {
            width = Math.ceil(width.toDouble()).toFloat()
          }
          val builder = StaticLayout.Builder.obtain(text, 0, text.length, textPaint, width.toInt())
            .setAlignment(
              alignment
            ).setLineSpacing(0.0f, 1.0f).setIncludePad(this.mIncludeFontPadding)
            .setBreakStrategy(this.mTextBreakStrategy)
            .setHyphenationFrequency(this.mHyphenationFrequency)
          if (Build.VERSION.SDK_INT >= 28) {
            builder.setUseLineSpacingFromFallbacks(true)
          }
          layout = builder.build()
        }
      } else {
        layout = BoringLayout.make(
          text,
          textPaint,
          Math.max(boring.width, 0),
          alignment,
          1.0f,
          0.0f,
          boring,
          this.mIncludeFontPadding
        )
      }
    } else {
      val hintWidth = Math.ceil(desiredWidth.toDouble()).toInt()
      layout = if (Build.VERSION.SDK_INT < 23) {
        StaticLayout(text, textPaint, hintWidth, alignment, 1.0f, 0.0f, this.mIncludeFontPadding)
      } else {
        val builder =
          StaticLayout.Builder.obtain(text, 0, text.length, textPaint, hintWidth).setAlignment(
            alignment
          ).setLineSpacing(0.0f, 1.0f).setIncludePad(this.mIncludeFontPadding)
            .setBreakStrategy(this.mTextBreakStrategy)
            .setHyphenationFrequency(this.mHyphenationFrequency)
        if (Build.VERSION.SDK_INT >= 26) {
          builder.setJustificationMode(this.mJustificationMode)
        }
        if (Build.VERSION.SDK_INT >= 28) {
          builder.setUseLineSpacingFromFallbacks(true)
        }
        builder.build()
      }
    }
    return layout as Layout
  }

  private fun getTextAlign(): Int {
    var textAlign: Int = this.mTextAlign
    if (this.layoutDirection == YogaDirection.RTL) {
      if (textAlign == 5) {
        textAlign = 3
      } else if (textAlign == 3) {
        textAlign = 5
      }
    }
    return textAlign
  }
}


