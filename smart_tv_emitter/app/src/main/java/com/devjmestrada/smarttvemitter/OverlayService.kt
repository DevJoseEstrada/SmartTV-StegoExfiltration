package com.devjmestrada.smarttvemitter

import android.app.Service
import android.content.Intent
import android.graphics.PixelFormat
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.util.DisplayMetrics
import android.view.Gravity
import android.view.WindowManager
import android.widget.ImageView

class OverlayService : Service() {
    private lateinit var overlayImageView: ImageView
    private lateinit var windowManager: WindowManager
    private val handler = Handler(Looper.getMainLooper())
    private val binService = BinService()
    private val binData: List<Int> = binService.extractBinData()
    private val timeShowImgModMs: Long = BuildConfig.TIME_SHOW_IMG_MOD_MS
    private val frequencyMs: Long = BuildConfig.FREQUENCY_MS
    private val timeShowImgBaseMs: Long = frequencyMs - timeShowImgModMs

    private val imageResources = listOf(
        R.drawable.base0,
        R.drawable.base1,
        R.drawable.base
    )

    override fun onBind(intent: Intent): IBinder? {
        return null
    }

    override fun onStartCommand(intent: Intent, flags: Int, startId: Int): Int {
        showOverlay()
        val layoutParams = createLayoutParams()
        setUpImageView(layoutParams)
        handler.post(overlaySwitchRunnable)
        return START_STICKY
    }

    private val overlaySwitchRunnable = object : Runnable {
        private var currentIndex = 0
        override fun run() {
            overlayImageView.setImageResource(imageResources[2])
            handler.postDelayed({
                overlayImageView.setImageResource(imageResources[binData[currentIndex]])
                currentIndex = (currentIndex + 1) % binData.size
                handler.postDelayed(this, timeShowImgModMs)
            }, timeShowImgBaseMs)
        }
    }

    private fun showOverlay() {
        createOverlay()
    }

    private fun setUpImageView(layoutParams: WindowManager.LayoutParams) {
        overlayImageView = ImageView(this)
        overlayImageView.setImageResource(imageResources[0])
        windowManager.addView(overlayImageView, layoutParams)
    }

    private fun createOverlay() {
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
    }

    private fun createLayoutParams(): WindowManager.LayoutParams {

        val size: Int = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            // API 30 or after (Android 11 or after)
            val windowMetrics = windowManager.currentWindowMetrics
            val bounds = windowMetrics.bounds
            val screenWidth = bounds.width()
            (0.05 * screenWidth).toInt()
        } else {
            // API 29 or before (Android 10 or before)
            val displayMetrics = DisplayMetrics()
            windowManager.defaultDisplay.getMetrics(displayMetrics)
            val screenWidth = displayMetrics.widthPixels
            (0.05 * screenWidth).toInt()
        }
        return WindowManager.LayoutParams(
            size,
            size,
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
                    WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or
                    WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.BOTTOM or Gravity.END
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        windowManager.removeView(overlayImageView)
    }
}