module IV.Apparatus.View exposing (render)

import IV.Apparatus.StaticView as StaticView
import IV.Apparatus.BagView as BagView
import IV.Apparatus.DropletView as DropletView

render model =
  [ DropletView.render model.droplet
  , StaticView.render -- Note: static view must go last to be on top.
  , BagView.render model
  ] 
