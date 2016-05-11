'
' config.bi
'

declare function config_get(section as string, key as string) as string
declare sub config_set(section as string, key as string, value as string)
declare function config_file() as string