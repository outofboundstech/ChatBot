module Client where


import Effects exposing (Effects, Never)
import Html exposing (Attribute, Html, button, div, input, p, span, text)
import Html.Attributes exposing (class, id, placeholder, style, type')
-- import Html.Events as Events exposing (on, onClick, targetValue)
import StartApp
import Task


type Action
  = NoOp
  | UpdateConnectionStatus Bool


type alias Message =
  { from : String
  , contents : String
  }


type alias History =
  List Message


type alias Model =
  { connected : Bool
  , history : History
  }


scrollable : Attribute
scrollable =
  style
    [ ("height", "400px")
    , ("overflow", "scroll")
    , ("background-color", "white")
    ]


viewHistory : History -> List Html
viewHistory history =
  List.map
    (\msg ->
      if "__system__" == msg.from then
        div [ class "alert" ] [ text msg.contents ]
      else if "__server__" == msg.from then
        div [ class "alert alert-info text-right" ] [ text msg.contents ]
      else
        div [ class "alert alert-success text-left" ] [ text msg.contents ]
    )
    history


view : Signal.Address Action -> Model -> Html
view address model =
  div [ id "container" ]
    [ div [ id "history", class "well", scrollable ] (viewHistory model.history)
    , div [ class "form-group input-group" ]
      [ input [ type' "text", placeholder "Enter your message...", class "form-control" ] []
      , span [ class "input-group-btn" ]
        [ button [ class "btn btn-primary" ] [ text "Send" ] ]
      ]
    ]


init : ( Model, Effects Action )
init =
  ( { connected = False
    , history =
      [ { from = "__system__", contents = "Socket connected" }
      , { from = "__client__", contents = "Hello, ChatBot!" }
      , { from = "__server__", contents = "Hello, World!" }
      , { from = "__system__", contents = "Socket disconnected" }
      ]
    }
  , Effects.none
  )


update : Action -> Model -> ( Model, Effects Action )
update action model =
  case action of
    UpdateConnectionStatus status ->
      ( { model | connected = status }, Effects.none )
    NoOp ->
      ( model, Effects.none)


app : StartApp.App Model
app =
  StartApp.start
    { init = init
    , inputs = [ ]
    , update = update
    , view = view
    }


main : Signal.Signal Html
main =
  app.html


port tasks : Signal (Task.Task Never ())
port tasks =
  app.tasks
