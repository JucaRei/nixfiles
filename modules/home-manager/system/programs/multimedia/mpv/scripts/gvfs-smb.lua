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

    -- Função para localizar dinamicamente a pasta do compartilhamento no GVfs FUSE
    local function find_gvfs_mount(srv, shr)
        local direct = gvfs_dir .. "/gvfs/smb-share:server=" .. srv .. ",share=" .. shr
        if utils.file_info(direct) then
            return direct
        end

        -- Varredura dinâmica para compartilhamentos com sufixos (ex: ,user=juca) ou variações de maiúsculas/minúsculas
        local entries = utils.readdir(gvfs_dir .. "/gvfs", "dirs")
        if entries then
            local s_srv = srv:lower()
            local s_shr = shr:lower()
            for _, entry in ipairs(entries) do
                local e = entry:lower()
                if e:find("^smb%-share:") and e:find("server=" .. s_srv, 1, true) and e:find("share=" .. s_shr, 1, true) then
                    local candidate = gvfs_dir .. "/gvfs/" .. entry
                    if utils.file_info(candidate) then
                        return candidate
                    end
                end
            end
        end
        return nil
    end

    local gvfs_share_dir = find_gvfs_mount(server, share)

    -- Se não estiver ativo, tenta montar via GIO
    if not gvfs_share_dir then
        msg.info("GVfs mount not active for " .. server .. "/" .. share .. ", attempting gio mount...")
        local mount_url = "smb://" .. server .. "/" .. share
        utils.subprocess({
            args = { "gio", "mount", "--anonymous", mount_url },
            playback_only = false
        })
        gvfs_share_dir = find_gvfs_mount(server, share)
    end

    if gvfs_share_dir then
        local new_path = gvfs_share_dir .. (relpath ~= "" and ("/" .. relpath) or "")
        msg.info("Redirecting MPV stream to GVfs FUSE path: " .. new_path)
        mp.set_property("stream-open-filename", new_path)
    else
        msg.warn("Could not find or mount GVfs share for server=" .. server .. ", share=" .. share)
    end
end)
