local toolchain = os.getenv("TOOLCHAIN")
local paths = {
    ["VMMB2"] = '--query-driver=/home/giovanni/ASD/toolchain/vmmb2/sysroots/x86_64-podsdk-linux/usr/bin/*podos*/*podos-linux-g*',
    ["VMMB3"] = '--query-driver=/home/giovanni/ASD/toolchain/vmmb3/sysroots/x86_64-podsdk-linux/usr/bin/*podos*/*podos-linux-g*',
    ["x86_64"] = '--query-driver=/home/giovanni/ASD/toolchain/genericx86-64/sysroots/x86_64-podsdk-linux/usr/bin/*podos*/*podos-linux-g*',
}

Clang_CMD={ 'clangd', '--clang-tidy', '--offset-encoding=utf-16', '-header-insertion=never', paths[toolchain] or ''}

require("main")
