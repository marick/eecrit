module Pile.Namelike exposing (..)

{-| 
Strings that are roughly treated as names and can appear in lists. They have
these properties:

1. Names are stored and displayed exactly as entered.
2. For comparison purposes, they are canonicalized by having excess spaces
   removed and being monocased. 
3. Blank (whitespace-only) names cannot be put in lists.
4. Canonical duplicates cannot be added to lists. That is, "Fred" and "fred"
   cannot both appear. Neither can "my dog" and "my dog ".
5. The sort order for such a list is alphabetical by canonical name. (In particular,
   case doesn't affect sorting.)
-} 


-- Todo: Use something like this?
-- type Namelike =
--   Namelike String

import String
import String.Extra as String

type alias Namelike = String
type alias PartialName = String -- Used when filtering by prefix strings

isBlank : Namelike -> Bool
isBlank = String.isBlank

isPresent : Namelike -> Bool
isPresent = isBlank >> not

canonicalize : Namelike -> Namelike
canonicalize string =             
  string |> String.clean |> String.toLower
    
isMember : Namelike -> List Namelike -> Bool
isMember candidate existing =
  List.member (canonicalize candidate) (List.map canonicalize existing)

isValidAddition : Namelike -> List Namelike -> Bool
isValidAddition candidate existing =
  isPresent candidate && not (isMember candidate existing)

isPrefix : PartialName -> Namelike -> Bool
isPrefix desiredPrefix existingName =
  String.startsWith (canonicalize desiredPrefix) (canonicalize existingName)

isTagListAllowed : PartialName -> List Namelike -> Bool
isTagListAllowed desiredPrefix tags  = 
  isBlank desiredPrefix || 
    List.any (isPrefix desiredPrefix) tags


sortByName : (t -> Namelike) -> List t -> List t
sortByName f xs =
  List.sortBy (f >> String.toLower) xs
  
perhapsAdd : Namelike -> List Namelike -> List Namelike
perhapsAdd candidate existing =
  case isValidAddition candidate existing of
    True -> List.append existing [candidate]
    False -> existing
    
    
