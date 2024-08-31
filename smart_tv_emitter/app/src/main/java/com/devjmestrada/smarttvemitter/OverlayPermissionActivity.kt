package com.devjmestrada.smarttvemitter

import android.content.Intent
import android.os.Bundle
import android.provider.Settings
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.activity.OnBackPressedCallback

class OverlayPermissionActivity : ComponentActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        onBackPressedDispatcher.addCallback(this, object : OnBackPressedCallback(true) {
            override fun handleOnBackPressed() {
                checkOverlayPermission()
            }
        })
        checkOverlayPermission()
    }

    override fun onResume() {
        super.onResume()
        checkOverlayPermission()
    }

    private fun checkOverlayPermission() {
        if (Settings.canDrawOverlays(this)) {
            startOverlayService()
        } else {
            val intent = Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            if (intent.resolveActivity(packageManager) != null) {
                startActivity(intent)
            } else {
                Toast.makeText(
                    this,
                    "Activity not found to handle the overlay permission request",
                    Toast.LENGTH_LONG
                ).show()
                finishAffinity()
            }
        }
    }

    private fun startOverlayService() {
        startService(Intent(this, OverlayService::class.java))
        finish()
    }
}
