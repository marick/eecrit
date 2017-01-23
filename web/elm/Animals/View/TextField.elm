module Animals.View.TextField exposing (..)

import Html exposing (..)
import Html.Events as Events

import Pile.Css.H as Css
import Pile.Css.Bulma as Css
import Pile.Css.Bulma.Util as Css
import Pile.Css.Bulma.TextField as TextField
import Pile.Css.Bulma.Button as Button
import Pile.HtmlShorthand exposing (..)

import Animals.Msg exposing (..)

type SubmitControl 
  = NeverSubmit

textField_noButton submitControl editMsg = 
  TextField.EditOnly editMsg

obeySavingForm form eventControl =
  if form.status == Css.BeingSaved then
    TextField.NeitherEditNorSubmit
  else
    eventControl

textField_button_withContext contextStatus (inputMsg, submitMsg) =
  ( eventControl2 contextStatus (inputMsg, submitMsg)
  , buttonControl (contextStatus == Css.BeingSaved) submitMsg
  )
  
textField_button_noContext bool (inputMsg, submitMsg) =
  ( eventControl3 bool (inputMsg, submitMsg)
  , buttonControl bool submitMsg
  )
  


-- Private



eventControl2 contextStatus (inputMsg, submitMsg) =
  if contextStatus == Css.BeingSaved then
    TextField.NeitherEditNorSubmit
  -- Todo: Should invalidity be marked for empty strings and already-existing
  -- tags? Currently, those are just filtered out silently, which is perhaps
  -- less annoying.
  -- else if form.tentativeTag.validity == Invalid then
  --   TextField.EditOnly onInput
  else
    TextField.BothEditAndSubmit inputMsg submitMsg

eventControl3 bool (inputMsg, submitMsg) =
  if bool then
    TextField.EditOnly inputMsg
  else
    TextField.BothEditAndSubmit inputMsg submitMsg


buttonControl bool submitMsg =
  if bool then
    Button.Inactive
  -- else if form.tentativeTag.validity == Valid then
  --   Button.Active onSubmit
  else
    Button.Active submitMsg
