'
' config.bas
'
#include "config.bi"
#include "profile.bi"
#include "util.bi"

function config_get(section as string, key as string) as string
    return profile_read(config_file(), section, key)
end function ' config_get()

sub config_set(section as string, key as string, value as string)
    profile_write config_file(), section, key, value    
end sub ' config_set()

function config_file() as string

    dim home_directory as string = environ("HOME")

    if file_exists("./.ilximrc") = 1 then return "./.ilximrc"
    if file_exists(home_directory & "/.ilximrc") then return home_directory & "/.ilximrc"
    if file_exists("/etc/ilxim.conf") then return "/etc/ilxim.conf"

    return ""

end function ' config_file()