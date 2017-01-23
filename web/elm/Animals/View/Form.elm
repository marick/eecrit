module Animals.View.Form exposing (view)

import Html exposing (..)
import Html.Events as Events

import Pile.Css.H as Css
import Pile.Css.Bulma as Css
import Pile.Css.Bulma.Util as Css
import Pile.Css.Bulma.TextField as TextField
import Pile.Css.Bulma.Button as Button
import Pile.HtmlShorthand exposing (..)

import Animals.Types.Form as Form exposing (Form)
import Animals.Msg exposing (..)

import Animals.View.Icons as Icon
import Animals.View.AnimalFlash as AnimalFlash exposing (AnimalFlash)

view : Form -> AnimalFlash -> (FormOperation, FormOperation) -> Html Msg
view form flash (saveOp, cancelOp) =
  Css.highlightedRow []
    [ td []
        [ Css.controlRow "Name" <| nameEditControl form
        , Css.controlRow "Tags" <| deleteTagControl form
        , Css.controlRow "New Tag" <| newTagControl form
          
        , Css.leftwardSave form.status (WithForm form saveOp)
        , Css.rightwardCancel form.status (WithForm form cancelOp)
        , AnimalFlash.showWithButton flash (WithForm form RemoveFormFlash)
        ]
    , td [] []
    , td [] []
    , Icon.editHelp Css.tdIcon
    ]
    

-- Controls

nameEditControl : Form -> Html Msg
nameEditControl form =
  let
    eventControl =
      if form.status == Css.BeingSaved then
        TextField.NeitherEditNorSubmit
      else
        TextField.EditOnly (WithForm form << NameFieldUpdate)
    input = 
      TextField.errorIndicatingTextField form.name eventControl
  in
    Css.aShortControlOnItsOwnLine input

deleteTagControl : Form -> Html Msg
deleteTagControl form =
  let
    onDelete name = WithForm form (DeleteTag name)
  in
    Css.horizontalControls 
      (List.map (Css.deletableTag form.status onDelete) form.tags)


newTagControl : Form -> Html Msg
newTagControl form =
  let
    onInput = WithForm form << TentativeTagUpdate
    onSubmit = WithForm form CreateNewTag

    textEventControl =
      if form.status == Css.BeingSaved then
        TextField.NeitherEditNorSubmit
      -- Todo: Should invalidity be marked for empty strings and already-existing
      -- tags? Currently, those are just filtered out silently, which is perhaps
      -- less annoying.
      -- else if form.tentativeTag.validity == Invalid then
      --   TextField.EditOnly onInput
      else
        TextField.BothEditAndSubmit onInput onSubmit

    buttonEventControl =
      if form.status == Css.BeingSaved then
        Button.Inactive
      -- else if form.tentativeTag.validity == Valid then
      --   Button.Active onSubmit
      else
        Button.Active onSubmit
          
    input = 
      TextField.errorIndicatingTextField
        (Css.freshValue form.tentativeTag)
        textEventControl

    button =
      Button.successButton
        "Add"
        buttonEventControl 
  in
    Css.controlWithAddons input [button]
