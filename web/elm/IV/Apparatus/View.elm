module IV.Apparatus.View exposing (view)

import IV.Apparatus.ChamberView as ChamberView
import IV.Apparatus.BagView as BagView
import IV.Apparatus.HoseView as HoseView
import IV.Apparatus.DropletView as DropletView

view model =
  [ DropletView.view model.droplet
  , ChamberView.view model.chamberFluid
  , BagView.view model.bagLevel
  , HoseView.view model.hoseFluid
  ] 
