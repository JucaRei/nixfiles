-- gvfs-smb.lua
-- Intercepta URLs do protocolo smb:// e mapeia de forma transparente para o ponto de
-- montagem FUSE do GVfs (/run/user/<uid>/gvfs/smb-share:server=...,share=...).
-- Isso permite que o MPV reproduza vídeos diretamente de compartilhamentos Samba/Windows
-- sem exigir recompilação do FFmpeg com libsmbclient.

local utils = require 'mp.utils'
local msg = require 'mp.msg'

-- Função para decodificar caracteres codificados em URL (ex: %20 -> espaço)
local function url_decode(str)
    if not str then return "" end
    str = str:gsub("+", " ")
    str = str:gsub("%%(%x%x)", function(h)
        return string.char(tonumber(h, 16))
    end)
    return str
end

mp.add_hook("on_load", 10, function()
    local path = mp.get_property("path", "")
    if not path or not path:find("^smb://") then
        return
    end

    msg.info("Intercepted SMB URL: " .. path)
    local decoded = url_decode(path)
    local stripped = decoded:gsub("^smb://", "")

    -- Estrutura da URL: [user[:pass]@]host[:port]/share[/subpath...]
    local host_part, rest = stripped:match("([^/]+)/(.*)")
    if not host_part or not rest then
        msg.warn("Could not parse SMB URL structure: " .. path)
        return
    end

    -- Extrai servidor (ignora eventual usuário/senha no prefixo e porta no sufixo)
    local server = host_part:match("@([^@]+)$") or host_part
    server = server:match("^([^:]+)") or server

    -- Extrai o nome do compartilhamento (share) e o caminho relativo
    local share, relpath = rest:match("([^/]+)/?(.*)")
    if not share then
        share = rest
        relpath = ""
    end

    -- Remove barras finais redundantes no caminho relativo
    relpath = relpath:gsub("/+$", "")

    local gvfs_dir = os.getenv("XDG_RUNTIME_DIR") or ("/run/user/" .. (os.getenv("UID") or "1000"))
    local share_prefix = "smb-share:server=" .. server .. ",share=" .. share
    local gvfs_share_dir = gvfs_dir .. "/gvfs/" .. share_prefix
    local new_path = gvfs_share_dir .. (relpath ~= "" and ("/" .. relpath) or "")

    -- Verifica se o compartilhamento já está exposto pelo FUSE
    local info = utils.file_info(gvfs_share_dir)
    if not info then
        msg.info("GVfs mount not active at " .. gvfs_share_dir .. ", attempting gio mount...")
        local mount_url = "smb://" .. server .. "/" .. share
        utils.subprocess({
            args = { "gio", "mount", "--anonymous", mount_url },
            playback_only = false
        })
        info = utils.file_info(gvfs_share_dir)
    end

    if info then
        msg.info("Redirecting MPV stream to GVfs FUSE path: " .. new_path)
        mp.set_property("stream-open-filename", new_path)
    else
        msg.warn("Could not find or mount GVfs share at: " .. gvfs_share_dir)
    end
end)
