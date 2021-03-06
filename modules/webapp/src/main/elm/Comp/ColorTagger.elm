module Comp.ColorTagger exposing
    ( Model
    , Msg
    , ViewOpts
    , init
    , update
    , view
    , view2
    )

import Comp.FixedDropdown
import Data.Color exposing (Color)
import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Styles as S
import Util.Maybe


type alias FormData =
    Dict String Color


type alias Model =
    { leftDropdown : Comp.FixedDropdown.Model String
    , colors : List Color
    , leftSelect : Maybe String
    }


type Msg
    = AddPair FormData Color
    | DeleteItem FormData String
    | EditItem String Color
    | LeftMsg (Comp.FixedDropdown.Msg String)


init : List String -> List Color -> Model
init leftSel colors =
    { leftDropdown = Comp.FixedDropdown.initString leftSel
    , colors = colors
    , leftSelect = Nothing
    }



--- Update


update : Msg -> Model -> ( Model, Maybe FormData )
update msg model =
    case msg of
        AddPair data color ->
            case model.leftSelect of
                Just l ->
                    ( model
                    , Just (Dict.insert l color data)
                    )

                _ ->
                    ( model, Nothing )

        DeleteItem data k ->
            ( model, Just (Dict.remove k data) )

        EditItem k _ ->
            ( { model
                | leftSelect = Just k
              }
            , Nothing
            )

        LeftMsg lm ->
            let
                ( m_, la ) =
                    Comp.FixedDropdown.update lm model.leftDropdown
            in
            ( { model
                | leftDropdown = m_
                , leftSelect = Util.Maybe.withDefault model.leftSelect la
              }
            , Nothing
            )



--- View


type alias ViewOpts =
    { renderItem : ( String, Color ) -> Html Msg
    , label : String
    , description : Maybe String
    }


view : FormData -> ViewOpts -> Model -> Html Msg
view data opts model =
    div [ class "field" ]
        [ label [] [ text opts.label ]
        , div [ class "inline field" ]
            [ Html.map LeftMsg
                (Comp.FixedDropdown.viewString
                    model.leftSelect
                    model.leftDropdown
                )
            ]
        , div [ class "field" ]
            [ chooseColor
                (AddPair data)
                Data.Color.all
                Nothing
            ]
        , renderFormData opts data
        , span
            [ classList
                [ ( "small-info", True )
                , ( "invisible hidden", opts.description == Nothing )
                ]
            ]
            [ Maybe.withDefault "" opts.description
                |> text
            ]
        ]


renderFormData : ViewOpts -> FormData -> Html Msg
renderFormData opts data =
    let
        values =
            Dict.toList data

        renderItem ( k, v ) =
            div [ class "item" ]
                [ a
                    [ class "link icon"
                    , href "#"
                    , onClick (DeleteItem data k)
                    ]
                    [ i [ class "trash icon" ] []
                    ]
                , a
                    [ class "link icon"
                    , href "#"
                    , onClick (EditItem k v)
                    ]
                    [ i [ class "edit icon" ] []
                    ]
                , opts.renderItem ( k, v )
                ]
    in
    div [ class "ui list" ]
        (List.map renderItem values)


chooseColor : (Color -> msg) -> List Color -> Maybe String -> Html msg
chooseColor tagger colors mtext =
    let
        renderLabel color =
            a
                [ class ("ui large label " ++ Data.Color.toString color)
                , href "#"
                , onClick (tagger color)
                ]
                [ Maybe.withDefault
                    (Data.Color.toString color)
                    mtext
                    |> text
                ]
    in
    div [ class "ui labels" ] <|
        List.map renderLabel colors



--- View2


view2 : FormData -> ViewOpts -> Model -> Html Msg
view2 data opts model =
    div [ class "flex flex-col" ]
        [ label [ class S.inputLabel ]
            [ text opts.label ]
        , Html.map LeftMsg
            (Comp.FixedDropdown.view2
                (Maybe.map (\s -> Comp.FixedDropdown.Item s s) model.leftSelect)
                model.leftDropdown
            )
        , div [ class "field" ]
            [ chooseColor2
                (AddPair data)
                Data.Color.all
                Nothing
            ]
        , renderFormData2 opts data
        , span
            [ classList
                [ ( "opacity-50 text-sm", True )
                , ( "hidden", opts.description == Nothing )
                ]
            ]
            [ Maybe.withDefault "" opts.description
                |> text
            ]
        ]


renderFormData2 : ViewOpts -> FormData -> Html Msg
renderFormData2 opts data =
    let
        values =
            Dict.toList data

        valueItem ( k, v ) =
            div [ class "flex flex-row items-center" ]
                [ a
                    [ class S.link
                    , class "mr-4 sm:mr-2 inline-flex"
                    , onClick (DeleteItem data k)
                    , href "#"
                    ]
                    [ i [ class "fa fa-trash" ] []
                    ]
                , a
                    [ class S.link
                    , class "mr-4 sm:mr-2 inline-flex"
                    , onClick (EditItem k v)
                    , href "#"
                    ]
                    [ i [ class "fa fa-edit" ] []
                    ]
                , span [ class "ml-2" ]
                    [ opts.renderItem ( k, v )
                    ]
                ]
    in
    div
        [ class "flex flex-col space-y-4 md:space-y-2 mt-2"
        , class "px-2 border-0 border-l dark:border-bluegray-600"
        ]
        (List.map valueItem values)


chooseColor2 : (Color -> msg) -> List Color -> Maybe String -> Html msg
chooseColor2 tagger colors mtext =
    let
        renderLabel color =
            a
                [ class (Data.Color.toString2 color)
                , class "label mt-1"
                , href "#"
                , onClick (tagger color)
                ]
                [ Maybe.withDefault
                    (Data.Color.toString color)
                    mtext
                    |> text
                ]
    in
    div [ class "flex flex-wrap flex-row space-x-2 mt-2" ] <|
        List.map renderLabel colors
