package com.example.klasik_lezzetler
import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        maksimumYenilemeHiziniAktifEt()
    }

    private fun maksimumYenilemeHiziniAktifEt() {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                val modlar = display?.supportedModes
                val enYuksekMod = modlar?.maxByOrNull { it.refreshRate }
                if (enYuksekMod != null) {
                    val params = window.attributes
                    params.preferredDisplayModeId = enYuksekMod.modeId
                    window.attributes = params
                }
            } else {
                @Suppress("DEPRECATION")
                val modlar = windowManager.defaultDisplay.supportedModes
                val enYuksekMod = modlar.maxByOrNull { it.refreshRate }
                if (enYuksekMod != null) {
                    val params = window.attributes
                    params.preferredRefreshRate = enYuksekMod.refreshRate
                    window.attributes = params
                }
            }
        } catch (_: Exception) {
        }
    }
}
