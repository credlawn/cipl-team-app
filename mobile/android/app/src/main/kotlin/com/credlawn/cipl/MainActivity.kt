package com.credlawn.cipl

import android.app.PictureInPictureParams
import android.content.res.Configuration
import android.os.Build
import android.util.Rational
import android.telephony.PhoneStateListener
import android.telephony.TelephonyManager
import android.content.Context
import android.provider.CallLog
import android.database.Cursor
import android.net.Uri
import android.content.Intent
import android.app.Activity
import androidx.activity.result.contract.ActivityResultContracts
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Date
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.os.Bundle
import android.view.WindowManager

class MainActivity : FlutterActivity() {
    private val CALL_CHANNEL = "com.credlawn.cipl/call_state"
    private val CAMERA_CHANNEL = "com.credlawn.cipl/camera"
    
    private var callStateChannel: MethodChannel? = null
    private var cameraChannel: MethodChannel? = null
    private var telephonyManager: TelephonyManager? = null
    private var phoneStateListener: PhoneStateListener? = null
    private var isListenerRegistered = false
    
    private var currentPhoneNumber: String? = null
    private var currentLeadId: String? = null
    private var currentEmployeeId: String? = null
    private var currentEmployeeCode: String? = null
    private var currentEmployeeName: String? = null
    private var ringStartTime: Long = 0
    private var ringDuration: Int = -1
    private var isInitialCallback = true
    private var cameraResult: MethodChannel.Result? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Prevent screenshots in production release builds only
        val isDebuggable = (applicationInfo.flags and android.content.pm.ApplicationInfo.FLAG_DEBUGGABLE) != 0
        if (!isDebuggable) {
            window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        
        callStateChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CALL_CHANNEL)
        callStateChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "startCallTracking" -> {
                    val phoneNumber = call.argument<String>("phoneNumber")
                    val leadId = call.argument<String>("leadId")
                    val employeeId = call.argument<String>("employeeId")
                    val employeeCode = call.argument<String>("employeeCode")
                    val employeeName = call.argument<String>("employeeName")
                    
                    if (phoneNumber != null) {
                        startCallTracking(phoneNumber, leadId, employeeId, employeeCode, employeeName)
                        result.success(true)
                    } else {
                        result.error("INVALID_ARGUMENT", "Phone number is required", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
        
        cameraChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CAMERA_CHANNEL)
        cameraChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "captureFrontSelfie" -> {
                    cameraResult = result
                    val intent = Intent(this, CameraActivity::class.java)
                    startActivityForResult(intent, CAMERA_REQUEST_CODE)
                }
                else -> result.notImplemented()
            }
        }
        
