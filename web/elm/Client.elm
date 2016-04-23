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


type alias Model =
  { connected : Bool
  }


scrollable : Attribute
scrollable =
  style
    [ ("height", "400px")
    , ("overflow", "scroll")
    , ("background-color", "white")
    ]


view : Signal.Address Action -> Model -> Html.Html
view address model =
  div [ id "container" ]
    [ div [ id "history", class "well", scrollable ]
      [ p [ class "bg-success" ] [ text "Hello, ChatBot!" ]
      , p [ class "bg-info" ] [ text "Hello, World!" ]
      ]
    , div [ class "form-group input-group" ]
      [ input [ type' "text", placeholder "Enter your message...", class "form-control" ] []
      , span [ class "input-group-btn" ]
        [ button [ class "btn btn-primary" ] [ text "Send" ] ]
      ]
    ]


init : ( Model, Effects Action )
init =
  ( { connected = False
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
