**Trinity**
===========

The Trinity plugin manages Source Explorer, Taglist and NERD Tree, and build them as a great IDE which works like the "Source Insignt".

Features
========

* Automatic Display of Declarations in the Context Window on the bottom in the (G)VIM window using the Source Explorer: 
http://www.vim.org/scripts/script.php?script_id=2179 

* Symbol Windows For Each File on the left in the (G)VIM window (G)VIM using the Taglist: 
http://www.vim.org/scripts/script.php?script_id=273 

* Quick Access to All Files on the right in the (G)VIM window using the NERD Tree: 
http://www.vim.org/scripts/script.php?script_id=1658 

Installation
============

1. Place the Trinity files (trinity.vim and NERD_tree.vim) in your Vim directory (such as ~/.vim) 
   or have it installed by a bundle manager like Vundle or NeoBundle.
2. Open the three plugins together with *:TrinityToggleAll* or map these
   commands to keys in your .vimrc (Settings Example)

Requirements
------------
Trinity requires:
* Vim 7.0 or higher

Screenshots
===========

Left window is Taglist, Bottom window is Source Explorer, and Right window is NERD Tree
---------------------
![One Declaration Found](http://i.imgur.com/bbGVO.jpg)

Settings Example
================
```vim
" Open and close all the three plugins on the same time 
nmap <F8>  :TrinityToggleAll<CR> 

" Open and close the Source Explorer separately 
nmap <F9>  :TrinityToggleSourceExplorer<CR> 

" Open and close the Taglist separately 
nmap <F10> :TrinityToggleTagList<CR> 

" Open and close the NERD Tree separately 
nmap <F11> :TrinityToggleNERDTree<CR> 
 
```

Changelog
=========
2.0
- Support the Named Buffer Version of Source Explorer (v5.1 and above).

2.1
- Add the default keys for Source Explorer's fast way to multi-defs jumping.
