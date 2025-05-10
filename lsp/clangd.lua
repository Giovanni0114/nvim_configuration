return {
    filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda', 'proto', 'C' },
    cmd = { 'clangd', '--clang-tidy', '--offset-encoding=utf-16', '-header-insertion=never' },
}
