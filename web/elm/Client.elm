module Client exposing (..)

import Json.Decode as Json

import Html.App as App
import Html exposing (Attribute, Html, a, button, div, input, li, p, span, text, ul)
import Html.Attributes exposing (attribute, class, disabled, href, id, placeholder, style, type', value)
import Html.Events as Events exposing (on, onClick, onInput, keyCode)

import Phoenix.Socket
import Phoenix.Channel
import Phoenix.Push


-- MODEL
type alias Message =
  { from : String
  , content : String
  }


type alias History =
  List Message


type alias Model =
  { connected : Bool
  , draft : String
  , history : History
  , phxSocket : Phoenix.Socket.Socket Msg
  }


initialModel : Model
initialModel =
  { connected = False
  , draft = ""
  , history = []
  , phxSocket = initPhxSocket
  }


-- UPDATE
type Msg
  = NoOp
  -- What is this?
  | PhoenixMsg (Phoenix.Socket.Msg Msg)
  | JoinChannel
  | SetLinkStatus Bool
  | SetDraft String
  | Send String
  | Receive String
  | Log String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    PhoenixMsg msg ->
      let
        ( phxSocket, phxCmd ) =
          Phoenix.Socket.update msg model.phxSocket
      in
        ( { model | phxSocket = phxSocket}, Cmd.map PhoenixMsg phxCmd )

    JoinChannel ->
      let
        channel =
          Phoenix.Channel.init "rooms:lobby"
        (phxSocket, phxCmd) =
          Phoenix.Socket.join channel model.phxSocket
      in
        ( { model | phxSocket = phxSocket }, Cmd.map PhoenixMsg phxCmd )

    SetLinkStatus connected ->
      ( { model | connected = connected }, Cmd.none )

    SetDraft message ->
      ( { model | draft = message }, Cmd.none )

    Send "" ->
      -- Silently ignore empty messages
      ( model, Cmd.none )

    Send content ->
      -- Send message off to the server (outbox.send)
      let
        -- task =
        --   outbox content
        --   `Task.andThen` (\_ -> Task.succeed NoOp)
        message = { from = "__client__", content = content }
        history = message :: model.history
      in
        ( { model | history = history, draft = "" }, Cmd.none ) -- task |> Cmd.task )

    Receive content ->
      let
        message = { from = "__server__", content = content }
        history = message :: model.history
      in
        ( { model | history = history } , Cmd.none )

    Log content ->
      let
        message = { from = "__system__", content = content }
        history = message :: model.history
      in
        ( { model | history = history } , Cmd.none )

    NoOp ->
      ( model, Cmd.none )


-- VIEW attributes
scrollableStyle : Attribute Msg
scrollableStyle =
  style
    [ ("height", "400px")
    , ("overflow-y", "auto")
    , ("background-color", "white")
    ]


-- VIEW event helpers
onReturn : Msg -> Attribute Msg
onReturn msg =
  let
    tagger = (\code -> if 13 == code then msg else NoOp)
  in
    on "keypress" (Json.map tagger keyCode)


-- VIEW helper functions
connectedView : Model -> List (Html Msg)
connectedView model =
  if model.connected then
    [ span [ class "glyphicon glyphicon-ok" ] [ ] ]
  else
    [ span [ class "glyphicon glyphicon-remove" ] [ ] ]


historyView : Model -> List (Html Msg)
historyView model =
  List.foldl
    (\msg acc  ->
      if "__system__" == msg.from then
        (div [ class "alert" ] [ text msg.content ]) :: acc
      else if "__server__" == msg.from then
        (div [ class "alert alert-info text-right" ] [ text msg.content ]) :: acc
      else
        (div [ class "alert alert-success text-left" ] [ text msg.content ]) :: acc
    )
    []
    model.history


-- VIEW
view : Model -> Html Msg
view model =
  div [ id "container" ]
    [ div [ id "history", class "well", scrollableStyle ] (historyView model)
    , div [ class "form-group input-group" ]
      [ span [ class "input-group-addon" ] (connectedView model)
      , input [ type' "text", placeholder "Enter your message...", class "form-control", value model.draft
        , onInput (\value -> SetDraft value)
        , onReturn (Send model.draft)
        ] []
      , div [ class "input-group-btn" ]
        [ button [ class "btn btn-primary", disabled (not model.connected), onClick (Send model.draft) ] [ text "Send" ]
        , button [ class "btn btn-primary dropdown-toggle", disabled (not model.connected), attribute "data-toggle" "dropdown" ]
          [ span [ class "caret"] []
          , span [ class "sr-only" ] [ text "Toggle Dropdown" ]
          ]
          , ul [ class "dropdown-menu dropdown-menu-right", attribute "aria-haspopup" "true", attribute "aria-expanded" "false"]
            [ li [ ] [ a [ href "#" ] [ text "Image or photo" ] ]
          ]
        ]
      ]
    ]


-- BOOKKEEPING
socketServer : String
socketServer =
  "ws://localhost:4000/socket/websocket"


initPhxSocket : Phoenix.Socket.Socket Msg
initPhxSocket =
  Phoenix.Socket.init socketServer
    |> Phoenix.Socket.withDebug


init : ( Model, Cmd Msg )
init =
  -- ( initialModel
  -- , Cmd.batch JoinChannel
  -- )
  update JoinChannel initialModel


subscriptions : Model -> Sub Msg
subscriptions model =
  Phoenix.Socket.listen model.phxSocket PhoenixMsg



main : Program Never
main =
  App.program
    { init = init
    , update = update
    , view = view
    , subscriptions = subscriptions
    }
