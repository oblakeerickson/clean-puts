# clean-puts

`clean-puts` is a little tool I made to help me quickly remove all the
debugging mess I make while doing "puts" debugging with ruby.

Simply run `clean-puts` inside of the current working directory you are in and
it will remove any lines that contain "puts" from files that have been edited
recently and show up in your current `git diff` output.
