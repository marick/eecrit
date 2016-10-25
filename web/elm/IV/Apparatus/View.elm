module IV.Apparatus.View exposing (render)

import IV.Apparatus.ChamberView as ChamberView
import IV.Apparatus.BagView as BagView
import IV.Apparatus.HoseView as HoseView
import IV.Apparatus.DropletView as DropletView

render model =
  [ DropletView.render model.droplet
  , ChamberView.render model.chamberFluid
  , BagView.render model
  , HoseView.render model
  ] 
