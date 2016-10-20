module IV.Clock.View exposing (render)

import IV.Clock.StaticView as StaticView
import IV.Clock.AnimatedView as AnimatedView

render model =
  [ StaticView.render -- static view must come first to serve as a background
  , AnimatedView.render model
  ]
