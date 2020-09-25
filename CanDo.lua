function CanDo_Print(...)
    print("CanDo: ", ...);
end

function CanDo_CreateEmptyFrame(name)
    return {
        name = name,
        display = {
            buttonSize = 40,
            backgroundAlpha = 0,
            backgroundColor = {r = 0, g = 0, b = 0},
            activeButtonAlpha = .5,
            inactiveButtonAlpha = .15,
            arrangement = {
                type = "grid",
                rows = 3,
                columns = 4,
                padding = 5,
            },
            positioning = {
                type = "absolute",
                anchor = "CENTER",
                relativeAnchor = "CENTER",
                offsetX = 0,
                offsetY = 0,
            },
        },
        items = {}
    }
end

function CanDo_CreateInitialCharacterData()
    return {
        frames = {
            {
                name = "Main Group",
                display = {
                    buttonSize = 40,
                    backgroundColor = {r = 0, g = 0, b = 0, a = .25},
                    activeButtonAlpha = .5,
                    inactiveButtonAlpha = .15,
                    -- arrangement = {
                    --     type = "grid",
                    --     rows = 0,
                    --     columns = 2,
                    --     padding = 5,
                    -- },
                    arrangement = {
                        type = "circle",
                        -- sizing = "absolute",
                        sizing = "relative",
                        relativeTo = "height",
                        -- relativeTo = "width",
                        diameter = .25,
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

function CanDo_tcopy(to, from)   -- "to" must be a table (possibly empty)
   for k,v in pairs(from) do
     if(type(v)=="table") then
       to[k] = {}
       CanDo_tcopy(to[k], v);
     else
       to[k] = v;
     end
   end
 end