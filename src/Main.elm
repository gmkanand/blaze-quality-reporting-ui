module Main exposing (Msg(..), main, update, view)

import Browser exposing (Document)
import Browser.Navigation as Nav
import Json.Encode exposing (Value)
import Page
import Page.Blank as Blank
import Page.Measure as Measure
import Page.Measure.List as MeasureList
import Page.NotFound as NotFound
import Route exposing (Route)
import Session exposing (Session)
import Url exposing (Url)



-- Model


type alias Model =
    { drawerOpen : Bool, page : Page }


type Page
    = Redirect Session
    | NotFound Session
    | MeasureList MeasureList.Model
    | Measure Measure.Model


init : Value -> Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url navKey =
    changeRouteTo (Route.fromUrl url)
        { drawerOpen = False
        , page =
            Redirect
                { navKey = navKey
                , base =
                    "http://localhost:8000/fhir"

                -- "https://blaze.life.uni-leipzig.de/fhir"
                }
        }



-- UPDATE


type Msg
    = ChangedUrl Url
    | ClickedLink Browser.UrlRequest
    | ClickedNavIcon
    | ClickedNavItem Page.NavItem
    | ClosedDrawer
    | GotMeasureListMsg MeasureList.Msg
    | GotMeasureMsg Measure.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.page ) of
        ( ChangedUrl url, _ ) ->
            changeRouteTo (Route.fromUrl url) model

        ( ClickedLink urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    case url.fragment of
                        Nothing ->
                            -- If we got a link that didn't include a fragment,
                            -- it's from one of those (href "") attributes that
                            -- we have to include to make the RealWorld CSS work.
                            --
                            -- In an application doing path routing instead of
                            -- fragment-based routing, this entire
                            -- `case url.fragment of` expression this comment
                            -- is inside would be unnecessary.
                            ( model, Cmd.none )

                        Just _ ->
                            ( model
                            , Nav.pushUrl
                                (Session.navKey (toSession model.page))
                                (Url.toString url)
                            )

                Browser.External href ->
                    ( model
                    , Nav.load href
                    )

        ( ClickedNavIcon, _ ) ->
            ( { model | drawerOpen = True }, Cmd.none )

        ( ClickedNavItem navItem, _ ) ->
            ( { model | drawerOpen = False }
            , Route.pushUrl (Session.navKey (toSession model.page)) (toRoute navItem)
            )

        ( ClosedDrawer, _ ) ->
            ( { model | drawerOpen = False }, Cmd.none )

        ( GotMeasureListMsg subMsg, MeasureList measureList ) ->
            MeasureList.update subMsg measureList
                |> updateWith MeasureList GotMeasureListMsg model

        ( GotMeasureMsg subMsg, Measure measure ) ->
            Measure.update subMsg measure
                |> updateWith Measure GotMeasureMsg model

        ( _, _ ) ->
            -- Disregard messages that arrived for the wrong page.
            ( model, Cmd.none )


toSession : Page -> Session
toSession page =
    case page of
        Redirect session ->
            session

        NotFound session ->
            session

        MeasureList measureList ->
            MeasureList.toSession measureList

        Measure measure ->
            Measure.toSession measure


changeRouteTo : Maybe Route -> Model -> ( Model, Cmd Msg )
changeRouteTo maybeRoute model =
    let
        session =
            toSession model.page
    in
    case maybeRoute of
        Nothing ->
            ( { model | page = NotFound session }, Cmd.none )

        Just Route.MeasureList ->
            MeasureList.init session
                |> updateWith MeasureList GotMeasureListMsg model

        Just (Route.Measure id) ->
            Measure.init session id
                |> updateWith Measure GotMeasureMsg model

        Just (Route.LibraryByUrl uri) ->
            Measure.init session uri
                |> updateWith Measure GotMeasureMsg model


toRoute : Page.NavItem -> Route
toRoute navItem =
    case navItem of
        Page.Measures ->
            Route.MeasureList


updateWith :
    (subModel -> Page)
    -> (subMsg -> Msg)
    -> Model
    -> ( subModel, Cmd subMsg )
    -> ( Model, Cmd Msg )
updateWith toModel toMsg model ( subModel, subCmd ) =
    ( { model | page = toModel subModel }
    , Cmd.map toMsg subCmd
    )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Document Msg
view model =
    let
        pageViewConfig =
            { onDrawerClose = ClosedDrawer
            , onNavIconClick = ClickedNavIcon
            , onNavItemClick = ClickedNavItem
            }

        viewPage toMsg config =
            let
                { title, body } =
                    Page.view
                        toMsg
                        pageViewConfig
                        model.drawerOpen
                        config
            in
            { title = title
            , body = body
            }
    in
    case model.page of
        Redirect _ ->
            Page.view
                identity
                pageViewConfig
                model.drawerOpen
                Blank.view

        NotFound _ ->
            Page.view
                identity
                pageViewConfig
                model.drawerOpen
                NotFound.view

        MeasureList measureList ->
            viewPage GotMeasureListMsg (MeasureList.view measureList)

        Measure measure ->
            viewPage GotMeasureMsg (Measure.view measure)



-- MAIN


main : Program Value Model Msg
main =
    Browser.application
        { init = init
        , onUrlChange = ChangedUrl
        , onUrlRequest = ClickedLink
        , subscriptions = subscriptions
        , update = update
        , view = view
        }
