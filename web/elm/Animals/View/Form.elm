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
import Pile.Calendar as Calendar
import Pile.DateHolder as DateHolder exposing (DateHolder, DisplayDate(..))

import Html exposing (..)
import Html.Attributes exposing (..)

view : Form -> AnimalFlash -> (FormOperation, FormOperation) -> Html Msg
view form flash (saveOp, cancelOp) =
  Css.highlightedRow []
    [ td []
        [ Css.controlRow "Name" <| nameEditControl form
        , Css.controlRow "Tags" <| deleteTagControl form
        , Css.controlRow "New Tag" <| newTagControl form
        , Css.controlRow "Takes effect" <| effectiveDateControl form
        , calendar form
          
        , Css.leftwardSave form.status (WithForm form saveOp)
        , Css.rightwardCancel form.status (WithForm form cancelOp)
        , AnimalFlash.showWithButton flash (WithForm form RemoveFormFlash)
        ]
    , td [] []
    , Icon.editHelp Css.tdIcon
    , Icon.moreLikeThis form.id Css.tdIcon
    ]
    

-- Controls

calendar : Form -> Html Msg
calendar form =
  if form.effectiveDate.datePickerOpen then
    Calendar.view form.effectiveDate (WithForm form << SelectFormDate)
  else
    span [] []


nameEditControl : Form -> Html Msg
nameEditControl form =
  let
    onInput = WithForm form << NameFieldUpdate
  in
    form.name
      |> TextField.editingEvents (Just onInput) TextField.NeverSubmit
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
      |> TextField.editingEvents
           (Just onInput)
           (TextField.ClickAndEnterSubmits onSubmit)
      |> TextField.eventsObeyForm form
      |> TextField.kind TextField.errorIndicatingTextField
      |> TextField.buttonKind (Button.primaryButton "Add")
      |> TextField.build

deleteTagControl : Form -> Html Msg
deleteTagControl form =
  let
    onDelete name = WithForm form (DeleteTag name)
  in
    Css.horizontalControls 
      (List.map (Css.deletableTag form.status onDelete) form.tags)

effectiveDateControl : Form -> Html Msg
effectiveDateControl form =
  let
    toggle = WithForm form ToggleFormDatePicker
    select = WithForm form << SelectFormDate
    buttonText =
      case form.effectiveDate.datePickerOpen of
        True -> "Close Calendar"
        False -> "Change"
  in
    Css.freshValue (DateHolder.enhancedDateString form.effectiveDate)
      |> TextField.editingEvents Nothing (TextField.ClickSubmits toggle)
      |> TextField.eventsObeyForm form
      |> TextField.kind TextField.plainTextField
      |> TextField.buttonKind (Button.primaryButton buttonText)
      |> TextField.build
