module IV.Scenario.Msg exposing (..)

type Msg
  -- Messages from the treatment editor
  = ChangedDripText String
  | ChangedHoursText String
  | ChangedMinutesText String

  | OpenCaseBackgroundEditor
  | CloseCaseBackgroundEditor

