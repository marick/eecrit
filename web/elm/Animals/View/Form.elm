module Animals.View.Form exposing (view)

import Animals.Types.Form as Form exposing (Form)
import Animals.Msg exposing (..)

import Animals.View.AnimalFlash as AnimalFlash exposing (AnimalFlash)
import Animals.View.Icons as Icon
import Animals.View.TextField as TextField

import Pile.Css.H as Css
import Pile.Css.Bulma as Css
import Pile.Css.Bulma.Button as Button
import Pile.Css.Bulma.TextField as TextField

import Html exposing (..)

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
    onInput = WithForm form << NameFieldUpdate
  in
    form.name
      |> TextField.events onInput TextField.NeverSubmit
      |> TextField.eventsObeyForm form
      |> TextField.kind TextField.errorIndicatingTextField
      |> TextField.build

newTagControl : Form -> Html Msg
newTagControl form =
  let
    onInput = WithForm form << TentativeTagUpdate
    onSubmit = WithForm form CreateNewTag
  in
    Css.freshValue form.tentativeTag
      |> TextField.events onInput (TextField.ClickAndEnterSubmits onSubmit)
      |> TextField.eventsObeyForm form
      |> TextField.kind TextField.errorIndicatingTextField
      |> TextField.buttonKind (Button.successButton "Add")
      |> TextField.build

deleteTagControl : Form -> Html Msg
deleteTagControl form =
  let
    onDelete name = WithForm form (DeleteTag name)
  in
    Css.horizontalControls 
      (List.map (Css.deletableTag form.status onDelete) form.tags)
