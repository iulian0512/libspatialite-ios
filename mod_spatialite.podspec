#
#  Be sure to run `pod spec lint spatialite.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  spec.name         = "mod_spatialite"
  spec.version      = "4.3.0a"
  spec.summary      = "SpatiaLite is an open source library intended to extend the SQLite core to support fully fledged Spatial SQL capabilities."

  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  spec.description  = <<-DESC
  SpatiaLite is an open source library intended to extend the SQLite core to support fully fledged Spatial SQL capabilities.
  SQLite is intrinsically simple and lightweight:
  
      a single lightweight library implementing the full SQL engine
      standard SQL implementation: almost complete SQL-92
      no complex client/server architecture
      a whole database simply corresponds to a single monolithic file (no size limits)
      any DB-file can be safely exchanged across different platforms, because the internal architecture is universally portable
      no installation, no configuration
  
  SpatiaLite is smoothly integrated into SQLite to provide a complete and powerful Spatial DBMS (mostly OGC-SFS compliant).
  Using SQLite + SpatiaLite you can effectively deploy an alternative open source Spatial DBMS roughly equivalent to PostgreSQL + PostGIS.
  
  SpatiaLite is licensed under the MPL tri-license terms; you are free to choose the best-fit license between:
  
      the MPL 1.1
      the GPL v2.0 or any subsequent version
      the LGPL v2.1 or any subsequent version
                   DESC

  spec.homepage     = "https://www.gaia-gis.it/fossil/libspatialite/home"
  # spec.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"


  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Licensing your code is important. See https://choosealicense.com for more info.
  #  CocoaPods will detect a license file if there is a named LICENSE*
  #  Popular ones are 'MIT', 'BSD' and 'Apache License, Version 2.0'.
  #

  spec.license      = { :type => "Mozilla Public License v1.1" }


  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Specify the authors of the library, with email addresses. Email addresses
  #  of the authors are extracted from the SCM log. E.g. $ git log. CocoaPods also
  #  accepts just a name if you'd rather not provide an email address.
  #
  #  Specify a social_media_url where others can refer to, for example a twitter
  #  profile URL.
  #

  spec.author             = {
    "Taro Matsuzawa" => "taro@georepublic.co.jp"
  }
  # Or just: spec.author    = "Taro Matsuzawa"
  # spec.authors            = { "Taro Matsuzawa" => "taro@georepublic.co.jp" }
  # spec.social_media_url   = "https://twitter.com/Taro Matsuzawa"

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If this Pod runs only on iOS or OS X, then specify the platform and
  #  the deployment target. You can optionally include the target after the platform.
  #

  spec.platform     = :ios
  #spec.platform     = { ios: '8.0', osx: '10.7' }

  #  When using multiple platforms
  # spec.ios.deployment_target = "5.0"
  # spec.osx.deployment_target = "10.7"
  # spec.watchos.deployment_target = "2.0"
  # spec.tvos.deployment_target = "9.0"


  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Specify the location from where the source should be retrieved.
  #  Supports git, hg, bzr, svn and HTTP.
  #

  spec.source = {
    :http => 'https://github.com/smellman/libspatialite-ios/releases/download/0.0.1/libspatialite-release-0.0.1.zip'
  }
  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  CocoaPods is smart about how it includes source code. For source files
  #  giving a folder will include any swift, h, m, mm, c & cpp files.
  #  For header files it will include any header in the folder.
  #  Not including the public_header_files will make all headers public.
  #

  #spec.source_files  = "spatialite/*.h", "spatialite/src/{gaiaaux,gaiageo}/gg_*.c", "spatialite/src/{dxf,gaiaexif,geopackage,md5,shapefiles,spatialite,srsinit,versioninfo,virtualtext,wfs}/*.c"
  #spec.preserve_paths  = "spatialite/src/**/*"

  #spec.public_header_files = "spatialite/src/headers/**/*.h", "spatialite/src/headers/spatialite.h"
  #spec.private_header_files = "spatialite/src/headers/spatialite_private.h"
  #spec.header_mappings_dir = "src/headers/"
  #spec.default_subspecs = ["standard"]
  spec.vendored_libraries = ['lib/mod_spatialite.a']
  

  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  A list of resources included with the Pod. These are copied into the
  #  target bundle with a build phase script. Anything else will be cleaned.
  #  You can preserve files from being cleaned, please don't preserve
  #  non-essential files like tests, examples and documentation.
  #

  # spec.resource  = "icon.png"
  # spec.resources = "Resources/*.png"

  # spec.preserve_paths = "FilesToSave", "MoreFilesToSave"


  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Link your library with frameworks, or libraries. Libraries do not include
  #  the lib prefix of their name.
  #

  # spec.framework  = "SomeFramework"
  # spec.frameworks = "SomeFramework", "AnotherFramework"

  # spec.library   = "iconv"
  # spec.libraries = "iconv", "xml2"


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If your library depends on compiler flags you can set them in the xcconfig hash
  #  where they will only apply to your library. If you depend on other Podspecs
  #  you can include multiple dependencies to ensure it works.

  # spec.requires_arc = true

  # spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # spec.dependency "JSONKit", "~> 1.4"

  # configure = <<-CMD
  # ./configure --enable-geos=yes --enable-proj=yes --enable-freexl=no
  # CMD
  # spec.script_phase = { :name => "configure", :script => configure }
  # spec.libraries = "z", "iconv"
  # spec.xcconfig = {
  #   "HEADER_SEARCH_PATHS" => "${PODS_ROOT}lisspatialite/spatialite/src ${PODS_ROOT}libspatialite/spatialite/src/headers ${PODS_ROOT}libspatialite/geos/include ${PODS_ROOT}libspatialite/geos/public",
  #   "CLANG_ENABLE_MODULES" => "NO"
  # }
  # spec.requires_arc = false
end
