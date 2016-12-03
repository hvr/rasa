module Rasa.Ext.Vim
  ( vim
  , VimSt
  ) where

import Rasa.Ext.Vim.State
import Rasa.Ext.Files (saveCurrent)

import Rasa.Ext
import Rasa.Ext.Directive

import qualified Data.Text as T

vim :: HasVim e => Alteration e ()
vim = do
  mode <- getPlugin vim'
  let modeFunc =
        case mode of
          Normal -> normal
          Insert -> insert
  evt <- getEvent
  mapM_ modeFunc evt

insert :: HasVim e => Event -> Alteration e ()
insert Esc = setPlugin vim' Normal
insert BS = deleteChar
insert Enter = insertText "\n"
insert (Keypress 'w' [Ctrl]) = killWord
insert (Keypress 'c' [Ctrl]) = exit
insert (Keypress c _) = insertText $ T.singleton c
insert _ = return ()

normal :: HasVim e => Event -> Alteration e ()
normal (Keypress 'i' _) = setPlugin vim' Insert
normal (Keypress 'I' _) = startOfLine >> setPlugin vim' Insert
normal (Keypress 'a' _) = moveCursor 1 >> setPlugin vim' Insert
normal (Keypress 'A' _) = endOfLine >> setPlugin vim' Insert
normal (Keypress '0' _) = startOfLine
normal (Keypress '$' _) = findNext "\n"
normal (Keypress 'g' _) = startOfBuffer
normal (Keypress 'G' _) = endOfBuffer
normal (Keypress 'o' _) = endOfLine >> insertText "\n" >> setPlugin vim' Insert
normal (Keypress 'O' _) = startOfLine >> insertText "\n" >> setPlugin vim' Insert
normal (Keypress '+' _) = switchBuf 1
normal (Keypress '-' _) = switchBuf (-1)
normal (Keypress 'h' _) = moveCursor (-1)
normal (Keypress 'l' _) = moveCursor 1
normal (Keypress 'k' _) = moveCursorCoord (-1, 0)
normal (Keypress 'j' _) = moveCursorCoord (1, 0)
normal (Keypress 'f' _) = findNext "f"
normal (Keypress 'F' _) = findPrev "f"
normal (Keypress 'X' _) = deleteChar >> moveCursor (-1)
normal (Keypress 'x' _) = moveCursor 1 >> deleteChar >> moveCursor (-1)
normal (Keypress 'D' _) = deleteTillEOL
normal (Keypress 'q' _) = exit
normal (Keypress 'c' [Ctrl]) = exit
normal (Keypress 's' [Ctrl]) = saveCurrent
normal _ = return ()
