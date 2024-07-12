# Syntax Highlighting in Vim
Copy the `syntax` and `ftdetect` folders to your vim folder. If these folders
already exist, instead copy the `assembly.vim` files to the corresponding
folders. The vim folder is by default located at `$HOME/.vim` on Unix and
`$HOME/vimfiles` on Windows systems respectively.

`syntax/assembly.vim` provides the syntax highlighting. `ftdetect/assembly.vim`
makes it so files with the `.s` file extension will be recognized as Adrien's
Magical Assembly (In Progress) files. If you want to use a different file
extension, change the regex in the file to something else. If you don't want
files to automatically be recognized as Adrien's Magical Assembly (In Progress)
files, remove the ftdetect file entirely. The syntax highlighting can then
manually be activated using `:set filetype=assembly`.
