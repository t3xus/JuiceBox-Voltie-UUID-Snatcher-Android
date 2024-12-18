package com.voltiegroup.uuidsnatcher

import android.Manifest
import android.content.Context
import android.content.Intent
import android.net.wifi.ScanResult
import android.net.wifi.WifiManager
import android.os.Bundle
import android.util.Log
import android.widget.ArrayAdapter
import android.widget.ListView
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ActivityCompat
import okhttp3.OkHttpClient
import okhttp3.Request
import org.json.JSONObject

class MainActivity : AppCompatActivity() {

    private lateinit var wifiManager: WifiManager
    private lateinit var listView: ListView
    private val processedAPs = mutableSetOf<String>()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        listView = findViewById(R.id.ap_list)
        wifiManager = applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager

        requestPermissions()
        scanWifi()
    }

    private fun requestPermissions() {
        val permissions = arrayOf(
            Manifest.permission.ACCESS_FINE_LOCATION,
            Manifest.permission.ACCESS_WIFI_STATE,
            Manifest.permission.CHANGE_WIFI_STATE,
            Manifest.permission.INTERNET
        )

        ActivityCompat.requestPermissions(this, permissions, 1)
    }

    private fun scanWifi() {
        if (!wifiManager.isWifiEnabled) {
            wifiManager.isWifiEnabled = true
        }

        val wifiScanResults: List<ScanResult> = wifiManager.scanResults

        val juiceAPs = wifiScanResults.filter { it.SSID.contains("Juice", ignoreCase = true) && !processedAPs.contains(it.BSSID) }

        val apNames = juiceAPs.map { it.SSID }
        val adapter = ArrayAdapter(this, android.R.layout.simple_list_item_1, apNames)
        listView.adapter = adapter

        listView.setOnItemClickListener { _, _, position, _ ->
            val selectedAP = juiceAPs[position]
            connectToAP(selectedAP)
        }
    }

    private fun connectToAP(scanResult: ScanResult) {
        val networkSuggestion = WifiManager.NetworkSuggestion.Builder()
            .setSsid(scanResult.SSID)
            .build()

        wifiManager.addNetworkSuggestions(listOf(networkSuggestion))

        fetchUUID()
    }

    private fun fetchUUID() {
        val client = OkHttpClient()
        val request = Request.Builder()
            .url("http://10.10.10.1/command/get+system.uuid")
            .build()

        client.newCall(request).execute().use { response ->
            if (response.isSuccessful) {
                val responseBody = response.body?.string()
                val uuid = JSONObject(responseBody ?: "{}").optString("uuid")
                sendEmail(uuid)
            } else {
                Log.e("UUID_FETCH", "Failed to fetch UUID")
            }
        }
    }

    private fun sendEmail(uuid: String) {
        val emailIntent = Intent(Intent.ACTION_SENDTO).apply {
            data = android.net.Uri.parse("mailto:support@voltiegroup.com")
            putExtra(Intent.EXTRA_SUBJECT, "UUID from Voltie Snatcher")
            putExtra(Intent.EXTRA_TEXT, "UUID: $uuid")
        }

        if (emailIntent.resolveActivity(packageManager) != null) {
            startActivity(emailIntent)
        }
    }
}
