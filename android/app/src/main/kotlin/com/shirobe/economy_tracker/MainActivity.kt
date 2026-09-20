package com.shirobe.economy_tracker

import io.flutter.embedding.android.FlutterFragmentActivity

/**
 * FlutterFragmentActivity y no FlutterActivity: el dialogo de huella de
 * Android (BiometricPrompt) es un fragmento y necesita un host que sepa
 * alojarlo. Con FlutterActivity, local_auth falla al invocarlo.
 */
class MainActivity : FlutterFragmentActivity()