        setupPhoneStateListener()
    }
    
    companion object {
        private const val CAMERA_REQUEST_CODE = 1001
    }
    
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        
        if (requestCode == CAMERA_REQUEST_CODE) {
            if (resultCode == Activity.RESULT_OK) {
                val imagePath = data?.getStringExtra("imagePath")
                cameraResult?.success(imagePath)
            } else {
                cameraResult?.error("CAMERA_ERROR", "Failed to capture image", null)
            }
            cameraResult = null
        }
    }

    private fun setupPhoneStateListener() {
        telephonyManager = getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
        
        phoneStateListener = object : PhoneStateListener() {
            override fun onCallStateChanged(state: Int, phoneNumber: String?) {
                super.onCallStateChanged(state, phoneNumber)
                
                // Ignore the immediate callback upon registration if it's IDLE
                if (isInitialCallback) {
                    isInitialCallback = false
                    if (state == TelephonyManager.CALL_STATE_IDLE) {
                        return
                    }
                }
                
                when (state) {
                    TelephonyManager.CALL_STATE_IDLE -> {
                        if (currentPhoneNumber != null) {
                            // Calculate total session duration (Dialing + Talk)
                            var totalDuration = 0
                            if (ringStartTime > 0) {
                                totalDuration = ((System.currentTimeMillis() - ringStartTime) / 1000).toInt()
                            }
                            
                            if (ringStartTime > 0) {
                                totalDuration = ((System.currentTimeMillis() - ringStartTime) / 1000).toInt()
                            }
                            
                            // Wait for system to write to call log
                            // Try after 1 second first (fast path), if not found, we'll retry
                            // Capture ringStartTime now — resetCallTracking() will zero it out
                            val capturedRingStartTime = ringStartTime
                            Handler(Looper.getMainLooper()).postDelayed({
                                fetchCallLogAndSend(currentPhoneNumber!!, totalDuration, 1, capturedRingStartTime)
                                resetCallTracking()
                            }, 1000)
                        }
                    }
                    
                    TelephonyManager.CALL_STATE_RINGING -> {
                        if (ringStartTime == 0L) {
                            ringStartTime = System.currentTimeMillis()
                        }
                    }
                    
                    TelephonyManager.CALL_STATE_OFFHOOK -> {
                        // For outgoing calls, OFFHOOK happens immediately when dialing starts.
                        // We don't calculate ringDuration here anymore.
                        // We just ensure start time is set if it wasn't already.
                        if (ringStartTime == 0L) {
                            ringStartTime = System.currentTimeMillis()
                        }
                    }
                }
            }
        }
    }

    private fun startCallTracking(phoneNumber: String, leadId: String?, employeeId: String?, employeeCode: String?, employeeName: String?) {
        currentPhoneNumber = phoneNumber
        currentLeadId = leadId
        currentEmployeeId = employeeId
        currentEmployeeCode = employeeCode
        currentEmployeeName = employeeName
        ringStartTime = System.currentTimeMillis()
        ringDuration = -1
        isInitialCallback = true
        
        if (!isListenerRegistered) {
            try {
                telephonyManager?.listen(phoneStateListener, PhoneStateListener.LISTEN_CALL_STATE)
                isListenerRegistered = true
            } catch (e: SecurityException) {
            }
        }
    }

    private fun resetCallTracking() {
        currentPhoneNumber = null
        currentLeadId = null
        currentEmployeeId = null
        currentEmployeeCode = null
        currentEmployeeName = null
        ringStartTime = 0
        ringDuration = -1
    }

    private fun fetchCallLogAndSend(phoneNumber: String, totalSessionDuration: Int, attempt: Int, fallbackTimestamp: Long = 0L) {
        var callDuration = 0
        var callType = "unknown"
        var callStatus = "no_answer"
        var matchFound = false
        var callTimestamp: Long = 0
        

        
        try {
            val projection = arrayOf(
                CallLog.Calls.DURATION,
                CallLog.Calls.TYPE,
                CallLog.Calls.DATE,
                CallLog.Calls.NUMBER
            )
            
            val cursor = contentResolver.query(
                CallLog.Calls.CONTENT_URI,
                projection,
                null, 
                null,
                "${CallLog.Calls.DATE} DESC" 
            )
            
            cursor?.use {
                if (it.moveToFirst()) {
                    var count = 0
                    do {
                        val durationIndex = it.getColumnIndex(CallLog.Calls.DURATION)
                        val typeIndex = it.getColumnIndex(CallLog.Calls.TYPE)
                        val dateIndex = it.getColumnIndex(CallLog.Calls.DATE)
                        val numberIndex = it.getColumnIndex(CallLog.Calls.NUMBER)
                        
                        val logDuration = if (durationIndex != -1) it.getInt(durationIndex) else 0
                        val logType = if (typeIndex != -1) it.getInt(typeIndex) else 0
                        val logDate = if (dateIndex != -1) it.getLong(dateIndex) else 0
                        val logNumber = if (numberIndex != -1) it.getString(numberIndex) else ""
                        
                        val timeDiff = System.currentTimeMillis() - logDate
                        val callEndTime = logDate + (logDuration * 1000)
                        val timeSinceEnd = System.currentTimeMillis() - callEndTime
                        

                        
                        // Check if this log ended recently (within last 30 seconds)
                        if (timeSinceEnd < 30000) {
                            // Normalize numbers for comparison (remove non-digits)
                            val cleanLogNumber = logNumber?.replace(Regex("[^0-9]"), "") ?: ""
                            val cleanTargetNumber = phoneNumber.replace(Regex("[^0-9]"), "")
                            
                            // Check for match (handling +91 etc by checking if one ends with the other)
                            val isMatch = if (cleanLogNumber.isNotEmpty() && cleanTargetNumber.isNotEmpty()) {
                                val logSuffix = if (cleanLogNumber.length > 10) cleanLogNumber.takeLast(10) else cleanLogNumber
                                val targetSuffix = if (cleanTargetNumber.length > 10) cleanTargetNumber.takeLast(10) else cleanTargetNumber
                                logSuffix == targetSuffix
                            } else {
                                false
                            }
                            
                            if (isMatch) {
                                 callDuration = logDuration
                                 callTimestamp = logDate
                                 
                                 when (logType) {
                                    CallLog.Calls.INCOMING_TYPE -> callType = "incoming"
                                    CallLog.Calls.OUTGOING_TYPE -> callType = "outgoing"
                                    CallLog.Calls.MISSED_TYPE -> callType = "missed"
                                    CallLog.Calls.REJECTED_TYPE -> callType = "rejected"
                                    else -> callType = "unknown"
                                }
                                
                                
                                matchFound = true
                                break 
                            } else {
                                // Ignored entry: Number mismatch
                            }
                        }
                        
                        count++
                        if (count >= 10) break // Manual limit
                    } while (it.moveToNext())
                }
            }
        } catch (e: SecurityException) {
        } catch (e: Exception) {
        }
        
        // Retry logic
        // Attempt 1: 1s (Initial)
        // Attempt 2: 3s (+2s)
        // Attempt 3: 6s (+3s)
        // Attempt 4: 10s (+4s)
        
        if (!matchFound && attempt < 4) {
            val delay = when (attempt) {
                1 -> 2000L // Wait 2s more (Total 3s)
                2 -> 3000L // Wait 3s more (Total 6s)
                3 -> 4000L // Wait 4s more (Total 10s)
                else -> 2000L
            }
            
            
            Handler(Looper.getMainLooper()).postDelayed({
                fetchCallLogAndSend(phoneNumber, totalSessionDuration, attempt + 1, fallbackTimestamp)
            }, delay)
            return // Exit and wait for retry
        }
        
        // Fallback: if the OS call log was never written within 10 seconds of retries,
        // use the captured ringStartTime as the timestamp instead of 0 (epoch 1970).
        // This ensures the record is valid and won't create a 1970-date junk entry
        // that background sync would later duplicate with the real OS entry.
        if (!matchFound && fallbackTimestamp > 0L) {
            callTimestamp = fallbackTimestamp
            callType = "outgoing" // Employee is always the initiator from this app
            // callDuration stays 0 and callStatus stays "no_answer" — accurate
        }

        // Calculate Ring Duration
        // Ring Duration = Total Session Duration - Talk Duration
        // Ensure it's not negative
        var calculatedRingDuration = totalSessionDuration - callDuration
        if (calculatedRingDuration < 0) calculatedRingDuration = 0
        
        // Determine status based on duration
        if (callDuration > 0) {
            callStatus = "connected"
        }
        
        sendCallDataToFlutter(
            phoneNumber = phoneNumber,
            callDuration = callDuration,
            ringDuration = calculatedRingDuration,
            sessionDuration = totalSessionDuration,
            callType = callType,
            callStatus = callStatus,
            callTimestamp = callTimestamp
        )
    }

    private fun sendCallDataToFlutter(
        phoneNumber: String,
        callDuration: Int,
        ringDuration: Int,
        sessionDuration: Int,
        callType: String,
        callStatus: String,
        callTimestamp: Long
    ) {
        val callData = hashMapOf(
            "phoneNumber" to phoneNumber,
            "callDuration" to callDuration,
            "ringDuration" to ringDuration,
            "sessionDuration" to sessionDuration,
            "callType" to callType,
            "callStatus" to callStatus,
            "timestamp" to callTimestamp,
            "leadId" to currentLeadId,
            "employeeId" to currentEmployeeId,
            "employeeCode" to currentEmployeeCode,
            "employeeName" to currentEmployeeName
        )
        
        callStateChannel?.invokeMethod("onCallEnded", callData)
    }

    override fun onDestroy() {
        super.onDestroy()
        if (isListenerRegistered) {
            try {
                telephonyManager?.listen(phoneStateListener, PhoneStateListener.LISTEN_NONE)
            } catch (e: SecurityException) {
            }
        }
    }
}
