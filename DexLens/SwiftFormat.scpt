tell application "Xcode"
    set frontWindow to the first window
    try
        set myPath to the path of the document of the frontWindow
        do shell script "cd \"" & myPath & "\" && /opt/homebrew/bin/swiftformat ."
    on error
        display dialog "No Xcode project open or unable to get project path." buttons {"OK"} default button "OK"
    end try
end tell