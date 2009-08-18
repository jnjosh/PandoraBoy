svn co http://shortcutrecorder.googlecode.com/svn/trunk src
svnversion src > version
cd src
xcodebuild -target ShortcutRecorder.framework TARGET_BUILD_DIR=..
