'
' profile.bi
'

declare function profile_read(ini_file as string, ini_section as string, ini_key as string) as string
declare sub profile_write(ini_file as string, ini_section as string, ini_key as string, ini_value as string)
