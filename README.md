# Mugura
**Text Formatting:**

<kbd>Alt</kbd> + <kbd>u</kbd> Upper cases selected text  
<kbd>Alt</kbd> + <kbd>l</kbd> Lower cases selected text  
<kbd>Alt</kbd> + <kbd>t</kbd> Title cases selected text  
<kbd>Alt</kbd> + <kbd>s</kbd> Sentence cases selected text  
<kbd>Alt</kbd> + <kbd>f</kbd> Title cases selected text (Greedy)  
<kbd>Alt</kbd> + <kbd>q</kbd> Fixes improper quote formatting (Uses straight quotes unless <kbd>q</kbd> is pressed <kbd>twice</kbd>, then uses curly quotes)  
<kbd>Alt</kbd> + <kbd>n</kbd> Removes excess symbols in integers and trailing zeroes in floats (Formats integers with commas and rounds floats if <kbd>n</kbd> is pressed <kbd>twice</kbd>)  














```
Alt+u = Upper cases the selected text                     ('abc def' > 'ABC DEF')
Alt+l = Lower cases the selected text                     ('Abc DeF' > 'abc def')
Alt+f = Indiscriminate title case the selected text       ('abc def' > 'Abc Def')
Alt+s = Sentence cases the selected text                  ('abc, def. ghi.' > 'Abc, def. Ghi.')
Alt+t = Title cases the selected text                     ('abc and def: ghi' > 'Abc and Def: Ghi')
Alt+q = Fixes quote formatting                            ('"abc, "def""' > '"abc, 'def'"')
Alt+n = Fixes number formatting                           ('1,12235,21' > '11,223,521')
```
**Text Wrapping:**
```
Ctrl+Shft+w = Input a symbol to wrap the selected text    (input = '_') ('abc' > '_abc_')
Ctrl+w      = Repeated the previous wrap                  ('abc' > '_abc_')
ALT+w       = Removes outer wrap on the selected text     ('__abc__' > '_abc_')
```
**Quick-wraps:**
```
Ctrl+{      =    {Selected text}
Ctrl+[      =    [Selected text]
Ctrl+(      =    (Selected text)
Ctrl+%      =    %Selected text%
Ctrl+_      =    __Selected text__

Ctrl+"      =    "Selected text"
Ctrl+'      =    'Selected text'
Ctrl+Alt+"  =    “Selected text”
Ctrl+Alt+'  =    ‘Selected text’
```
**Clipboard / Pathfinder / Text Selection:**
```
Ctrl+Shft+c = Copies the open folder/selected file/website's path/URL into the clipboard
Ctrl+Wnd+c  = Copies the active window's path to the clipboard

Ctrl+Shft+g = Opens the path/URL-text selected otherwise searches it on Google as a query
Ctrl+Shft+z = Swaps the selected text with that of the clipboard
Ctrl+Shft+k = Quickly inserts a link into plain text if a valid URL is in the clipboard
```
