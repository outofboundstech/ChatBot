module Client where


import Effects exposing (Effects, Never)
import Html exposing (Attribute, Html, button, div, input, p, span, text)
import Html.Attributes exposing (class, id, placeholder, style, type', value)
import Html.Events as Events exposing (on, onClick, targetValue)
import StartApp
import Task


-- MODEL
type alias Message =
  { from : String
  , contents : String
  }


type alias History =
  List Message


type alias Model =
  { connected : Bool
  , draft : String
  , history : History
  }


type Action
  = NoOp
  | UpdateDraft String
  | Send
  | Receive String
  | UpdateConnectionStatus Bool


-- UPDATE
update : Action -> Model -> ( Model, Effects Action )
update action model =
  case action of
    UpdateDraft message ->
      ( { model | draft = message }, Effects.none )
    Send ->
      -- Send message off to the server (outbox.send)
      let
        task =
          Signal.send outbox.address model.draft
          `Task.andThen` (\_ -> Task.succeed NoOp)
        message = { from = "__client__", contents = model.draft }
        history = message :: model.history
      in
        ( { model | history = history, draft = "" }, task |> Effects.task )
    Receive contents ->
      let
        message = { from = "__server__", contents = contents }
        history = message :: model.history
      in
        ( { model | history = history } , Effects.none )
    UpdateConnectionStatus status ->
      -- How do I communicate this information between Elm and socket?
      ( { model | connected = status }, Effects.none )
    NoOp ->
      ( model, Effects.none)


-- VIEW styles
scrollableStyle : Attribute
scrollableStyle =
  style
    [ ("height", "400px")
    , ("overflow", "scroll")
    , ("background-color", "white")
    ]


-- VIEW helper functions
historyView : History -> List Html
historyView history =
  List.foldl
    (\msg acc  ->
      if "__system__" == msg.from then
        (div [ class "alert" ] [ text msg.contents ]) :: acc
      else if "__server__" == msg.from then
        (div [ class "alert alert-info text-right" ] [ text msg.contents ]) :: acc
      else
        (div [ class "alert alert-success text-left" ] [ text msg.contents ]) :: acc
    )
    []
    history


-- VIEW event helpers
onInput : Signal.Address Action -> (String -> Action) -> Attribute
onInput address action =
  on "input" targetValue (\value -> Signal.message address (action value))


-- VIEW
view : Signal.Address Action -> Model -> Html
view address model =
  div [ id "container" ]
    [ div [ id "history", class "well", scrollableStyle ] (historyView model.history)
    , div [ class "form-group input-group" ]
      [ input [ type' "text", placeholder "Enter your message...", class "form-control", value model.draft, onInput address UpdateDraft ] []
      , span [ class "input-group-btn" ]
        [ button [ class "btn btn-primary", onClick address Send ] [ text "Send" ] ]
      ]
    ]


-- BOOKKEEPING
init : ( Model, Effects Action )
init =
  ( { connected = False
    , draft = ""
    , history = []
    }
  , Effects.none
  )


app : StartApp.App Model
app =
  StartApp.start
    { init = init
    , inputs = [ Signal.map Receive message ]
    , update = update
    , view = view
    }


main : Signal.Signal Html
main =
  app.html


port tasks : Signal (Task.Task Never ())
port tasks =
  app.tasks


-- INTEROP
port message : Signal String


outbox : Signal.Mailbox String
outbox =
  Signal.mailbox ""


port transmit : Signal String
port transmit =
  outbox.signal
