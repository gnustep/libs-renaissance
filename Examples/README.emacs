Editing .gsmarkup files using Emacs
-----------------------------------

1. Add to your .emacs code to have it switch to xml-mode (or sgml-mode
if you don't have xml-mode) when opening a .gsmarkup file:

 (add-to-list 'auto-mode-alist '("\\.gsmarkup$" . xml-mode))

2. When you are editing a .gsmarkup file, you can have the
gsmarkup.dtd automatically used by emacs to perform validation (and
other xml editing helper functions).  To get this result, you need to
provide the path to the gsmarkup.dtd file.  In practice, temporarily
replace the line

<!DOCTYPE gsmarkup>

at the beginning of your .gsmarkup file with the line

<!DOCTYPE gsmarkup SYSTEM "../Documentation/gsmarkup.dtd">

Then select 'DTD/Parse DTD' from the menu.

(to validate, you can then use 'SGML/Validate' from the menu; other
xml editing functions should be available too).
