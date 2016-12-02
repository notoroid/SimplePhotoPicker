Pod::Spec.new do |s|

  s.name         = "SimplePhotoPicker"
  s.version      = "0.1.1"
  s.summary      = "SimplePhotoPicker is a simple photo picker UI. You can combine with UINavigationController to realize photo selection function or provide photo selection function by incorporating as part of UI."

  s.description  = <<-DESC
                   SimplePhotoPicker is a simple photo picker UI. You can combine with UINavigationController to realize photo selection function or provide photo selection function by incorporating as part of UI. - SimplePhotoPicker はシンプルな写真ピッカーUIです。UINavigationController と組み合わせて写真選択機能を実現したり、UIの一部として組み込み事で写真選択機能を提供することができます。
                   DESC

  s.homepage     = "https://github.com/notoroid/SimplePhotoPicker"
  s.screenshots  = "https://raw.githubusercontent.com/notoroid/SimpleNumpad/master/Screenshots/ss01.png", "https://raw.githubusercontent.com/notoroid/SimpleNumpad/master/Screenshots/ss02.png", "https://raw.githubusercontent.com/notoroid/SimpleNumpad/master/Screenshots/ss03.png"


  s.license      = "MIT"
  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author             = { "notoroid" => "noto@irimasu.com" }
  s.social_media_url   = "http://twitter.com/notoroid"

  s.platform     = :ios, "9.0"

  s.source       = { :git => "https://github.com/notoroid/SimpleNumpad.git", :tag => "v#{s.version}" }

  s.source_files  = "Lib/**/*.{h,m}"
  s.resources  = "Lib/**/*.{storyboard,xib}"
  s.framework    = "Photos"

  s.requires_arc = true

end
