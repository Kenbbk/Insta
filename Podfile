# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'

target 'Instagram_01' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Instagram_01
pod 'JGProgressHUD'
pod 'YPImagePicker'
use_frameworks!
pod 'FirebaseAuth'
pod 'FirebaseFirestore'
pod 'FirebaseMessaging'
pod 'FirebaseStorage'
pod 'SDWebImage', '~> 5.0'
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
    end
  end
end
end
