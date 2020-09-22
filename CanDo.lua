function CanDo_Print(...)
    print("CanDo: ", ...);
end

function CanDo_CreateInitialCharacterData()
    return {
        frames = {
            {
                name = "Main Group",
                display = {
                    -- arrangement = {
                    --     type = "grid",
                    --     rows = 0,
                    --     columns = 2,
                    --     buttonSize = 40,
                    --     padding = 5,
                    -- },
                    arrangement = {
                        type = "circle",
                        -- sizing = "absolute",
                        sizing = "relative",
                        relativeTo = "height",
                        -- relativeTo = "width",
                        diameter = .25,
                        buttonSize = 40,
                    },
                    -- values match call to SetPoint on Frame widgets
                    positioning = {
                        type = "relative",
                        anchor = "CENTER",
                        relativeAnchor = "CENTER",
                        -- values in percentage of screen
                        offsetX = 0,
                        offsetY = -.05,
                    },
                    -- positioning = {
                    --     type = "absolute",
                    --     anchor = "CENTER",
                    --     relativeAnchor = "CENTER",
                    --     -- absolute pixel values
                    --     offsetX = 0,
                    --     offsetY = -200,
                    -- },
                },
                items = {
                    {
                        source = {
                            type = "actionbar",
                            slot = 1,
                        }
                    },
                    {
                        source = {
                            type = "actionbar",
                            slot = 2,
                        }
                    },
                    {
                        source = {
                            type = "actionbar",
                            slot = 3,
                        }
                    },
                    {
                        source = {
                            type = "actionbar",
                            slot = 4,
                        }
                    },
                    {
                        source = {
                            type = "actionbar",
                            slot = 5,
                        }
                    },
                    {
                        source = {
                            type = "actionbar",
                            slot = 6,
                        }
                    },
                    {
                        source = {
                            type = "actionbar",
                            slot = 7,
                        }
                    },
                    {
                        source = {
                            type = "actionbar",
                            slot = 8,
                        }
                    },
                    {
                        source = {
                            type = "actionbar",
                            slot = 9,
                        }
                    },
                    {
                        source = {
                            type = "actionbar",
                            slot = 10,
                        }
                    },
                    {
                        source = {
                            type = "actionbar",
                            slot = 11,
                        }
                    },
                    {
                        source = {
                            type = "actionbar",
                            slot = 12,
                        }
                    }
                }
            }
        }
    };
end