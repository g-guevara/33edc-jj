package com.anonymous.test1

import android.os.Bundle
import com.facebook.react.ReactActivity
import com.facebook.react.ReactActivityDelegate
import com.facebook.react.defaults.DefaultReactActivityDelegate

// Si estás usando Expo, quizás necesitas este import
// import expo.modules.ReactActivityDelegateWrapper

class MainActivity : ReactActivity() {
  override fun onCreate(savedInstanceState: Bundle?) {
    // No uses referencias a R aquí hasta que el proyecto compile correctamente
    // setTheme(...) // Comenta cualquier referencia a R por ahora
    
    super.onCreate(null)
  }

  /**
   * Returns the name of the main component registered from JavaScript.
   */
  override fun getMainComponentName(): String = "main" // O el nombre correcto de tu componente

  /**
   * Returns the instance of the [ReactActivityDelegate].
   */
  override fun createReactActivityDelegate(): ReactActivityDelegate {
    // Versión simplificada sin referencias a BuildConfig o R
    return DefaultReactActivityDelegate(this, mainComponentName, false)
    
    // Si usas Expo, quizás necesitas algo como:
    // return ReactActivityDelegateWrapper(this, false, 
    //   DefaultReactActivityDelegate(this, mainComponentName, false))
  }
}