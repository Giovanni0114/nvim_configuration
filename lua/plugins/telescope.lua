return {     -- Fuzzy Finder (files, lsp, etc)
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    branch = '0.1.x',
    dependencies = {
        'nvim-telescope/telescope-symbols.nvim',
        'nvim-lua/plenary.nvim',
        {     -- If encountering errors, see telescope-fzf-native README for install instructions
            'nvim-telescope/telescope-fzf-native.nvim',

            build = 'make',

            -- `cond` is a condition used to determine whether this plugin should be
            -- installed and loaded.
            cond = function()
                return vim.fn.executable 'make' == 1
            end,
        },
        { 'nvim-telescope/telescope-ui-select.nvim' },
        { 'nvim-tree/nvim-web-devicons' }
    },
    config = function()
        -- Two important keymaps to use while in telescope are:
        --  - Insert mode: <c-/>
        --  - Normal mode: ?

        require('telescope').setup {
            defaults = {
                layout_strategy = "vertical",
                mappings = {
                    i = { ['<c-enter>'] = 'to_fuzzy_refine' },
                },
            },
            extensions = {
                ['ui-select'] = {
                    require('telescope.themes').get_dropdown(),
                },
            },
        }

        -- Enable telescope extensions, if they are installed
        pcall(require('telescope').load_extension, 'fzf')
        pcall(require('telescope').load_extension, 'ui-select')
    end,
}
