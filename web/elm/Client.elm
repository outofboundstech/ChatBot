module Client where


import Effects exposing (Effects, Never)
import Html exposing (Attribute, Html, button, div, input, p, span, text)
import Html.Attributes exposing (class, id, placeholder, style, type', value)
import Html.Events as Events exposing (on, onClick, keyCode, targetValue)
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
  { draft : String
  , history : History
  }


type Action
  = NoOp
  | UpdateDraft String
  | Send String
  | Receive String
  | Log String


-- UPDATE
update : Action -> Model -> ( Model, Effects Action )
update action model =
  case action of
    UpdateDraft message ->
      ( { model | draft = message }, Effects.none )
    Send "" ->
      -- Silently ignore empty messages
      ( model, Effects.none )
    Send contents ->
      -- Send message off to the server (outbox.send)
      let
        task =
          Signal.send outbox.address contents
          `Task.andThen` (\_ -> Task.succeed NoOp)
        message = { from = "__client__", contents = contents }
        history = message :: model.history
      in
        ( { model | history = history, draft = "" }, task |> Effects.task )
    Receive contents ->
      let
        message = { from = "__server__", contents = contents }
        history = message :: model.history
      in
        ( { model | history = history } , Effects.none )
    Log contents ->
      let
        message = { from = "__system__", contents = contents }
        history = message :: model.history
      in
        ( { model | history = history } , Effects.none )
    NoOp ->
      ( model, Effects.none )


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


onReturn : Signal.Address Action -> Action -> Attribute
onReturn address action =
  on "keypress" keyCode
    (\code ->
      if 13 == code then
        Signal.message address action
      else
        Signal.message address NoOp
    )


-- VIEW
view : Signal.Address Action -> Model -> Html
view address model =
  div [ id "container" ]
    [ div [ id "history", class "well", scrollableStyle ] (historyView model.history)
    , div [ class "form-group input-group" ]
      [ input [ type' "text", placeholder "Enter your message...", class "form-control", value model.draft
        , onInput address UpdateDraft
        , onReturn address (Send model.draft)
        ] []
      , span [ class "input-group-btn" ]
        [ button [ class "btn btn-primary", onClick address (Send model.draft) ] [ text "Send" ] ]
      ]
    ]


-- BOOKKEEPING
init : ( Model, Effects Action )
init =
  ( { draft = ""
    , history = []
    }
  , Effects.none
  )


app : StartApp.App Model
app =
  StartApp.start
    { init = init
    , inputs = [ inputs ]
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
port inbox : Signal String
port log : Signal String


inputs : Signal Action
inputs =
  Signal.merge
    (Signal.map Receive inbox)
    (Signal.map Log log)


outbox : Signal.Mailbox String
outbox =
  Signal.mailbox ""


port transmit : Signal String
port transmit =
  outbox.signal
