-- Yazi plugin to preview 3D mesh files using Python/trimesh
-- Supported formats: obj, stl, ply, gltf, glb, fbx, 3ds, off, dae, and more

local M = {}

-- Path to the Python interpreter in our venv
local plugin_dir = os.getenv("HOME") .. "/.config/yazi/plugins/mesh-preview.yazi"
local python_path = plugin_dir .. "/.venv/bin/python3"
local script_path = plugin_dir .. "/render_mesh.py"

function M:peek(job)
    ya.err("mesh-preview: peek called for " .. tostring(job.file.url))
    
    local cache = ya.file_cache(job)
    if not cache then
        ya.err("mesh-preview: no cache path")
        return self:fallback(job, "Failed to get cache path")
    end
    
    ya.err("mesh-preview: cache path = " .. tostring(cache))

    -- Check if already cached
    local cha = fs.cha(cache)
    if not cha or cha.len == 0 then
        ya.err("mesh-preview: cache not found, rendering...")
        -- Not cached yet, render now
        local ok = self:render(job, cache)
        if not ok then
            ya.err("mesh-preview: render failed")
            return self:fallback(job, "Failed to render mesh")
        end
        ya.err("mesh-preview: render succeeded")
    else
        ya.err("mesh-preview: using cached file, size = " .. tostring(cha.len))
    end

    -- Show the rendered image
    ya.err("mesh-preview: showing image")
    ya.image_show(cache, job.area)
    ya.err("mesh-preview: done")
end

function M:seek(job)
    local h = cx.active.current.hovered
    if h and h.url == job.file.url then
        local step = ya.clamp(-1, job.units, 1)
        ya.manager_emit("peek", { math.max(0, cx.active.preview.skip + step), only_if = job.file.url })
    end
end

function M:render(job, cache)
    -- Calculate preview size
    local width = job.area and job.area.w and math.max(400, job.area.w * 8) or 600
    local height = job.area and job.area.h and math.max(300, job.area.h * 16) or 400

    ya.err("mesh-preview: rendering " .. tostring(job.file.url) .. " -> " .. tostring(cache))
    ya.err("mesh-preview: size = " .. tostring(width) .. "x" .. tostring(height))
    ya.err("mesh-preview: python = " .. python_path)
    ya.err("mesh-preview: script = " .. script_path)

    -- Run Python script to render the mesh
    local status, err = Command(python_path)
        :arg({
            script_path,
            tostring(job.file.url),
            tostring(cache),
            tostring(width),
            tostring(height),
        })
        :status()

    ya.err("mesh-preview: command finished, status = " .. tostring(status and status.success))

    if status and status.success then
        return true
    else
        ya.err("mesh-preview: render failed for: " .. tostring(job.file.url))
        return false
    end
end

function M:preload(job)
    return 1
end

function M:fallback(job, message)
    ya.preview_widget(job, ui.Text {
        ui.Line { ui.Span("3D Mesh Preview"):bold() },
        ui.Line { ui.Span("") },
        ui.Line { ui.Span("Error: " .. message):fg("red") },
        ui.Line { ui.Span("") },
        ui.Line { ui.Span("File: " .. tostring(job.file.url)):fg("gray") },
    }:area(job.area))
end

return M
