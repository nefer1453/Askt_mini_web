// kodu kopyala
package com.nefer.sktmini

import android.annotation.SuppressLint
import android.os.Bundle
import android.webkit.*
import androidx.appcompat.app.AppCompatActivity

class MainActivity : AppCompatActivity() {

    private lateinit var web: WebView
    private val HOME_URL = "https://nefer1453.github.io/skt/"

    @SuppressLint("SetJavaScriptEnabled")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        web = findViewById(R.id.webview)

        val s = web.settings

        // WebView2019i taray0131c0131ya yakla015ft0131r (UI farklar0131n0131 azalt)
        s.userAgentString = s.userAgentString.replace('; wv', '')
        s.useWideViewPort = true
        s.loadWithOverviewMode = true

        s.javaScriptEnabled = true
        s.domStorageEnabled = true
        s.loadsImagesAutomatically = true

        // Cache kaynaklı ERR_CACHE_MISS sorununu kes
        s.cacheMode = WebSettings.LOAD_NO_CACHE
        web.clearCache(true)
        web.clearHistory()

        // Çerez / session tutarlılığı (bazı cihazlarda lazım olabiliyor)
        CookieManager.getInstance().setAcceptCookie(true)
        CookieManager.getInstance().setAcceptThirdPartyCookies(web, true)

        web.webChromeClient = WebChromeClient()
        web.webViewClient = object : WebViewClient() {

            override fun shouldOverrideUrlLoading(view: WebView?, request: WebResourceRequest?): Boolean {
                return false // WebView içinde kalsın
            }

            override fun onReceivedError(
                view: WebView,
                request: WebResourceRequest,
                error: WebResourceError
            ) {
                // Ana sayfa yüklenemediyse bir kere daha dene (ağ geç gelir vs.)
                if (request.isForMainFrame) {
                    view.postDelayed({ view.loadUrl(HOME_URL) }, 600)
                }
            }
        }

        web.loadUrl(HOME_URL)
    }

    override fun onBackPressed() {
        if (this::web.isInitialized && web.canGoBack()) web.goBack() else super.onBackPressed()
    }
}
