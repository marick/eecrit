module IV.Apparatus.View exposing (render)

import IV.Apparatus.StaticView as StaticView
import IV.Apparatus.BagLevelView as BagLevelView
import IV.Apparatus.DropletView as DropletView

render bmodel dmodel =
  [ BagLevelView.render bmodel
  , DropletView.render dmodel
  , StaticView.render -- Note: static view must go last to be on top.
  ]
