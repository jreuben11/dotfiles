return {
    "echasnovski/mini.operators",
    version = "*",
    event = "VeryLazy",
    opts = {
        replace = { prefix = "gr" },  -- griw, grap, etc.
        exchange = { prefix = "gx" }, -- gxiw to swap two regions
        multiply = { prefix = "gm" }, -- gmip to duplicate paragraph
        sort = { prefix = "gs" },     -- gsip to sort paragraph
        evaluate = { prefix = "g=" }, -- g=ip to evaluate expression
    },
}
