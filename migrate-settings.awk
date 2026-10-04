# Copy only Empire Earth's game settings from Wine's old user.reg format.
BEGIN { print "Windows Registry Editor Version 5.00\n" }
/^\[/ {
  copy = index($0, "[Software\\\\SSSI\\\\Empire Earth") == 1 || index($0, "[Software\\\\Mad Doc Software\\\\EE-AOC") == 1
  if (copy) {
    line=$0
    sub(/\] .*/, "]", line)
    gsub(/\\\\/, "\\", line)
    sub(/^\[/, "[HKEY_CURRENT_USER\\", line)
    print "\n" line
  }
  next
}
copy && /^"/ && !/^"Installed From (Directory|Volume)"/ { print }
