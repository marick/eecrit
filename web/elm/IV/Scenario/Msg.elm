module IV.Scenario.Msg exposing (..)

type Msg
  -- Messages from the treatment editor
  = ChangedDripText String
  | ChangedHoursText String
  | ChangedMinutesText String

  | ChangedBagCapacity String
  | ChangedBagContents String
  | ChangedDropsPerMil String

  | OpenCaseBackgroundEditor
  | CloseCaseBackgroundEditor

