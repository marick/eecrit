module IV.Droplet.Msg exposing (..)

import Animation
import IV.Droplet.Model exposing (Model)

type Msg
  = ChangeDripRate Float
  | Animate Animation.Msg

subscriptions model = 
  Animation.subscription Animate [model.style]
    
