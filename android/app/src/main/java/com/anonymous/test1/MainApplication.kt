package com.anonymous.test1

import android.app.Application
import com.facebook.react.PackageList
import com.facebook.react.ReactApplication
import com.facebook.react.ReactHost
import com.facebook.react.ReactNativeHost
import com.facebook.react.ReactPackage
import com.facebook.react.defaults.DefaultReactNativeHost
import com.facebook.soloader.SoLoader
import com.facebook.react.defaults.DefaultReactHost

class MainApplication : Application(), ReactApplication {

  override val reactNativeHost: ReactNativeHost = object : DefaultReactNativeHost(this) {
    override fun getPackages(): List<ReactPackage> {
      val packages = PackageList(this).packages
      // Añadir el SharedStoragePackage
      packages.add(SharedStoragePackage())
      return packages
    }

    override fun getJSMainModuleName(): String = "index"

    override fun getUseDeveloperSupport(): Boolean = true // O false según necesites
    
    override val isNewArchEnabled: Boolean = false 
    override val isHermesEnabled: Boolean = true
  }

  override val reactHost: ReactHost
    get() = DefaultReactHost.getDefaultReactHost(this.applicationContext, reactNativeHost)

  override fun onCreate() {
    super.onCreate()
    SoLoader.init(this, false)
  }
}