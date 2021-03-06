module.exports =
    process.env.npm_lifecycle_event === "start"
        ? {
            // Put your normal webpack config below here
            module: {
                rules: [
                    {
                        test: /\.(m?js|node)$/,
                        parser: {amd: false},
                        use: {
                            loader: '@marshallofsound/webpack-asset-relocator-loader',
                            options: {
                                outputAssetBase: 'native_modules',
                            },
                        },
                    },
                    {
                        test: /\.elm$/,
                        use: [
                            {loader: "elm-hot-webpack-loader"},
                            {
                                loader: "elm-webpack-loader",
                                options: {
                                    debug: false,
                                    forceWatch: true
                                }
                            }
                        ]
                    },
                    {
                        test: /\.scss$/,
                        use: [
                            "style-loader",
                            "css-loader?url=false",
                            "postcss-loader",
                            "sass-loader"
                        ]
                    },
                    {
                        test: /\.css$/,
                        use: [
                            "style-loader",
                            "css-loader"
                        ]
                    },
                    {
                        test: /\.(woff|woff2|eot|ttf|otf)$/,
                        use: [
                            'file-loader',
                        ],
                    }
                ]
            },
        }
        : {
            module: {
                rules: [
                    {
                        test: /\.(m?js|node)$/,
                        parser: {amd: false},
                        use: {
                            loader: '@marshallofsound/webpack-asset-relocator-loader',
                            options: {
                                outputAssetBase: 'native_modules',
                            },
                        },
                    },
                    {
                        test: /\.elm$/,
                        use: [
                            {
                                loader: "elm-webpack-loader",
                                options: {
                                    optimize: true
                                }
                            }
                        ]
                    },
                    {
                        test: /\.scss$/,
                        use: [
                            "style-loader",
                            "css-loader?url=false",
                            "postcss-loader",
                            "sass-loader"
                        ]
                    },
                    {
                        test: /\.css$/,
                        use: [
                            "style-loader",
                            "css-loader"
                        ]
                    },
                    {
                        test: /\.(woff|woff2|eot|ttf|otf)$/,
                        use: [{
                            loader: "file-loader",
                            options: {
                                outputPath: "fonts/",
                                publicPath: "../fonts/"
                            }
                        }],
                    }
                ]
            },
        };
