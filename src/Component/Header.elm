module Component.Header exposing (Model, Msg, init, update, view)

import Events
import Html exposing (..)
import Html.Attributes exposing (class, classList)
import Material.Button exposing (buttonConfig, outlinedButton, unelevatedButton)
import Material.IconButton exposing (iconButton, iconButtonConfig)
import Material.LayoutGrid exposing (layoutGridCell, span12)
import Material.TextArea exposing (textArea, textAreaConfig)
import Material.TextField exposing (textField, textFieldConfig)



-- MODEL


type alias Model =
    { title : Maybe String
    , enteredTitle : Maybe String
    , description : Maybe String
    , enteredDescription : Maybe String
    , edit : Bool
    }


init : Maybe String -> Maybe String -> Model
init title description =
    { title = title
    , enteredTitle = title
    , description = description
    , enteredDescription = description
    , edit = False
    }



-- UPDATE


type Msg
    = ClickedEdit
    | EnteredTitle String
    | EnteredDescription String
    | ClickedCancel


update : Msg -> Model -> Model
update msg model =
    case msg of
        ClickedEdit ->
            { model | edit = True }

        EnteredTitle title ->
            { model | enteredTitle = blankToNothing title }

        EnteredDescription description ->
            { model | enteredDescription = blankToNothing description }

        ClickedCancel ->
            { model
                | enteredTitle = model.title
                , enteredDescription = model.description
                , edit = False
            }


blankToNothing s =
    if String.isEmpty s then
        Nothing

    else
        Just s



-- VIEW


type alias Config msg =
    { onSave : Maybe String -> Maybe String -> msg
    , onDelete : msg
    , onMsg : Msg -> msg
    }


view : Config msg -> Model -> Html msg
view { onSave, onDelete, onMsg } { title, enteredTitle, description, enteredDescription, edit } =
    layoutGridCell
        [ class "measure-header"
        , span12
        , classList [ ( "measure-header--edit", edit ) ]
        ]
    <|
        [ div [ class "measure-header__title" ]
            (if edit then
                [ textField
                    { textFieldConfig
                        | value = Maybe.withDefault "" enteredTitle
                        , outlined = True
                        , onInput = Just (EnteredTitle >> onMsg)
                        , additionalAttributes =
                            [ Events.onEnterEsc
                                (onSave enteredTitle enteredDescription)
                                (onMsg ClickedCancel)
                            ]
                    }
                ]

             else
                [ h2 [ class "mdc-typography--headline5" ]
                    [ text (Maybe.withDefault "<not specified>" title) ]
                , iconButton
                    { iconButtonConfig | onClick = Just (onMsg ClickedEdit) }
                    "edit"
                ]
            )
        ]
            ++ (if edit then
                    [ div [ class "measure-header__description" ]
                        [ textArea
                            { textAreaConfig
                                | value = Maybe.withDefault "" enteredDescription
                                , fullwidth = True
                                , onInput = Just (EnteredDescription >> onMsg)
                            }
                        ]
                    , div [ class "measure-header__action-buttons" ]
                        [ unelevatedButton
                            { buttonConfig
                                | onClick = Just (onSave enteredTitle enteredDescription)
                            }
                            "Save"
                        , div [ class "measure-header__action-buttons-right" ]
                            [ unelevatedButton
                                { buttonConfig
                                    | onClick = Just onDelete
                                    , additionalAttributes =
                                        [ class "measure-header__delete-button" ]
                                }
                                "Delete"
                            , outlinedButton
                                { buttonConfig
                                    | onClick = Just (onMsg ClickedCancel)
                                }
                                "Cancel"
                            ]
                        ]
                    ]

                else
                    case description of
                        Just s ->
                            [ div [ class "measure-header__description" ]
                                [ text s ]
                            ]

                        Nothing ->
                            []
               )
